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

    // MARK: - Dashboard analytics (computed from real history)

    // Matches ISO dates ("yyyy-MM-dd" or full timestamps) by their "yyyy-MM" prefix
    private static let monthKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f
    }()

    private var currentMonthKey: String { Self.monthKeyFormatter.string(from: Date()) }

    var monthItems: [ConfirmedTransaction] { items.filter { $0.date.hasPrefix(currentMonthKey) } }

    // Current-month figures for the hero "Balance del mes" card
    var monthIncome:   Double { monthItems.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount } }
    var monthExpenses: Double { monthItems.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) } }
    var monthBalance:  Double { monthIncome - monthExpenses }

    // Current-month expense share per category, sorted descending
    var catShare: [CatShare] {
        let expenseItems = monthItems.filter { $0.amount < 0 }
        let total = expenseItems.reduce(0) { $0 + abs($1.amount) }
        guard total > 0 else { return [] }
        let byCategory = Dictionary(grouping: expenseItems) { $0.category ?? "other" }
        return byCategory
            .map { cat, txs in
                let sum = txs.reduce(0) { $0 + abs($1.amount) }
                let hex = CategoryId(rawValue: cat)?.dotHex ?? "#7080c8"
                return CatShare(id: cat, value: sum / total, color: hex)
            }
            .sorted { $0.value > $1.value }
    }

    // Income vs expenses for the last 6 months (oldest first)
    var trend: [TrendPoint] {
        let labelFormatter = DateFormatter()
        labelFormatter.locale = Locale(identifier: "es_CO")
        labelFormatter.dateFormat = "MMM"
        let calendar = Calendar.current
        return (0..<6).reversed().compactMap { monthsBack in
            guard let date = calendar.date(byAdding: .month, value: -monthsBack, to: Date()) else { return nil }
            let key = Self.monthKeyFormatter.string(from: date)
            let monthTxs = items.filter { $0.date.hasPrefix(key) }
            let label = labelFormatter.string(from: date)
                .replacingOccurrences(of: ".", with: "")
                .capitalized
            return TrendPoint(
                month: label,
                income: monthTxs.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount },
                expense: monthTxs.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
            )
        }
    }

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
