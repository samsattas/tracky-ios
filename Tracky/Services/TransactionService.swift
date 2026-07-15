import Foundation

final class TransactionService {
    static let shared = TransactionService()
    private let api = APIClient.shared

    func fetchPending() async throws -> [PendingTransaction] {
        try await api.get("/transactions/pending")
    }

    func fetchHistory(from: String? = nil, to: String? = nil, category: String? = nil, bank: String? = nil, limit: Int = 50, offset: Int = 0) async throws -> [ConfirmedTransaction] {
        var params: [String] = ["limit=\(limit)", "offset=\(offset)"]
        if let from     { params.append("from=\(from)") }
        if let to       { params.append("to=\(to)") }
        if let category { params.append("category=\(category)") }
        if let bank     { params.append("bank=\(bank)") }
        let query = params.joined(separator: "&")
        return try await api.get("/transactions/history?\(query)")
    }

    func approve(id: String, category: String? = nil, merchant: String? = nil, notes: String? = nil) async throws {
        var body: [String: Any] = [:]
        if let c = category { body["category"] = c }
        if let m = merchant { body["merchant"] = m }
        if let n = notes    { body["notes"]    = n }
        try await api.post("/transactions/\(id)/approve", body: body)
    }

    func discard(id: String) async throws {
        try await api.post("/transactions/\(id)/discard")
    }

    func delete(id: String) async throws {
        try await api.delete("/transactions/\(id)")
    }

    func update(id: String, fields: [String: Any]) async throws {
        try await api.patch("/transactions/\(id)", body: fields)
    }
}
