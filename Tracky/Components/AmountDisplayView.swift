import SwiftUI

struct AmountDisplayView: View {
    let value: Double
    var color: Color = .primary
    var large: Bool = false

    private var formatted: String { fmtCOP(value) }
    private var fontSize: CGFloat { large ? 34 : 22 }

    var body: some View {
        Text(formatted)
            .font(.system(size: fontSize, weight: .bold, design: .default))
            .tracking(-0.5)
            .foregroundColor(color)
    }
}
