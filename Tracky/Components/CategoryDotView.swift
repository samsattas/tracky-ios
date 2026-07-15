import SwiftUI

struct CategoryDotView: View {
    let id: String?
    var size: CGFloat = 36

    private var colors: CategoryColors {
        guard let id = id else {
            return CategoryColors(bg: Color(hex: "#f0f3f8"), fg: Color(hex: "#5060a0"), dot: Color(hex: "#7080c8"))
        }
        return id.categoryColors
    }

    private var icon: String {
        guard let id = id, let catId = CategoryId(rawValue: id) else { return "tag.fill" }
        return catId.meta.icon
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28)
                .fill(colors.bg)
            Image(systemName: icon)
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundColor(colors.fg)
        }
        .frame(width: size, height: size)
    }
}
