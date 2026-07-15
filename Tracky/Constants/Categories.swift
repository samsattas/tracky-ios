import SwiftUI

// MARK: - Category ID

enum CategoryId: String, Codable, CaseIterable {
    case food
    case groceries
    case transport
    case shopping
    case bills
    case health
    case income
    case fun
    case home
    case other
    case subs
    case travel
    case fees
    case gifts
}

// MARK: - Category Metadata

struct CategoryMeta {
    let name: String
    let hue: Double
    let icon: String
}

// MARK: - Categories Registry

let CATEGORIES: [CategoryId: CategoryMeta] = [
    .food:      CategoryMeta(name: "Comida",        hue: 25,  icon: "cup.and.saucer.fill"),
    .groceries: CategoryMeta(name: "Mercado",       hue: 145, icon: "bag.fill"),
    .transport: CategoryMeta(name: "Transporte",    hue: 245, icon: "car.fill"),
    .shopping:  CategoryMeta(name: "Compras",       hue: 295, icon: "bag.fill"),
    .bills:     CategoryMeta(name: "Servicios",     hue: 200, icon: "bolt.fill"),
    .health:    CategoryMeta(name: "Salud",         hue: 5,   icon: "heart.fill"),
    .income:    CategoryMeta(name: "Ingresos",      hue: 152, icon: "chart.line.uptrend.xyaxis"),
    .fun:       CategoryMeta(name: "Ocio",          hue: 320, icon: "gamecontroller.fill"),
    .home:      CategoryMeta(name: "Hogar",         hue: 50,  icon: "house.fill"),
    .other:     CategoryMeta(name: "Otros",         hue: 220, icon: "tag.fill"),
    .subs:      CategoryMeta(name: "Suscripciones", hue: 270, icon: "arrow.clockwise"),
    .travel:    CategoryMeta(name: "Viajes",        hue: 180, icon: "globe"),
    .fees:      CategoryMeta(name: "Comisiones",    hue: 0,   icon: "doc.text.fill"),
    .gifts:     CategoryMeta(name: "Regalos",       hue: 340, icon: "gift.fill"),
]

// MARK: - Hue → Color

struct CategoryColors {
    let bg: Color
    let fg: Color
    let dot: Color
}

private let hueColorMap: [Double: (bg: String, fg: String, dot: String)] = [
    25:  (bg: "#fdeee6", fg: "#a03a10", dot: "#e07030"),
    145: (bg: "#e4f7ee", fg: "#1a7a42", dot: "#28a858"),
    245: (bg: "#e6f0fa", fg: "#1e50b0", dot: "#3878d4"),
    295: (bg: "#f2eafe", fg: "#6630b8", dot: "#9058e8"),
    200: (bg: "#e6f5fa", fg: "#1a6888", dot: "#2898c4"),
    5:   (bg: "#fdeae6", fg: "#a02010", dot: "#e03828"),
    152: (bg: "#e4f7ee", fg: "#1a7a42", dot: "#28a858"),
    320: (bg: "#fde8f4", fg: "#981068", dot: "#d838a0"),
    50:  (bg: "#fdf5e4", fg: "#8a6010", dot: "#c89820"),
    220: (bg: "#e6ecfa", fg: "#3048a0", dot: "#5068d8"),
    270: (bg: "#eeecfe", fg: "#5030c0", dot: "#7860e8"),
    180: (bg: "#e4f5f5", fg: "#1a7878", dot: "#28aaaa"),
    0:   (bg: "#fde8e8", fg: "#a01818", dot: "#e03030"),
    340: (bg: "#fde6f0", fg: "#981048", dot: "#d83880"),
]

func hueToColor(_ hue: Double) -> CategoryColors {
    if let c = hueColorMap[hue] {
        return CategoryColors(bg: Color(hex: c.bg), fg: Color(hex: c.fg), dot: Color(hex: c.dot))
    }
    return CategoryColors(bg: Color(hex: "#f0f3f8"), fg: Color(hex: "#5060a0"), dot: Color(hex: "#7080c8"))
}

extension CategoryId {
    var meta: CategoryMeta { CATEGORIES[self] ?? CategoryMeta(name: rawValue, hue: 220, icon: "tag.fill") }
    var colors: CategoryColors { hueToColor(meta.hue) }
    var dotColor: Color { colors.dot }
}

extension String {
    var asCategoryId: CategoryId? { CategoryId(rawValue: self) }
    var categoryColors: CategoryColors {
        guard let id = CategoryId(rawValue: self) else {
            return CategoryColors(bg: Color(hex: "#f0f3f8"), fg: Color(hex: "#5060a0"), dot: Color(hex: "#7080c8"))
        }
        return id.colors
    }
    var categoryName: String { CategoryId(rawValue: self)?.meta.name ?? self }
}
