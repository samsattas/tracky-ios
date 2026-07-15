import SwiftUI

struct PendingCardView: View {
    let tx: PendingTransaction
    var selected: Bool = false
    var selectionMode: Bool = false
    var onPress: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    var onSelect: (() -> Void)? = nil
    var onApprove: ((String) -> Void)? = nil
    var onDiscard: ((String) -> Void)? = nil

    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var offsetX: CGFloat = 0
    @State private var isDragging: Bool = false

    private let THRESHOLD: CGFloat = 80
    private var b: BankMeta { tx.bank.meta }

    private var approveOpacity: Double {
        selectionMode ? 0 : Double(max(0, min(1, offsetX / THRESHOLD)))
    }
    private var discardOpacity: Double {
        selectionMode ? 0 : Double(max(0, min(1, -offsetX / THRESHOLD)))
    }

    var body: some View {
        ZStack {
            // Approve background
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(C.income)
                    Text("Aprobar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(C.incomeInk)
                }
                .padding(.leading, 24)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(C.incomeSoft)
            .opacity(approveOpacity)

            // Discard background
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Text("Descartar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(C.expenseInk)
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(C.expense)
                }
                .padding(.trailing, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(C.expenseSoft)
            .opacity(discardOpacity)

            // Card
            cardBody
                .offset(x: selectionMode ? 0 : offsetX)
                .gesture(
                    selectionMode ? nil : DragGesture()
                        .onChanged { value in
                            offsetX = value.translation.width
                            isDragging = true
                        }
                        .onEnded { value in
                            isDragging = false
                            if value.translation.width > THRESHOLD {
                                withAnimation(.spring(response: 0.3)) { offsetX = 400 }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    onApprove?(tx.id)
                                }
                            } else if value.translation.width < -THRESHOLD {
                                withAnimation(.spring(response: 0.3)) { offsetX = -400 }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    onDiscard?(tx.id)
                                }
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    offsetX = 0
                                }
                            }
                        }
                )
        }
        .cornerRadius(Radii.lg)
        .clipped()
    }

    private var cardBody: some View {
        Button(action: {
            if selectionMode { onSelect?() } else { onPress?() }
        }) {
            HStack(alignment: .top, spacing: 12) {
                // Checkbox in selection mode
                if selectionMode {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(selected ? C.primary : C.borderStrong, lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                        if selected {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(C.primary)
                                .frame(width: 22, height: 22)
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 4)
                }

                BankBadgeView(bank: tx.bank, size: 38)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(tx.merchant)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(C.text)
                            .lineLimit(1)
                        Spacer()
                        Text(fmtCOP(tx.amount))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(C.text)
                    }
                    HStack(spacing: 4) {
                        Text(b.name)
                            .font(.system(size: 11.5))
                            .foregroundColor(C.textMuted)
                        Text("·")
                            .font(.system(size: 11))
                            .foregroundColor(C.textSubtle.opacity(0.5))
                        let isCredit = tx.accountType == .credit
                        Text("\(isCredit ? "CRÉD" : "DÉB")\(tx.last4.map { l in l != "0000" ? " •••\(l)" : "" } ?? "")")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(isCredit ? C.premium : C.info)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isCredit ? C.premiumSoft : C.infoSoft)
                            )
                        Text("·")
                            .font(.system(size: 11))
                            .foregroundColor(C.textSubtle.opacity(0.5))
                        Text(fmtDate(tx.date))
                            .font(.system(size: 11.5))
                            .foregroundColor(C.textMuted)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(14)
            .background(selected ? C.primarySoft : C.surface)
            .cornerRadius(Radii.lg)
            .overlay(
                RoundedRectangle(cornerRadius: Radii.lg)
                    .stroke(selected ? C.primary : C.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.4) { onLongPress?() }
    }
}
