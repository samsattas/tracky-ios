import SwiftUI

struct HistoryDetailView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var historyStore: HistoryStore
    private var C: AppColors { scheme == .dark ? .dark : .light }

    let tx: ConfirmedTransaction
    @State private var showRaw = false
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBarView(
                    title: "Detalle",
                    leading: AnyView(
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(C.text)
                                .frame(width: 36, height: 36)
                                .background(C.surface2)
                                .cornerRadius(18)
                        }
                    ),
                    trailing: AnyView(
                        Button(action: { showDeleteConfirm = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(C.expense)
                                .frame(width: 36, height: 36)
                                .background(C.expenseSoft)
                                .cornerRadius(18)
                        }
                    )
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        // Amount hero
                        VStack(spacing: 4) {
                            if let catId = tx.category.flatMap({ CategoryId(rawValue: $0) }) {
                                CategoryDotView(id: catId.rawValue, size: 44)
                                    .padding(.bottom, 4)
                            }
                            Text(tx.amount < 0 ? "GASTO" : "INGRESO")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundColor(tx.amount < 0 ? C.expenseInk : C.incomeInk)
                                .tracking(1)
                            Text(fmtCOP(abs(tx.amount)))
                                .font(.system(size: 36, weight: .heavy))
                                .tracking(-0.8)
                                .foregroundColor(tx.amount < 0 ? C.expense : C.income)
                            Text(tx.merchant)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(C.text)
                            Text(fmtDate(tx.date))
                                .font(.system(size: 12)).foregroundColor(C.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(tx.amount < 0 ? C.expenseSoft : C.incomeSoft)
                        .cornerRadius(Radii.xl)
                        .overlay(RoundedRectangle(cornerRadius: Radii.xl).stroke(tx.amount < 0 ? C.expense.opacity(0.25) : C.income.opacity(0.25), lineWidth: 1))

                        // Details card
                        VStack(spacing: 0) {
                            detailRow("Banco", value: tx.bank.meta.name)
                            if let cat = tx.category {
                                Divider()
                                detailRow("Categoría", value: CategoryId(rawValue: cat)?.meta.name ?? cat)
                            }
                            if let notes = tx.notes, !notes.isEmpty {
                                Divider()
                                detailRow("Notas", value: notes)
                            }
                        }
                        .background(C.surface)
                        .cornerRadius(Radii.lg)
                        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))

                        // Raw notification collapsible (only available if notes exist)
                        if let notes = tx.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: { withAnimation { showRaw.toggle() } }) {
                                    HStack {
                                        Image(systemName: showRaw ? "chevron.down" : "chevron.right")
                                            .font(.system(size: 10)).foregroundColor(C.textMuted)
                                        Text("Notas")
                                            .font(.system(size: 12, weight: .semibold)).foregroundColor(C.textMuted)
                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)

                                if showRaw {
                                    Text(notes)
                                        .font(.system(size: 11.5))
                                        .foregroundColor(C.text)
                                        .padding(10)
                                        .background(C.surface2)
                                        .cornerRadius(10)
                                        .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                                }
                            }
                            .padding(14)
                            .background(C.surface)
                            .cornerRadius(Radii.lg)
                            .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(16)
                }
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
            .alert("Eliminar transacción", isPresented: $showDeleteConfirm) {
                Button("Eliminar", role: .destructive) {
                    Task { await historyStore.delete(id: tx.id) }
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Eliminar esta transacción? Esta acción no se puede deshacer.")
            }
        }
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13.5)).foregroundColor(C.textMuted)
            Spacer()
            Text(value).font(.system(size: 13.5, weight: .semibold)).foregroundColor(C.text)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
    }
}
