import Foundation
import SwiftUI

@MainActor
final class HistoryStore: ObservableObject {
    @Published var items:   [ConfirmedTransaction] = []
    @Published var loading: Bool = false
    @Published var error:   String? = nil

    // Summary computed for Dashboard
    var income:   Double { items.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount } }
    var expenses: Double { items.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) } }
    var balance:  Double { income - expenses }

    func load(from: String? = nil, to: String? = nil, category: String? = nil, bank: String? = nil) async {
        loading = true; error = nil
        do { items = try await TransactionService.shared.fetchHistory(from: from, to: to, category: category, bank: bank) }
        catch { self.error = error.localizedDescription }
        loading = false
    }

    func delete(id: String) async {
        do {
            try await TransactionService.shared.delete(id: id)
            items.removeAll { $0.id == id }
        } catch { self.error = error.localizedDescription }
    }

    func deleteAll(_ ids: Set<String>) async {
        await withTaskGroup(of: Void.self) { group in
            for id in ids { group.addTask { await self.delete(id: id) } }
        }
    }
}
