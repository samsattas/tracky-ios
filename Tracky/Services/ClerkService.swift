import Foundation

// Clerk REST client — no SDK dependency required.
// Uses Clerk's Frontend API directly with the publishable key.
final class ClerkService {
    static let shared = ClerkService()

    private let publishableKey = "pk_test_ZW1pbmVudC1kYW5lLTg5LmNsZXJrLmFjY291bnRzLmRldiQ"

    // Frontend API domain derived from publishable key (base64-encoded in the key suffix)
    private var fapiBase: String {
        let b64 = publishableKey
            .replacingOccurrences(of: "pk_test_", with: "")
            .replacingOccurrences(of: "pk_live_", with: "")
        let padded = b64 + String(repeating: "=", count: (4 - b64.count % 4) % 4)
        guard let data   = Data(base64Encoded: padded),
              let domain = String(data: data, encoding: .utf8)?
                  .trimmingCharacters(in: CharacterSet(charactersIn: "$"))
        else { return "https://eminent-dane-89.clerk.accounts.dev" }
        return "https://\(domain)"
    }

    // Decoder that converts snake_case keys from Clerk's JSON to camelCase Swift properties
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    // application/x-www-form-urlencoded encoder that encodes all special chars
    private func formEncode(_ dict: [String: String]) -> Data {
        let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
        return dict.map { k, v in
            let ek = k.addingPercentEncoding(withAllowedCharacters: allowed) ?? k
            let ev = v.addingPercentEncoding(withAllowedCharacters: allowed) ?? v
            return "\(ek)=\(ev)"
        }.joined(separator: "&").data(using: .utf8) ?? Data()
    }

    // Rotating client JWT for native flows. Clerk returns it in the Authorization
    // response header of every FAPI call and expects it back on subsequent requests.
    private var clientJWT: String? {
        get { UserDefaults.standard.string(forKey: "clerk_client_jwt") }
        set { UserDefaults.standard.set(newValue, forKey: "clerk_client_jwt") }
    }

    private func clerkPost(path: String, body: [String: String]) -> URLRequest {
        // _is_native=1 marks the request as a native app flow (required on dev instances,
        // otherwise Clerk responds 401 dev_browser_unauthenticated)
        var req = URLRequest(url: URL(string: "\(fapiBase)\(path)?_is_native=1")!)
        req.httpMethod = "POST"
        if let jwt = clientJWT {
            req.setValue(jwt, forHTTPHeaderField: "Authorization")
        }
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = formEncode(body)
        return req
    }

    // Shared POST that captures the rotated client JWT, logs, and maps errors
    private func send(path: String, body: [String: String]) async throws -> Data {
        let req = clerkPost(path: path, body: body)
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ClerkError.network }
        if let jwt = http.value(forHTTPHeaderField: "Authorization"), !jwt.isEmpty {
            clientJWT = jwt
        }
        debugLog(path, http, data)
        if http.statusCode >= 400 {
            // The client can already hold an active session (e.g. a previous sign-in
            // completed server-side). Surface it so callers can recover the session.
            if let resp = try? decoder.decode(ClerkErrorResponse.self, from: data),
               resp.errors?.first?.code == "session_exists" {
                throw ClerkError.sessionExists(data)
            }
            throw ClerkError.api(extractError(data))
        }
        return data
    }

    // Debug logging for API testing — prints status + response body to console
    private func debugLog(_ path: String, _ resp: URLResponse?, _ data: Data) {
        let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
        let body = String(data: data, encoding: .utf8) ?? "<binary>"
        print("🔐 [Clerk] POST \(path) → \(status)\n\(body)")
    }

    private func extractError(_ data: Data) -> String {
        if let resp = try? decoder.decode(ClerkErrorResponse.self, from: data),
           let msg = resp.errors?.first?.longMessage ?? resp.errors?.first?.message {
            return msg
        }
        return String(data: data, encoding: .utf8)?.prefix(200).description ?? "Error desconocido"
    }

    // MARK: - Sign In

    enum SignInResult {
        case complete(token: String, userId: String, firstName: String?)
        // Clerk dev instances require email-code verification for new devices
        case needsSecondFactor(signInId: String)
    }

    func signIn(email: String, password: String) async throws -> SignInResult {
        let data: Data
        do {
            data = try await send(path: "/v1/client/sign_ins",
                                  body: ["identifier": email, "password": password, "strategy": "password"])
        } catch ClerkError.sessionExists(let errData) {
            // Reuse the active session that Clerk returns in the error's meta.client
            let err = try decoder.decode(ClerkErrorResponse.self, from: errData)
            guard let session = err.meta?.client?.sessions?.first,
                  let token   = session.lastActiveToken?.jwt,
                  let userId  = session.resolvedUserId
            else { throw ClerkError.api("Ya tienes una sesión activa pero no se pudo recuperar") }
            return .complete(token: token, userId: userId, firstName: session.firstName)
        }
        let result = try decoder.decode(ClerkSignInResponse.self, from: data)

        if result.response?.status == "needs_second_factor", let signInId = result.response?.id {
            return .needsSecondFactor(signInId: signInId)
        }
        guard result.response?.status == "complete",
              let session   = result.client?.sessions?.first,
              let token     = session.lastActiveToken?.jwt,
              let userId    = session.resolvedUserId
        else {
            let status = result.response?.status ?? "nil"
            throw ClerkError.api("Estado inesperado: \(status)")
        }
        return .complete(token: token, userId: userId, firstName: session.firstName)
    }

    // Sends the email code for the second factor (new-device verification)
    func prepareSecondFactor(signInId: String) async throws {
        _ = try await send(path: "/v1/client/sign_ins/\(signInId)/prepare_second_factor",
                           body: ["strategy": "email_code"])
    }

    // Verifies the 6-digit code and completes the sign-in
    func attemptSecondFactor(signInId: String, code: String) async throws -> (token: String, userId: String, firstName: String?) {
        let data = try await send(path: "/v1/client/sign_ins/\(signInId)/attempt_second_factor",
                                  body: ["strategy": "email_code", "code": code])
        let result = try decoder.decode(ClerkSignInResponse.self, from: data)
        guard result.response?.status == "complete",
              let session = result.client?.sessions?.first,
              let token   = session.lastActiveToken?.jwt,
              let userId  = session.resolvedUserId
        else {
            let status = result.response?.status ?? "nil"
            throw ClerkError.api("Verificación incompleta: \(status)")
        }
        return (token, userId, session.firstName)
    }

    // MARK: - Sign Up

    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> String {
        let data = try await send(path: "/v1/client/sign_ups", body: [
            "first_name":    firstName,
            "last_name":     lastName,
            "email_address": email,
            "password":      password
        ])
        let result = try decoder.decode(ClerkSignUpResponse.self, from: data)
        guard let signUpId = result.response?.id else { throw ClerkError.api("No se pudo crear la cuenta") }
        return signUpId
    }

    // Sends email verification code
    func prepareVerification(signUpId: String) async throws {
        _ = try await send(path: "/v1/client/sign_ups/\(signUpId)/prepare_verification",
                           body: ["strategy": "email_code"])
    }

    // Verifies the 6-digit code and returns a session token
    func attemptVerification(signUpId: String, code: String) async throws -> (token: String, userId: String, firstName: String?) {
        let data = try await send(path: "/v1/client/sign_ups/\(signUpId)/attempt_verification",
                                  body: ["strategy": "email_code", "code": code])
        let result = try decoder.decode(ClerkSignUpVerifyResponse.self, from: data)
        guard result.response?.status == "complete",
              let session = result.client?.sessions?.first,
              let token   = session.lastActiveToken?.jwt,
              let userId  = session.resolvedUserId
        else {
            let status = result.response?.status ?? "nil"
            throw ClerkError.api("Verificación incompleta: \(status)")
        }
        return (token, userId, session.firstName)
    }
}

// MARK: - Errors

enum ClerkError: LocalizedError {
    case network
    case api(String)
    // Carries the raw error body so callers can recover the existing session from meta.client
    case sessionExists(Data)
    var errorDescription: String? {
        switch self {
        case .network:        return "Error de red"
        case .api(let m):     return m
        case .sessionExists:  return "Ya tienes una sesión activa"
        }
    }
}

// MARK: - Response models

private struct ClerkErrorResponse: Codable {
    struct ClerkErr: Codable {
        let message: String?
        let longMessage: String?
        let code: String?
    }
    struct Meta: Codable {
        let client: ClerkClient?
    }
    let errors: [ClerkErr]?
    let meta: Meta?
}

private struct ClerkToken: Codable {
    let jwt: String?
}

private struct ClerkSession: Codable {
    struct ClerkUser: Codable { let id: String?; let firstName: String? }
    let userId: String?          // some responses use "user_id"
    let user: ClerkUser?         // others nest the full user object
    let lastActiveToken: ClerkToken?
    var resolvedUserId: String? { userId ?? user?.id }
    var firstName: String? { user?.firstName }
}

private struct ClerkClient: Codable {
    let sessions: [ClerkSession]?
}

private struct ClerkSignInResponse: Codable {
    struct Inner: Codable { let id: String?; let status: String? }
    let response: Inner?
    let client: ClerkClient?
}

private struct ClerkSignUpResponse: Codable {
    struct Inner: Codable { let id: String?; let status: String? }
    let response: Inner?
}

private struct ClerkSignUpVerifyResponse: Codable {
    struct Inner: Codable { let status: String? }
    let response: Inner?
    let client: ClerkClient?
}
