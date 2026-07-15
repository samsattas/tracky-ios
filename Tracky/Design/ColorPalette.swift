import SwiftUI

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - App Colors

struct AppColors {
    let bg:            Color
    let surface:       Color
    let surface2:      Color
    let surface3:      Color
    let border:        Color
    let borderStrong:  Color
    let text:          Color
    let textMuted:     Color
    let textSubtle:    Color

    let primary:       Color
    let primaryFg:     Color
    let primarySoft:   Color
    let primaryInk:    Color

    let income:        Color
    let incomeSoft:    Color
    let incomeInk:     Color

    let expense:       Color
    let expenseSoft:   Color
    let expenseInk:    Color

    let warning:       Color
    let warningSoft:   Color
    let warningInk:    Color

    let info:          Color
    let infoSoft:      Color

    let premium:       Color
    let premiumSoft:   Color

    static let light = AppColors(
        bg:           Color(hex: "#f7fbfc"),
        surface:      Color(hex: "#ffffff"),
        surface2:     Color(hex: "#f2f6f7"),
        surface3:     Color(hex: "#e7ecee"),
        border:       Color(hex: "#dde2e4"),
        borderStrong: Color(hex: "#cacfd0"),
        text:         Color(hex: "#161b20"),
        textMuted:    Color(hex: "#636a71"),
        textSubtle:   Color(hex: "#9399a0"),
        primary:      Color(hex: "#009f89"),
        primaryFg:    Color(hex: "#ffffff"),
        primarySoft:  Color(hex: "#d3f8ef"),
        primaryInk:   Color(hex: "#005144"),
        income:       Color(hex: "#0ea053"),
        incomeSoft:   Color(hex: "#d7f9de"),
        incomeInk:    Color(hex: "#005827"),
        expense:      Color(hex: "#e64343"),
        expenseSoft:  Color(hex: "#ffe2de"),
        expenseInk:   Color(hex: "#8d1a1e"),
        warning:      Color(hex: "#ecaa0b"),
        warningSoft:  Color(hex: "#ffefcd"),
        warningInk:   Color(hex: "#7a4a00"),
        info:         Color(hex: "#168dd9"),
        infoSoft:     Color(hex: "#d9f2ff"),
        premium:      Color(hex: "#7c54cd"),
        premiumSoft:  Color(hex: "#f0e9ff")
    )

    static let dark = AppColors(
        bg:           Color(hex: "#0b1015"),
        surface:      Color(hex: "#13191f"),
        surface2:     Color(hex: "#1a2026"),
        surface3:     Color(hex: "#242a30"),
        border:       Color(hex: "#292e35"),
        borderStrong: Color(hex: "#3d434a"),
        text:         Color(hex: "#eef3f4"),
        textMuted:    Color(hex: "#9fa5ac"),
        textSubtle:   Color(hex: "#6c7278"),
        primary:      Color(hex: "#00c0a8"),
        primaryFg:    Color(hex: "#001712"),
        primarySoft:  Color(hex: "#003a2f"),
        primaryInk:   Color(hex: "#7ee3d0"),
        income:       Color(hex: "#24c369"),
        incomeSoft:   Color(hex: "#033216"),
        incomeInk:    Color(hex: "#81e8a0"),
        expense:      Color(hex: "#ff5f5b"),
        expenseSoft:  Color(hex: "#521615"),
        expenseInk:   Color(hex: "#ffa89f"),
        warning:      Color(hex: "#fdb500"),
        warningSoft:  Color(hex: "#422800"),
        warningInk:   Color(hex: "#ffdc84"),
        info:         Color(hex: "#43acfb"),
        infoSoft:     Color(hex: "#002b49"),
        premium:      Color(hex: "#b697ff"),
        premiumSoft:  Color(hex: "#2c2047")
    )
}

// MARK: - Environment Key

private struct AppColorsKey: EnvironmentKey {
    static let defaultValue: AppColors = .light
}

extension EnvironmentValues {
    var colors: AppColors {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
}

// MARK: - Radii

enum Radii {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 22
    static let full: CGFloat = 999
}
