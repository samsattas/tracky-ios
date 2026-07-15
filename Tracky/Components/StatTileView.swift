import SwiftUI

struct StatTileView: View {
    let label: String
    let value: String
    let tone: TileTone
    let icon: String       // SF Symbol

    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    enum TileTone { case income, expense, primary }

    private var toneColor: Color {
        switch tone {
        case .income:  return C.income
        case .expense: return C.expense
        case .primary: return C.primary
        }
    }
    private var toneSoft: Color {
        switch tone {
        case .income:  return C.incomeSoft
        case .expense: return C.expenseSoft
        case .primary: return C.primarySoft
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(toneSoft)
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(toneColor)
                }
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(C.textMuted)
            }
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .tracking(-0.3)
                .foregroundColor(C.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Radii.lg)
                .stroke(C.border, lineWidth: 1)
        )
    }
}
