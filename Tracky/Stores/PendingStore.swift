import Foundation
import SwiftUI

@MainActor
final class PendingStore: ObservableObject {
    @Published var items:   [PendingTransaction] = []
    @Published var loading: Bool = false
    @Published var error:   String? = nil

    var count: Int { items.count }

    func load() async {
        loading = true; error = nil
        do { items = try await TransactionService.shared.fetchPending() }
        catch { self.error = error.localizedDescription }
        loading = false
    }

    func approve(id: String, category: String? = nil, merchant: String? = nil, notes: String? = nil) async {
        do {
            try await TransactionService.shared.approve(id: id, category: category, merchant: merchant, notes: notes)
            items.removeAll { $0.id == id }
        } catch { self.error = error.localizedDescription }
    }

    func discard(id: String) async {
        do {
            try await TransactionService.shared.discard(id: id)
            items.removeAll { $0.id == id }
        } catch { self.error = error.localizedDescription }
    }

    func approveAll(_ ids: Set<String>) async {
        await withTaskGroup(of: Void.self) { group in
            for id in ids { group.addTask { await self.approve(id: id) } }
        }
    }

    func discardAll(_ ids: Set<String>) async {
        await withTaskGroup(of: Void.self) { group in
            for id in ids { group.addTask { await self.discard(id: id) } }
        }
    }

    // Local-only helpers (for immediate UI feedback before API confirms)
    func remove(id: String)          { items.removeAll { $0.id == id } }
    func removeAll(_ ids: Set<String>) { items.removeAll { ids.contains($0.id) } }
}
