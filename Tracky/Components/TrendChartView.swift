import SwiftUI

struct TrendChartView: View {
    let data: [TrendPoint]

    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    private var maxVal: Double {
        data.flatMap { [$0.income, $0.expense] }.max() ?? 1
    }

    var body: some View {
        GeometryReader { geo in
            let barW = (geo.size.width - CGFloat(data.count - 1) * 6) / CGFloat(data.count * 2 + max(0, data.count - 1))
            let groupW = barW * 2 + 4
            let chartH = geo.size.height - 24

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(data.enumerated()), id: \.offset) { i, point in
                    VStack(spacing: 0) {
                        HStack(alignment: .bottom, spacing: 2) {
                            // Income bar
                            bar(value: point.income, maxVal: maxVal, height: chartH, color: C.income, barW: barW)
                            // Expense bar
                            bar(value: point.expense, maxVal: maxVal, height: chartH, color: C.expense, barW: barW)
                        }
                        Text(point.month)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(C.textMuted)
                            .padding(.top, 4)
                            .frame(height: 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 120)
    }

    private func bar(value: Double, maxVal: Double, height: CGFloat, color: Color, barW: CGFloat) -> some View {
        let h = maxVal > 0 ? CGFloat(value / maxVal) * height : 0
        return RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: barW, height: max(3, h))
    }
}
