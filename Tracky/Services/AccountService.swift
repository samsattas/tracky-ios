import Foundation

final class AccountService {
    static let shared = AccountService()
    private let api = APIClient.shared

    func fetchAccounts() async throws -> [Account] {
        try await api.get("/accounts")
    }

    func updateAlias(id: String, alias: String) async throws {
        try await api.patch("/accounts/\(id)", body: ["alias": alias])
    }

    func delete(id: String) async throws {
        try await api.delete("/accounts/\(id)")
    }
}
