import SwiftUI

struct EmptyStateView: View {
    let icon: String          // SF Symbol name
    let title: String
    let subtitle: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil
    var accent: EmptyAccent = .primary

    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    enum EmptyAccent { case primary, info, income }

    private var accentColor: Color {
        switch accent {
        case .primary: return C.primary
        case .info:    return C.info
        case .income:  return C.income
        }
    }
    private var accentSoft: Color {
        switch accent {
        case .primary: return C.primarySoft
        case .info:    return C.infoSoft
        case .income:  return C.incomeSoft
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(accentSoft)
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(accentColor)
            }
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(C.text)
            Text(subtitle)
                .font(.system(size: 13.5))
                .foregroundColor(C.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            if let action, let onAction {
                Button(action: onAction) {
                    Text(action)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: Radii.md)
                                .fill(accentSoft)
                        )
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
