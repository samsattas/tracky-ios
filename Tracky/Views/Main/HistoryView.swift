import SwiftUI

struct HistoryView: View {
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var query      = ""
    @State private var showFilter = false
    @State private var filterType: TxType = .all
    @State private var filterBank: BankId? = nil
    @State private var filterCategory: String? = nil
    @State private var selected: Set<String> = []
    @State private var showDeleteConfirm = false

    @EnvironmentObject var historyStore: HistoryStore
    private var txs: [ConfirmedTransaction] { historyStore.items }

    enum TxType { case all, income, expense }

    private var selectionMode: Bool { !selected.isEmpty }

    private var filtered: [ConfirmedTransaction] {
        var result = txs
        if !query.isEmpty { result = result.filter { $0.merchant.localizedCaseInsensitiveContains(query) } }
        if filterType == .income  { result = result.filter { $0.amount > 0 } }
        if filterType == .expense { result = result.filter { $0.amount < 0 } }
        if let b = filterBank     { result = result.filter { $0.bank == b } }
        if let c = filterCategory { result = result.filter { $0.category == c } }
        return result
    }

    private var sections: [(title: String, items: [ConfirmedTransaction])] {
        var groups: [String: [ConfirmedTransaction]] = [:]
        for tx in filtered {
            let key = sectionKey(tx.date)
            groups[key, default: []].append(tx)
        }
        let sortedKeys = groups.keys.sorted { a, b in
            let aDate = groups[a]?.first?.date ?? ""
            let bDate = groups[b]?.first?.date ?? ""
            return aDate > bDate
        }
        return sortedKeys.map { (title: $0, items: groups[$0]!) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                AppBarView(
                    title: selectionMode ? "\(selected.count) seleccionadas" : "Historial",
                    subtitle: selectionMode
                        ? "\(fmtCOP(abs(selectedTotal))) · Mantén presionado para seleccionar"
                        : "\(filtered.count) transacciones",
                    trailing: AnyView(trailingButtons)
                )

                // Search bar
                if !selectionMode {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(C.textMuted)
                        TextField("Buscar comercio…", text: $query)
                            .font(.system(size: 13))
                            .foregroundColor(C.text)
                        Button(action: { showFilter = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14))
                                .foregroundColor(filterActive ? C.primaryInk : C.textMuted)
                                .padding(4)
                                .background(filterActive ? C.primarySoft : Color.clear)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(C.surface)
                    .cornerRadius(Radii.md)
                    .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))
                    .padding(.horizontal, 16).padding(.vertical, 10)
                }

                // Selection bar
                if selectionMode { selectionBar }

                // List
                if filtered.isEmpty {
                    EmptyStateView(
                        icon: txs.isEmpty ? "list.bullet.rectangle" : "magnifyingglass",
                        title: txs.isEmpty ? "Sin historial aún" : "Sin resultados",
                        subtitle: txs.isEmpty
                            ? "Cuando apruebes tu primera transacción aparecerá aquí."
                            : "Ninguna transacción coincide con los filtros.",
                        action: txs.isEmpty ? nil : "Limpiar filtros",
                        onAction: clearFilters,
                        accent: txs.isEmpty ? .info : .primary
                    )
                } else {
                    List {
                        ForEach(sections, id: \.title) { section in
                            Section(header:
                                Text(section.title)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(C.textMuted)
                                    .textCase(.uppercase)
                                    .tracking(1)
                            ) {
                                ForEach(section.items) { tx in
                                    NavigationLink(destination: HistoryDetailView(tx: tx)) {
                                        TransactionRowView(
                                            tx: tx,
                                            showAccount: true,
                                            selected: selected.contains(tx.id),
                                            selectionMode: selectionMode,
                                            onLongPress: { enterSelection(tx.id) },
                                            onSelect: { toggleSelect(tx.id) }
                                        )
                                    }
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(selected.contains(tx.id) ? C.primarySoft : C.surface)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(C.bg)
                }
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
            .task { await historyStore.load() }
            .sheet(isPresented: $showFilter) { filterSheet }
            .alert("Eliminar transacciones", isPresented: $showDeleteConfirm) {
                Button("Eliminar", role: .destructive) { deleteSelected() }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Eliminar \(selected.count) \(selected.count == 1 ? "transacción" : "transacciones")? Esta acción no se puede deshacer.")
            }
        }
    }

    // MARK: - Trailing Buttons

    private var trailingButtons: some View {
        Group {
            if selectionMode {
                Button(action: { selected = [] }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15)).foregroundColor(C.text)
                        .frame(width: 38, height: 38)
                        .background(C.surface).cornerRadius(19)
                        .overlay(Circle().stroke(C.border, lineWidth: 1))
                }
            } else {
                HStack(spacing: 8) {
                    NavigationLink(destination: NewTransactionView()) {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                            .frame(width: 38, height: 38).background(C.primary).cornerRadius(19)
                    }
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 15)).foregroundColor(C.text)
                            .frame(width: 38, height: 38)
                            .background(C.surface).cornerRadius(19)
                            .overlay(Circle().stroke(C.border, lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: - Selection Bar

    private var selectionBar: some View {
        HStack(spacing: 8) {
            Button(action: {
                if selected.count == filtered.count { selected = [] }
                else { selected = Set(filtered.map(\.id)) }
            }) {
                Text(selected.count == filtered.count ? "Ninguna" : "Todas")
                    .font(.system(size: 11, weight: .bold)).foregroundColor(C.expenseInk)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(C.expense, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Text("\(selected.count) elemento\(selected.count != 1 ? "s" : "")")
                .font(.system(size: 12.5, weight: .semibold)).foregroundColor(C.expenseInk)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { showDeleteConfirm = true }) {
                HStack(spacing: 5) {
                    Image(systemName: "trash").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    Text("Eliminar").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                }
                .padding(.horizontal, 10).padding(.vertical, 5).background(C.expense).cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(C.expenseSoft)
        .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.expense, lineWidth: 1))
        .padding(.horizontal, 16).padding(.bottom, 8)
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Tipo
                    filterSection("Tipo") {
                        HStack(spacing: 8) {
                            filterChip("Todos",    active: filterType == .all)    { filterType = .all }
                            filterChip("Ingresos", active: filterType == .income) { filterType = .income }
                            filterChip("Gastos",   active: filterType == .expense){ filterType = .expense }
                        }
                    }

                    // Banco
                    let avBanks = Array(Set(txs.map(\.bank)))
                    if !avBanks.isEmpty {
                        filterSection("Banco") {
                            FlowLayout(spacing: 8) {
                                ForEach(avBanks, id: \.rawValue) { b in
                                    filterChip(b.meta.name, active: filterBank == b) {
                                        filterBank = filterBank == b ? nil : b
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Filtros").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { showFilter = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") { showFilter = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func filterSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                .textCase(.uppercase).tracking(0.8)
            content()
        }
    }

    private func filterChip(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundColor(active ? C.primaryInk : C.textMuted)
                .padding(.horizontal, 11).padding(.vertical, 7)
                .background(
                    Capsule().fill(active ? C.primarySoft : C.surface2)
                        .overlay(Capsule().stroke(active ? C.primary : C.border, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var filterActive: Bool { filterType != .all || filterBank != nil || filterCategory != nil }

    private var selectedTotal: Double {
        txs.filter { selected.contains($0.id) }.reduce(0) { $0 + $1.amount }
    }

    private func enterSelection(_ id: String) { selected = [id] }
    private func toggleSelect(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
    private func clearFilters() { filterType = .all; filterBank = nil; filterCategory = nil; query = "" }
    private func deleteSelected() {
        let ids = selected
        selected = []
        Task { await historyStore.deleteAll(ids) }
    }

    private func sectionKey(_ iso: String) -> String {
        guard iso.count >= 10 else { return iso }
        let dateStr = String(iso.prefix(10))
        // TODO: categorize as "Hoy", "Esta semana", etc.
        return fmtDate(dateStr)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return CGSize(width: proposal.width ?? 0, height: rows.map(\.height).reduce(0, +) + CGFloat(max(0, rows.count-1)) * spacing)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for sv in row.subviews {
                let size = sv.sizeThatFits(.unspecified)
                sv.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }
    private struct Row { var subviews: [LayoutSubview]; var height: CGFloat }
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current: Row = Row(subviews: [], height: 0)
        var x: CGFloat = 0
        let maxW = proposal.width ?? .infinity
        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if x + size.width > maxW && !current.subviews.isEmpty {
                rows.append(current); current = Row(subviews: [], height: 0); x = 0
            }
            current.subviews.append(sv)
            current.height = max(current.height, size.height)
            x += size.width + spacing
        }
        if !current.subviews.isEmpty { rows.append(current) }
        return rows
    }
}

// MARK: - Placeholder for new transaction
struct NewTransactionView: View {
    var body: some View { Text("Nueva transacción").navigationTitle("Nueva transacción") }
}
