import Foundation
import SwiftUI

@MainActor
final class RulesStore: ObservableObject {
    @Published var items:   [Rule] = []
    @Published var loading: Bool = false
    @Published var error:   String? = nil

    func load() async {
        loading = true; error = nil
        do { items = try await CategoryService.shared.fetchRules() }
        catch { self.error = error.localizedDescription }
        loading = false
    }

    func create(match: String, category: String, priority: Int = 1) async {
        do {
            let rule = try await CategoryService.shared.createRule(match: match, category: category, priority: priority)
            items.append(rule)
        } catch { self.error = error.localizedDescription }
    }

    func toggle(id: String, enabled: Bool) async {
        if let idx = items.firstIndex(where: { $0.id == id }) { items[idx].enabled = enabled }
        do { try await CategoryService.shared.toggleRule(id: id, enabled: enabled) }
        catch {
            if let idx = items.firstIndex(where: { $0.id == id }) { items[idx].enabled = !enabled }
            self.error = error.localizedDescription
        }
    }

    func delete(id: String) async {
        do {
            try await CategoryService.shared.deleteRule(id: id)
            items.removeAll { $0.id == id }
        } catch { self.error = error.localizedDescription }
    }
}
