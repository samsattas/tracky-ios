import SwiftUI

struct CategoryChipView: View {
    let id: String
    var selected: Bool = false
    var size: ChipSize = .md
    var customName: String? = nil
    var customHue: Double? = nil
    var onPress: (() -> Void)? = nil

    enum ChipSize { case sm, md }

    private var meta: CategoryMeta? { CategoryId(rawValue: id)?.meta }
    private var name: String { customName ?? meta?.name ?? id }
    private var hue: Double { customHue ?? meta?.hue ?? 220 }
    private var colors: CategoryColors { hueToColor(hue) }

    var body: some View {
        let h: CGFloat = size == .sm ? 26 : 30
        let fontSize: CGFloat = size == .sm ? 11 : 12
        let hPad: CGFloat = size == .sm ? 10 : 12

        Button(action: { onPress?() }) {
            HStack(spacing: 4) {
                Circle()
                    .fill(colors.dot)
                    .frame(width: 6, height: 6)
                Text(name)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(selected ? colors.fg : Color(hex: "#636a71"))
            }
            .padding(.horizontal, hPad)
            .frame(height: h)
            .background(
                RoundedRectangle(cornerRadius: Radii.full)
                    .fill(selected ? colors.bg : Color(hex: "#f2f6f7"))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radii.full)
                            .stroke(selected ? colors.dot.opacity(0.5) : Color(hex: "#dde2e4"), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
