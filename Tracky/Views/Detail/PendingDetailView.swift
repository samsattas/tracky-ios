import SwiftUI

struct PendingDetailView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var pendingStore: PendingStore
    private var C: AppColors { scheme == .dark ? .dark : .light }

    let txId: String
    private var tx: PendingTransaction? { pendingStore.items.first(where: { $0.id == txId }) }

    @State private var merchant: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: String? = nil
    @State private var notes: String = ""
    @State private var autoRule: Bool = false
    @State private var showRaw: Bool = false
    @State private var showBankPicker = false
    @State private var selectedBank: BankId? = nil

    var body: some View {
        guard let tx = tx else {
            return AnyView(
                Text("Transacción no encontrada")
                    .foregroundColor(.secondary)
                    .navigationTitle("Pendiente")
            )
        }
        return AnyView(mainContent(tx))
    }

    private func mainContent(_ tx: PendingTransaction) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBarView(
                    title: "Revisar transacción",
                    leading: AnyView(
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(C.text)
                                .frame(width: 36, height: 36)
                                .background(C.surface2)
                                .cornerRadius(18)
                        }
                    )
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        // Amount hero
                        amountHero(tx)

                        // Editable form
                        formCard(tx)

                        // Category picker
                        categorySection

                        // Raw notification
                        if let raw = tx.raw, !raw.isEmpty {
                            rawSection(raw)
                        }

                        // Auto rule toggle
                        autoRuleSection(tx)

                        Spacer(minLength: 90)
                    }
                    .padding(16)
                }

                // Sticky action bar
                actionBar(tx)
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                merchant = tx.merchant
                amount = String(format: "%.0f", abs(tx.amount))
                selectedCategory = tx.category
                selectedBank = tx.bank
            }
            .sheet(isPresented: $showBankPicker) { bankPickerSheet }
        }
    }

    // MARK: - Amount Hero

    private func amountHero(_ tx: PendingTransaction) -> some View {
        VStack(spacing: 4) {
            Text(tx.amount < 0 ? "GASTO" : "INGRESO")
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(tx.amount < 0 ? C.expenseInk : C.incomeInk)
                .tracking(1)
            Text(fmtCOP(abs(tx.amount)))
                .font(.system(size: 36, weight: .heavy))
                .tracking(-0.8)
                .foregroundColor(tx.amount < 0 ? C.expense : C.income)
            Text(fmtDate(tx.date))
                .font(.system(size: 12)).foregroundColor(C.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(tx.amount < 0 ? C.expenseSoft : C.incomeSoft)
        .cornerRadius(Radii.xl)
        .overlay(RoundedRectangle(cornerRadius: Radii.xl).stroke(tx.amount < 0 ? C.expense.opacity(0.25) : C.income.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Form Card

    private func formCard(_ tx: PendingTransaction) -> some View {
        VStack(spacing: 0) {
            formRow(label: "Comercio") {
                TextField("Nombre del comercio", text: $merchant)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundColor(C.text)
                    .multilineTextAlignment(.trailing)
            }
            Divider()
            formRow(label: "Monto") {
                HStack(spacing: 2) {
                    Text("$").font(.system(size: 13.5)).foregroundColor(C.textMuted)
                    TextField("0", text: $amount)
                        .keyboardType(.numberPad)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundColor(C.text)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
            }
            Divider()
            formRow(label: "Banco") {
                Button(action: { showBankPicker = true }) {
                    HStack(spacing: 6) {
                        Text((selectedBank ?? tx.bank).meta.name)
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundColor(C.text)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10)).foregroundColor(C.textMuted)
                    }
                }
            }
            Divider()
            formRow(label: "Cuenta") {
                Text("\(tx.accountType.displayName) ···\(tx.last4 ?? "----")")
                    .font(.system(size: 13.5)).foregroundColor(C.textMuted)
            }
            Divider()
            formRow(label: "Tipo") {
                Text(tx.amount < 0 ? "Gasto" : "Ingreso")
                    .font(.system(size: 13.5)).foregroundColor(C.textMuted)
            }
            Divider()
            formRow(label: "Notas") {
                TextField("Opcional…", text: $notes)
                    .font(.system(size: 13.5))
                    .foregroundColor(C.text)
                    .multilineTextAlignment(.trailing)
            }
        }
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
    }

    private func formRow<T: View>(label: String, @ViewBuilder trailing: () -> T) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13.5))
                .foregroundColor(C.textMuted)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Categoría")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(C.textMuted)
                .tracking(0.5)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(Array(CATEGORIES.keys), id: \.rawValue) { catId in
                    let cat = catId.meta
                    let colors = hueToColor(cat.hue)
                    let isSelected = selectedCategory == catId.rawValue
                    Button(action: { selectedCategory = isSelected ? nil : catId.rawValue }) {
                        HStack(spacing: 6) {
                            CategoryDotView(id: catId.rawValue, size: 22)
                            Text(cat.name)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(isSelected ? colors.fg : C.text)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(isSelected ? colors.bg : C.surface)
                        .cornerRadius(Radii.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radii.md)
                                .stroke(isSelected ? colors.fg.opacity(0.4) : C.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Raw Notification

    private func rawSection(_ raw: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { withAnimation { showRaw.toggle() } }) {
                HStack {
                    Image(systemName: showRaw ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(C.textMuted)
                    Text("Notificación original")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(C.textMuted)
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if showRaw {
                Text(raw)
                    .font(.system(size: 11.5, design: .monospaced))
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

    // MARK: - Auto Rule

    private func autoRuleSection(_ tx: PendingTransaction) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Regla automática")
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundColor(C.text)
                Text("La próxima vez que llegue una transacción de \"\(merchant)\" se categoriza sola.")
                    .font(.system(size: 11.5))
                    .foregroundColor(C.textMuted)
                    .lineSpacing(2)
            }
            Toggle("", isOn: $autoRule)
                .labelsHidden()
                .tint(C.primary)
        }
        .padding(14)
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
    }

    // MARK: - Action Bar

    private func actionBar(_ tx: PendingTransaction) -> some View {
        HStack(spacing: 10) {
            Button(action: { handleDiscard(tx) }) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark").font(.system(size: 13, weight: .bold))
                    Text("Descartar").font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(C.text)
                .frame(maxWidth: .infinity).padding(.vertical, 15)
                .background(C.surface)
                .cornerRadius(Radii.md)
                .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.borderStrong, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            Button(action: { handleApprove(tx) }) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark").font(.system(size: 13, weight: .bold))
                    Text("Aprobar").font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 15)
                .background(C.income)
                .cornerRadius(Radii.md)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(C.bg.opacity(0.95))
        .overlay(alignment: .top) { Divider() }
    }

    // MARK: - Bank Picker Sheet

    private var bankPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(BankId.allCases, id: \.rawValue) { bank in
                    Button(action: { selectedBank = bank; showBankPicker = false }) {
                        HStack(spacing: 12) {
                            BankBadgeView(bank: bank, size: 34)
                            Text(bank.meta.name).font(.system(size: 14, weight: .semibold))
                            Spacer()
                            if selectedBank == bank {
                                Image(systemName: "checkmark").foregroundColor(.accentColor)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Seleccionar banco").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { showBankPicker = false } }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Actions

    private func handleApprove(_ tx: PendingTransaction) {
        let cat  = selectedCategory
        let merc = merchant.isEmpty ? tx.merchant : merchant
        let note = notes.isEmpty ? nil : notes
        withAnimation { pendingStore.remove(id: tx.id) }
        dismiss()
        Task { await pendingStore.approve(id: tx.id, category: cat, merchant: merc, notes: note) }
    }
    private func handleDiscard(_ tx: PendingTransaction) {
        withAnimation { pendingStore.remove(id: tx.id) }
        dismiss()
        Task { await pendingStore.discard(id: tx.id) }
    }
}
