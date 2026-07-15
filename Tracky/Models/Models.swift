import Foundation

// MARK: - Core Models

struct PendingTransaction: Identifiable, Codable {
    let id: String
    let bank: BankId
    let accountType: AccountType
    let last4: String?
    let merchant: String
    let amount: Double      // positive value (expense or income)
    let date: String        // ISO 8601 yyyy-MM-dd
    var category: String?
    let raw: String?
}

struct ConfirmedTransaction: Identifiable, Codable {
    let id: String
    let bank: BankId
    let last4: String?
    let merchant: String
    let amount: Double      // negative = expense, positive = income
    let date: String        // ISO 8601
    var category: String?
    var notes: String?
}

struct Account: Identifiable, Codable {
    let id: String
    let bank: BankId
    var alias: String
    let type: AccountType
    let last4: String?
    var balance: Double
    var limit: Double?
    var cutDay: Int?

    var isCredit: Bool { type == .credit }
    var available: Double {
        isCredit ? max(0, (limit ?? 0) - balance) : balance
    }
    var usedPercent: Double {
        guard isCredit, let lim = limit, lim > 0 else { return 0 }
        return min(100, (balance / lim) * 100)
    }
}

struct Rule: Identifiable, Codable {
    let id: String
    var match: String
    var category: String
    var priority: Int
    var enabled: Bool
}

struct UserCategory: Identifiable, Codable {
    let id: String
    var name: String
    var hue: Double
    var icon: String
}

// MARK: - Enums

enum AccountType: String, Codable, CaseIterable {
    case credit
    case debit
    case savings

    var displayName: String {
        switch self {
        case .credit:  return "Crédito"
        case .debit:   return "Débito"
        case .savings: return "Ahorros"
        }
    }
}

// MARK: - Chart Models

struct TrendPoint {
    let month: String
    let income: Double
    let expense: Double
}

struct CatShare {
    let id: String
    let value: Double
    let color: String
}

struct MerchantStat {
    let name: String
    let amount: Double
    let count: Int
    let category: String
}
