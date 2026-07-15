import Foundation

// MARK: - Mock Pending Transactions

let MOCK_PENDING: [PendingTransaction] = [
    PendingTransaction(id: "p1", bank: .bogota,      accountType: .credit,  last4: "3243", merchant: "AliExpress",    amount: 58201,  date: "2026-05-21", category: "shopping", raw: "Banco de Bogota: Tu compra por 58,201 fue aprobada con Tarjeta Crédito 3243 el 21/05/26 14:21:54 en aliexpress"),
    PendingTransaction(id: "p2", bank: .bancolombia, accountType: .debit,   last4: "4471", merchant: "Rappi",         amount: 32400,  date: "2026-05-21", category: "food",     raw: "Bancolombia: Compra Debito $32.400 en RAPPI COL 21/05 12:45"),
    PendingTransaction(id: "p3", bank: .davivienda,  accountType: .credit,  last4: "8821", merchant: "Éxito",         amount: 184500, date: "2026-05-20", category: "groceries",raw: "Davivienda alerta: Compra de 184,500 COP en EXITO con T. Credito 8821 el 20/05/2026"),
    PendingTransaction(id: "p4", bank: .nequi,       accountType: .debit,   last4: "NEQ",  merchant: "Transferencia", amount: 250000, date: "2026-05-20", category: "income",   raw: "Nequi: Recibiste $250,000 de JUAN P MARTINEZ. Tu saldo es de $812,450"),
    PendingTransaction(id: "p5", bank: .bbva,        accountType: .credit,  last4: "0119", merchant: "Netflix",       amount: 38900,  date: "2026-05-19", category: "subs",     raw: "BBVA: Cargo recurrente NETFLIX.COM 38,900 COP TC*0119 19/05"),
    PendingTransaction(id: "p6", bank: .daviplata,   accountType: .debit,   last4: "DPL",  merchant: "Uber",          amount: 14300,  date: "2026-05-19", category: "transport",raw: "Daviplata: Pago a UBER.COM $14.300 19/05"),
    PendingTransaction(id: "p7", bank: .scotia,      accountType: .credit,  last4: "5530", merchant: "Farmatodo",     amount: 27650,  date: "2026-05-18", category: "health",   raw: "Scotiabank Colpatria: Compra TC*5530 27,650 FARMATODO 18/05 16:12"),
]

// MARK: - Mock Confirmed Transactions

let MOCK_HISTORY: [ConfirmedTransaction] = [
    ConfirmedTransaction(id: "h1",  bank: .bogota,      last4: "3243", merchant: "Cine Colombia",    amount: -28000,   date: "2026-05-17", category: "fun"),
    ConfirmedTransaction(id: "h2",  bank: .bancolombia, last4: "4471", merchant: "Nómina Mayo",      amount: 3450000,  date: "2026-05-15", category: "income"),
    ConfirmedTransaction(id: "h3",  bank: .davivienda,  last4: "8821", merchant: "Justo & Bueno",    amount: -42600,   date: "2026-05-15", category: "groceries"),
    ConfirmedTransaction(id: "h4",  bank: .nequi,       last4: "NEQ",  merchant: "Domicilio Wok",    amount: -45200,   date: "2026-05-14", category: "food"),
    ConfirmedTransaction(id: "h5",  bank: .bbva,        last4: "0119", merchant: "Spotify",          amount: -16900,   date: "2026-05-13", category: "subs"),
    ConfirmedTransaction(id: "h6",  bank: .bogota,      last4: "3243", merchant: "Carulla",          amount: -132400,  date: "2026-05-12", category: "groceries"),
    ConfirmedTransaction(id: "h7",  bank: .daviplata,   last4: "DPL",  merchant: "TransMilenio",     amount: -3200,    date: "2026-05-12", category: "transport"),
    ConfirmedTransaction(id: "h8",  bank: .scotia,      last4: "5530", merchant: "D1",               amount: -28900,   date: "2026-05-11", category: "groceries"),
    ConfirmedTransaction(id: "h9",  bank: .bancolombia, last4: "4471", merchant: "Café Juan Valdez", amount: -7800,    date: "2026-05-11", category: "food"),
    ConfirmedTransaction(id: "h10", bank: .bogota,      last4: "3243", merchant: "Claro",            amount: -89000,   date: "2026-05-10", category: "bills"),
]

// MARK: - Mock Accounts

let MOCK_ACCOUNTS: [Account] = [
    Account(id: "a1", bank: .bogota,      alias: "Bogotá Platinum",    type: .credit,  last4: "3243", balance: 3160000, limit: 5000000, cutDay: 28),
    Account(id: "a2", bank: .bancolombia, alias: "Cuenta Ahorros",     type: .debit,   last4: "4471", balance: 2840600, limit: nil,      cutDay: nil),
    Account(id: "a3", bank: .davivienda,  alias: "Dav Visa Signature", type: .credit,  last4: "8821", balance: 7280000, limit: 8000000,  cutDay: 12),
    Account(id: "a4", bank: .nequi,       alias: "Nequi",              type: .debit,   last4: "NEQ",  balance: 412500,  limit: nil,      cutDay: nil),
    Account(id: "a5", bank: .bbva,        alias: "BBVA Mastercard",    type: .credit,  last4: "0119", balance: 880000,  limit: 4000000,  cutDay: 3),
    Account(id: "a6", bank: .daviplata,   alias: "Daviplata",          type: .debit,   last4: "DPL",  balance: 84200,   limit: nil,      cutDay: nil),
]

// MARK: - Mock Top Merchants

let MOCK_MERCHANTS: [MerchantStat] = [
    MerchantStat(name: "Carulla",       amount: 542300, count: 6,  category: "groceries"),
    MerchantStat(name: "Rappi",         amount: 318900, count: 11, category: "food"),
    MerchantStat(name: "Uber",          amount: 184500, count: 23, category: "transport"),
    MerchantStat(name: "Netflix",       amount: 38900,  count: 1,  category: "subs"),
    MerchantStat(name: "Cine Colombia", amount: 56000,  count: 2,  category: "fun"),
]

// MARK: - Mock Category Distribution

let MOCK_CAT_SHARE: [CatShare] = [
    CatShare(id: "groceries", value: 0.28, color: "#28a858"),
    CatShare(id: "food",      value: 0.21, color: "#e07030"),
    CatShare(id: "transport", value: 0.12, color: "#3878d4"),
    CatShare(id: "subs",      value: 0.09, color: "#7860e8"),
    CatShare(id: "shopping",  value: 0.11, color: "#9058e8"),
    CatShare(id: "bills",     value: 0.08, color: "#2898c4"),
    CatShare(id: "fun",       value: 0.06, color: "#d838a0"),
    CatShare(id: "health",    value: 0.05, color: "#e03828"),
]

// MARK: - Mock Trend Data

let MOCK_TREND: [TrendPoint] = [
    TrendPoint(month: "Dic", income: 3200, expense: 2400),
    TrendPoint(month: "Ene", income: 3450, expense: 2900),
    TrendPoint(month: "Feb", income: 3450, expense: 2750),
    TrendPoint(month: "Mar", income: 3450, expense: 3100),
    TrendPoint(month: "Abr", income: 3450, expense: 2680),
    TrendPoint(month: "May", income: 3450, expense: 2980),
]

// MARK: - Mock Rules

let MOCK_RULES: [Rule] = [
    Rule(id: "r1", match: "rappi",   category: "food",      priority: 1, enabled: true),
    Rule(id: "r2", match: "uber",    category: "transport", priority: 2, enabled: true),
    Rule(id: "r3", match: "netflix", category: "subs",      priority: 3, enabled: true),
    Rule(id: "r4", match: "carulla", category: "groceries", priority: 4, enabled: true),
    Rule(id: "r5", match: "claro",   category: "bills",     priority: 5, enabled: false),
]
