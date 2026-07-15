import SwiftUI

struct TransactionRowView: View {
    let tx: ConfirmedTransaction
    var showAccount: Bool = false
    var selected: Bool = false
    var selectionMode: Bool = false
    var onPress: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    var onSelect: (() -> Void)? = nil

    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    private var isIncome: Bool { tx.amount > 0 }

    var body: some View {
        Button(action: {
            if selectionMode { onSelect?() } else { onPress?() }
        }) {
            HStack(spacing: 12) {
                if selectionMode {
                    ZStack {
                        Circle()
                            .stroke(selected ? C.primary : C.borderStrong, lineWidth: 2)
                            .frame(width: 22, height: 22)
                        if selected {
                            Circle().fill(C.primary).frame(width: 22, height: 22)
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 22, height: 22)
                    .flexShrink()
                } else {
                    CategoryDotView(id: tx.category, size: 36)
                        .flexShrink()
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(tx.merchant)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundColor(C.text)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text(fmtDate(tx.date))
                            .font(.system(size: 11.5))
                            .foregroundColor(C.textMuted)
                        if showAccount {
                            Text("·")
                                .font(.system(size: 11))
                                .foregroundColor(C.textSubtle.opacity(0.5))
                            BankBadgeView(bank: tx.bank, size: 14)
                            if let last4 = tx.last4, last4 != "0000" {
                                Text("···\(last4)")
                                    .font(.system(size: 11.5))
                                    .foregroundColor(C.textMuted)
                            }
                        }
                    }
                }

                Spacer(minLength: 0)

                Text("\(isIncome ? "+ " : "− ")\(fmtCOP(tx.amount))")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(-0.2)
                    .foregroundColor(isIncome ? C.income : C.text)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(selected ? C.primarySoft : Color.clear)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.35) { onLongPress?() }
        Divider().padding(.leading, 14)
    }
}

// MARK: - FlexShrink Helper

extension View {
    func flexShrink() -> some View {
        self.fixedSize()
    }
}
