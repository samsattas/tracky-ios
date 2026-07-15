import SwiftUI

// MARK: - Bank ID

enum BankId: String, Codable, CaseIterable {
    case unknown
    case agrario
    case avvillas
    case bancolombia
    case bancoomeva
    case bbva
    case bogota
    case caja_social
    case cash
    case coopcentral
    case davivienda
    case daviplata
    case falabella
    case finandina
    case gnb
    case itau
    case lulo
    case mundo_mujer
    case nequi
    case nubank
    case occidente
    case pichincha
    case popular
    case rappipay
    case scotia
    case serfinansa
    case w
}

// MARK: - Bank Metadata

struct BankMeta {
    let short: String
    let name: String
    let color: String
    let fg: String

    var swiftColor: Color { Color(hex: color) }
    var swiftFg: Color { Color(hex: fg) }
}

// MARK: - Banks Registry

let BANKS: [BankId: BankMeta] = [
    // Bancos tradicionales grandes
    .bogota:      BankMeta(short: "BB", name: "Banco de Bogotá",      color: "#003893", fg: "#ffffff"),
    .bancolombia: BankMeta(short: "Bc", name: "Bancolombia",          color: "#D4A820", fg: "#3a2c00"),
    .davivienda:  BankMeta(short: "Dv", name: "Davivienda",           color: "#CC0000", fg: "#ffffff"),
    .bbva:        BankMeta(short: "BV", name: "BBVA",                  color: "#004481", fg: "#ffffff"),
    .scotia:      BankMeta(short: "Sc", name: "Scotiabank Colpatria", color: "#E02818", fg: "#ffffff"),
    .popular:     BankMeta(short: "Po", name: "Banco Popular",        color: "#004B9B", fg: "#ffffff"),
    .avvillas:    BankMeta(short: "AV", name: "AV Villas",            color: "#C8102E", fg: "#ffffff"),
    .caja_social: BankMeta(short: "CS", name: "Banco Caja Social",    color: "#003F87", fg: "#ffffff"),
    .gnb:         BankMeta(short: "GN", name: "GNB Sudameris",        color: "#003781", fg: "#ffffff"),
    .occidente:   BankMeta(short: "Oc", name: "Banco de Occidente",   color: "#004A97", fg: "#ffffff"),
    .agrario:     BankMeta(short: "Ag", name: "Banco Agrario",        color: "#009B3E", fg: "#ffffff"),
    // Bancos medianos
    .itau:        BankMeta(short: "It", name: "Banco Itaú",           color: "#FF6200", fg: "#ffffff"),
    .pichincha:   BankMeta(short: "Pi", name: "Banco Pichincha",      color: "#009A44", fg: "#ffffff"),
    .falabella:   BankMeta(short: "Fa", name: "Banco Falabella",      color: "#003A70", fg: "#ffffff"),
    .bancoomeva:  BankMeta(short: "Bm", name: "Bancoomeva",           color: "#006FBA", fg: "#ffffff"),
    .finandina:   BankMeta(short: "Fi", name: "Banco Finandina",      color: "#005B8E", fg: "#ffffff"),
    .w:           BankMeta(short: "W",  name: "Banco W",              color: "#E30613", fg: "#ffffff"),
    .mundo_mujer: BankMeta(short: "MM", name: "Banco Mundo Mujer",    color: "#E91E8C", fg: "#ffffff"),
    .serfinansa:  BankMeta(short: "Sf", name: "Serfinansa",           color: "#0062A8", fg: "#ffffff"),
    .coopcentral: BankMeta(short: "Cc", name: "Coopcentral",          color: "#007934", fg: "#ffffff"),
    // Digital / Fintech
    .nequi:       BankMeta(short: "Nq", name: "Nequi",                color: "#CC3A9F", fg: "#ffffff"),
    .daviplata:   BankMeta(short: "Dp", name: "Daviplata",            color: "#E04828", fg: "#ffffff"),
    .nubank:      BankMeta(short: "Nu", name: "Nu Colombia",           color: "#820AD1", fg: "#ffffff"),
    .lulo:        BankMeta(short: "Lu", name: "Lulo Bank",            color: "#FF5C00", fg: "#ffffff"),
    .rappipay:    BankMeta(short: "Rp", name: "Rappipay",             color: "#FF441F", fg: "#ffffff"),
    // Efectivo
    .cash:        BankMeta(short: "$",  name: "Efectivo",             color: "#22a05a", fg: "#ffffff"),
    // Sin banco
    .unknown:     BankMeta(short: "?",  name: "Sin cuenta",           color: "#9399a0", fg: "#ffffff"),
]

extension BankId {
    var meta: BankMeta { BANKS[self] ?? BANKS[.unknown]! }
}
