import Foundation

enum APIError: LocalizedError {
    case noToken
    case http(Int, String?)
    case decoding(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .noToken:        return "Sesión no iniciada"
        case .http(let c, let m): return m ?? "Error HTTP \(c)"
        case .decoding(let e):return "Error de datos: \(e.localizedDescription)"
        case .network(let e): return e.localizedDescription
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let base = "https://tracky-backend.vercel.app"

    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    // MARK: - Token

    private func authHeader() throws -> String {
        guard let token = SessionStore.shared.token else { throw APIError.noToken }
        return "Bearer \(token)"
    }

    // MARK: - Generic request

    private func request(_ path: String, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: base + path) else { fatalError("Bad URL: \(path)") }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue(try authHeader(), forHTTPHeaderField: "Authorization")
        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = body
        }
        return req
    }

    private func perform(_ req: URLRequest) async throws -> Data {
        let (data, resp): (Data, URLResponse)
        do { (data, resp) = try await URLSession.shared.data(for: req) }
        catch { throw APIError.network(error) }

        if let http = resp as? HTTPURLResponse, http.statusCode >= 400 {
            let msg = try? JSONDecoder().decode([String: String].self, from: data)["error"]
            throw APIError.http(http.statusCode, msg)
        }
        return data
    }

    // MARK: - Public helpers

    func get<T: Decodable>(_ path: String) async throws -> T {
        let data = try await perform(try request(path))
        do { return try decoder.decode(T.self, from: data) }
        catch { throw APIError.decoding(error) }
    }

    func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        let bodyData = try JSONEncoder().encode(body)
        let data = try await perform(try request(path, method: "POST", body: bodyData))
        do { return try decoder.decode(T.self, from: data) }
        catch { throw APIError.decoding(error) }
    }

    func post(_ path: String, body: [String: Any] = [:]) async throws {
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        _ = try await perform(try request(path, method: "POST", body: bodyData))
    }

    func patch(_ path: String, body: [String: Any]) async throws {
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        _ = try await perform(try request(path, method: "PATCH", body: bodyData))
    }

    func delete(_ path: String) async throws {
        _ = try await perform(try request(path, method: "DELETE"))
    }
}
