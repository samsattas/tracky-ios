import Foundation

final class CategoryService {
    static let shared = CategoryService()
    private let api = APIClient.shared

    func fetchRules() async throws -> [Rule] {
        try await api.get("/categories/rules")
    }

    func createRule(match: String, category: String, priority: Int = 1) async throws -> Rule {
        struct Body: Encodable { let match: String; let category: String; let priority: Int }
        return try await api.post("/categories/rules", body: Body(match: match, category: category, priority: priority))
    }

    func toggleRule(id: String, enabled: Bool) async throws {
        try await api.patch("/categories/rules/\(id)", body: ["enabled": enabled])
    }

    func deleteRule(id: String) async throws {
        try await api.delete("/categories/rules/\(id)")
    }
}
