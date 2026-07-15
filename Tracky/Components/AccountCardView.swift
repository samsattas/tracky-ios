import SwiftUI

struct AccountCardView: View {
    let account: Account
    var compact: Bool = false
    var onPress: (() -> Void)? = nil

    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    private var b: BankMeta { account.bank.meta }
    private var usedPct: Double { account.usedPercent }

    private var barColor: Color {
        usedPct > 80 ? C.expense :
        usedPct > 50 ? C.warning :
        C.primary
    }

    var body: some View {
        let content = cardContent
        if let onPress = onPress {
            Button(action: onPress) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var cardContent: some View {
        ZStack(alignment: .topTrailing) {
            // Swatch
            Circle()
                .fill(b.swiftColor.opacity(0.08))
                .frame(width: 100, height: 100)
                .offset(x: 30, y: -30)

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 10) {
                    BankBadgeView(bank: account.bank, size: compact ? 32 : 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.alias)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(C.text)
                            .lineLimit(1)
                        HStack(spacing: 6) {
                            Text(account.isCredit ? "CRÉDITO" : account.type == .savings ? "AHORROS" : "DÉBITO")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(account.isCredit ? C.text : C.incomeInk)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(account.isCredit ? C.surface3 : C.incomeSoft)
                                )
                            if let last4 = account.last4 {
                                Text("•••• \(last4)")
                                    .font(.system(size: 11))
                                    .foregroundColor(C.textMuted)
                            }
                        }
                    }
                    Spacer()
                }

                // Balance row
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.isCredit ? "Disponible" : "Saldo")
                            .font(.system(size: 10.5, weight: .semibold))
                            .foregroundColor(C.textMuted)
                            .textCase(.uppercase)
                        Text(fmtCOP(account.available))
                            .font(.system(size: compact ? 17 : 20, weight: .bold))
                            .tracking(-0.4)
                            .foregroundColor(C.text)
                    }
                    Spacer()
                    if account.isCredit {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Corte")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundColor(C.textMuted)
                            Text(account.cutDay.map { "Día \($0)" } ?? "—")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(C.text)
                        }
                    }
                }
                .padding(.top, 14)

                // Credit bar
                if account.isCredit {
                    VStack(alignment: .leading, spacing: 5) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 999)
                                    .fill(C.surface3)
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 999)
                                    .fill(barColor)
                                    .frame(width: geo.size.width * CGFloat(usedPct / 100), height: 6)
                            }
                        }
                        .frame(height: 6)

                        HStack {
                            Text("\(fmtCOP(account.balance)) usados")
                                .font(.system(size: 11))
                                .foregroundColor(C.textMuted)
                            Spacer()
                            Text("cupo \(fmtCOP(account.limit ?? 0))")
                                .font(.system(size: 11))
                                .foregroundColor(C.textMuted)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .padding(compact ? 14 : 16)
        }
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Radii.lg)
                .stroke(C.border, lineWidth: 1)
        )
        .clipped()
    }
}
