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

    private func clerkPost(path: String, body: [String: String]) -> URLRequest {
        var req = URLRequest(url: URL(string: "\(fapiBase)\(path)")!)
        req.httpMethod = "POST"
        req.setValue("Bearer \(publishableKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = formEncode(body)
        return req
    }

    private func extractError(_ data: Data) -> String {
        if let resp = try? decoder.decode(ClerkErrorResponse.self, from: data),
           let msg = resp.errors?.first?.longMessage ?? resp.errors?.first?.message {
            return msg
        }
        return String(data: data, encoding: .utf8)?.prefix(200).description ?? "Error desconocido"
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws -> (token: String, userId: String) {
        let req = clerkPost(path: "/v1/client/sign_ins",
                            body: ["identifier": email, "password": password, "strategy": "password"])
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ClerkError.network }
        if http.statusCode >= 400 { throw ClerkError.api(extractError(data)) }

        let result = try decoder.decode(ClerkSignInResponse.self, from: data)
        guard result.response?.status == "complete",
              let session   = result.client?.sessions?.first,
              let token     = session.lastActiveToken?.jwt,
              let userId    = session.userId
        else {
            let status = result.response?.status ?? "nil"
            throw ClerkError.api("Estado inesperado: \(status)")
        }
        return (token, userId)
    }

    // MARK: - Sign Up

    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> String {
        let req = clerkPost(path: "/v1/client/sign_ups", body: [
            "first_name":    firstName,
            "last_name":     lastName,
            "email_address": email,
            "password":      password
        ])
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ClerkError.network }
        if http.statusCode >= 400 { throw ClerkError.api(extractError(data)) }

        let result = try decoder.decode(ClerkSignUpResponse.self, from: data)
        guard let signUpId = result.response?.id else { throw ClerkError.api("No se pudo crear la cuenta") }
        return signUpId
    }

    // Sends email verification code
    func prepareVerification(signUpId: String) async throws {
        let req = clerkPost(path: "/v1/client/sign_ups/\(signUpId)/prepare_verification",
                            body: ["strategy": "email_code"])
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ClerkError.network }
        if http.statusCode >= 400 { throw ClerkError.api(extractError(data)) }
    }

    // Verifies the 6-digit code and returns a session token
    func attemptVerification(signUpId: String, code: String) async throws -> (token: String, userId: String) {
        let req = clerkPost(path: "/v1/client/sign_ups/\(signUpId)/attempt_verification",
                            body: ["strategy": "email_code", "code": code])
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ClerkError.network }
        if http.statusCode >= 400 { throw ClerkError.api(extractError(data)) }

        let result = try decoder.decode(ClerkSignUpVerifyResponse.self, from: data)
        guard result.response?.status == "complete",
              let session = result.client?.sessions?.first,
              let token   = session.lastActiveToken?.jwt,
              let userId  = session.userId
        else {
            let status = result.response?.status ?? "nil"
            throw ClerkError.api("Verificación incompleta: \(status)")
        }
        return (token, userId)
    }
}

// MARK: - Errors

enum ClerkError: LocalizedError {
    case network
    case api(String)
    var errorDescription: String? {
        switch self {
        case .network:    return "Error de red"
        case .api(let m): return m
        }
    }
}

// MARK: - Response models

private struct ClerkErrorResponse: Codable {
    struct ClerkErr: Codable {
        let message: String?
        let longMessage: String?
    }
    let errors: [ClerkErr]?
}

private struct ClerkToken: Codable {
    let jwt: String?
}

private struct ClerkSession: Codable {
    let userId: String?
    let lastActiveToken: ClerkToken?
}

private struct ClerkClient: Codable {
    let sessions: [ClerkSession]?
}

private struct ClerkSignInResponse: Codable {
    struct Inner: Codable { let status: String? }
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
