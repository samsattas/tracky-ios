import Foundation
import SwiftUI

@MainActor
final class AccountStore: ObservableObject {
    @Published var items:   [Account] = []
    @Published var loading: Bool = false
    @Published var error:   String? = nil

    var creditAccounts: [Account] { items.filter { $0.isCredit } }
    var debitAccounts:  [Account] { items.filter { !$0.isCredit } }
    var totalBalance:   Double    { debitAccounts.reduce(0) { $0 + $1.balance } }
    var totalUsed:      Double    { creditAccounts.reduce(0) { $0 + $1.balance } }

    func load() async {
        loading = true; error = nil
        do { items = try await AccountService.shared.fetchAccounts() }
        catch { self.error = error.localizedDescription }
        loading = false
    }

    func updateAlias(id: String, alias: String) async {
        do {
            try await AccountService.shared.updateAlias(id: id, alias: alias)
            if let idx = items.firstIndex(where: { $0.id == id }) { items[idx].alias = alias }
        } catch { self.error = error.localizedDescription }
    }

    func delete(id: String) async {
        do {
            try await AccountService.shared.delete(id: id)
            items.removeAll { $0.id == id }
        } catch { self.error = error.localizedDescription }
    }
}
