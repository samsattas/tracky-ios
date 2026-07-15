import SwiftUI

struct PendingView: View {
    @EnvironmentObject var pendingStore: PendingStore
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var selected: Set<String> = []
    @State private var showFilter = false

    private var selectionMode: Bool { !selected.isEmpty }
    private var selectedTotal: Double {
        pendingStore.items.filter { selected.contains($0.id) }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // AppBar
                AppBarView(
                    title: selectionMode ? "\(selected.size) seleccionadas" : "Pendientes",
                    subtitle: selectionMode
                        ? "\(fmtCOP(selectedTotal)) · Mantén presionado para seleccionar"
                        : "Desliza → para aprobar, ← para descartar",
                    trailing: AnyView(
                        Button(action: {
                            if selectionMode { selected = [] } else { showFilter = true }
                        }) {
                            Image(systemName: selectionMode ? "xmark" : "line.3.horizontal.decrease")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(C.text)
                                .frame(width: 38, height: 38)
                                .background(C.surface)
                                .cornerRadius(19)
                                .overlay(Circle().stroke(C.border, lineWidth: 1))
                        }
                    )
                )

                // Selection bar
                if selectionMode { selectionBar }

                // Content
                if pendingStore.items.isEmpty {
                    EmptyStateView(
                        icon: "tray",
                        title: "Bandeja al día",
                        subtitle: "No tienes transacciones por revisar. Te avisaremos cuando llegue una nueva.",
                        accent: .primary
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            if !selectionMode {
                                Text("Mantén presionado para seleccionar varias")
                                    .font(.system(size: 11.5))
                                    .foregroundColor(C.textSubtle)
                                    .padding(.top, 4)
                            }
                            ForEach(pendingStore.items) { tx in
                                NavigationLink(destination: PendingDetailView(txId: tx.id)) {
                                    PendingCardView(
                                        tx: tx,
                                        selected: selected.contains(tx.id),
                                        selectionMode: selectionMode,
                                        onPress: nil,
                                        onLongPress: { enterSelection(tx.id) },
                                        onSelect: { toggleSelect(tx.id) },
                                        onApprove: { handleApprove($0) },
                                        onDiscard: { handleDiscard($0) }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
            .task { await pendingStore.load() }
        }
    }

    // MARK: - Selection Bar

    private var selectionBar: some View {
        HStack(spacing: 8) {
            Button(action: {
                if selected.count == pendingStore.items.count { selected = [] }
                else { selected = Set(pendingStore.items.map(\.id)) }
            }) {
                Text(selected.count == pendingStore.items.count ? "Ninguna" : "Todas")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(C.primaryInk)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(C.primary, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Text(fmtCOP(selectedTotal))
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundColor(C.primaryInk)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: handleApproveSelected) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                    Text("Aprobar").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(C.income).cornerRadius(8)
            }
            .buttonStyle(.plain)

            Button(action: handleDiscardSelected) {
                Text("Descartar")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(C.text)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(C.borderStrong, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(C.primarySoft)
        .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.primary, lineWidth: 1))
        .padding(.horizontal, 16).padding(.bottom, 8)
    }

    // MARK: - Actions

    private func enterSelection(_ id: String) {
        selected = [id]
    }
    private func toggleSelect(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
    private func handleApprove(_ id: String) {
        let tx = pendingStore.items.first(where: { $0.id == id })
        withAnimation { pendingStore.remove(id: id) }
        Task { await pendingStore.approve(id: id, category: tx?.category, merchant: tx?.merchant) }
    }
    private func handleDiscard(_ id: String) {
        withAnimation { pendingStore.remove(id: id) }
        Task { await pendingStore.discard(id: id) }
    }
    private func handleApproveSelected() {
        let ids = selected; selected = []
        for id in ids {
            let tx = pendingStore.items.first(where: { $0.id == id })
            withAnimation { pendingStore.remove(id: id) }
            Task { await pendingStore.approve(id: id, category: tx?.category, merchant: tx?.merchant) }
        }
    }
    private func handleDiscardSelected() {
        let ids = selected; selected = []
        withAnimation { pendingStore.removeAll(ids) }
        Task { await pendingStore.discardAll(ids) }
    }
}

// MARK: - Set helper

extension Set {
    var size: Int { count }
}
