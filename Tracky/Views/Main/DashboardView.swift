import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var pendingStore: PendingStore
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var accountStore: AccountStore
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    private var income:   Double { historyStore.income }
    private var expenses: Double { historyStore.expenses }
    private var balance:  Double { historyStore.balance }
    private var accounts: [Account] { accountStore.items }
    private let catShare  = MOCK_CAT_SHARE   // TODO: compute from real history
    private let trend     = MOCK_TREND        // TODO: compute from real history
    private let merchants = MOCK_MERCHANTS    // TODO: compute from real history

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {

                    // Hero balance card
                    heroCard

                    // Pending ribbon
                    if pendingStore.count > 0 {
                        pendingRibbon
                    }

                    // Donut chart
                    if !catShare.isEmpty {
                        sectionTitle("Gasto por categoría")
                        donutCard
                    }

                    // Trend chart
                    sectionTitle("Tendencia 6 meses")
                    trendCard

                    // Accounts
                    HStack {
                        sectionTitleView("Mis cuentas")
                        Spacer()
                        NavigationLink(destination: AccountsView()) {
                            Text("Gestionar")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundColor(C.primary)
                        }
                    }
                    accountsScroll

                    // Top merchants
                    if !merchants.isEmpty {
                        sectionTitle("Top comercios")
                        merchantsCard
                    }

                    // Recent
                    HStack {
                        sectionTitleView("Recientes")
                        Spacer()
                        NavigationLink(destination: HistoryView()) {
                            Text("Ver todo")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundColor(C.primary)
                        }
                    }
                    recentCard

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("Hola")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(C.text)
                    }
                }
            }
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#161b20"), Color(hex: "#113436")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            // Halo glow
            RadialGradient(
                colors: [Color(hex: "#009f89").opacity(0.30), Color(hex: "#009f89").opacity(0.08), .clear],
                center: .topTrailing,
                startRadius: 0, endRadius: 100
            )

            VStack(alignment: .leading, spacing: 0) {
                Text("BALANCE DEL MES")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(.white.opacity(0.65))
                    .tracking(1)
                    .padding(.bottom, 4)

                Text(fmtCOP(balance))
                    .font(.system(size: 30, weight: .heavy))
                    .tracking(-0.6)
                    .foregroundColor(.white)
                    .padding(.bottom, 14)

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.left")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.65))
                            Text("INGRESOS")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundColor(.white.opacity(0.65))
                                .tracking(0.8)
                        }
                        Text(fmtCOP(income))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#72eb99"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 1)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.65))
                            Text("GASTOS")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundColor(.white.opacity(0.65))
                                .tracking(0.8)
                        }
                        Text(fmtCOP(expenses))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#ff7a73"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 14)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cornerRadius(Radii.xl)
        .overlay(RoundedRectangle(cornerRadius: Radii.xl).stroke(Color(hex: "#21373d"), lineWidth: 1))
    }

    // MARK: - Pending Ribbon

    private var pendingRibbon: some View {
        NavigationLink(destination: PendingView()) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(C.warning)
                        .frame(width: 32, height: 32)
                    Image(systemName: "tray.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(pendingStore.count) \(pendingStore.count == 1 ? "transacción pendiente" : "transacciones pendientes")")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(C.warningInk)
                    Text("\(fmtCOP(pendingStore.items.reduce(0) { $0 + $1.amount })) sin clasificar")
                        .font(.system(size: 11))
                        .foregroundColor(C.warningInk.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(C.warningInk)
            }
            .padding(12)
            .background(C.warningSoft)
            .cornerRadius(Radii.md)
            .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(Color(hex: "#e8c86a"), lineWidth: 1))
        }
    }

    // MARK: - Donut Card

    private var donutCard: some View {
        HStack(spacing: 12) {
            DonutChartView(
                segments: catShare.map { DonutSegment(value: $0.value, color: Color(hex: $0.color)) },
                size: 140,
                centerLabel: fmtCOP(expenses)
            )
            VStack(alignment: .leading, spacing: 6) {
                ForEach(catShare.prefix(6), id: \.id) { s in
                    if let catId = CategoryId(rawValue: s.id) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: s.color))
                                .frame(width: 8, height: 8)
                            Text(catId.meta.name)
                                .font(.system(size: 11.5, weight: .medium))
                                .foregroundColor(C.text)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(Int(s.value * 100))%")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundColor(C.textMuted)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
    }

    // MARK: - Trend Card

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                legendDot(C.income, "Ingresos")
                legendDot(C.expense, "Gastos")
            }
            TrendChartView(data: trend)
        }
        .padding(14)
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(C.textMuted)
        }
    }

    // MARK: - Accounts Scroll

    private var accountsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(accounts.prefix(4)) { a in
                    AccountCardView(account: a, compact: true)
                        .frame(width: 220)
                }
            }
            .padding(.bottom, 6)
        }
    }

    // MARK: - Merchants Card

    private var merchantsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(merchants.enumerated()), id: \.offset) { i, m in
                HStack(spacing: 12) {
                    CategoryDotView(id: m.category, size: 32)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(m.name).font(.system(size: 13, weight: .semibold)).foregroundColor(C.text)
                        Text("\(m.count) \(m.count == 1 ? "compra" : "compras")").font(.system(size: 11)).foregroundColor(C.textMuted)
                    }
                    Spacer()
                    Text(fmtCOP(m.amount)).font(.system(size: 13.5, weight: .bold)).foregroundColor(C.text)
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 14)
                if i < merchants.count - 1 { Divider().padding(.leading, 14) }
            }
        }
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
    }

    // MARK: - Recent Card

    private var recentCard: some View {
        VStack(spacing: 0) {
            ForEach(historyStore.items.prefix(3)) { tx in
                NavigationLink(destination: HistoryDetailView(tx: tx)) {
                    TransactionRowView(tx: tx, showAccount: true)
                }
                .buttonStyle(.plain)
            }
        }
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
        .clipped()
        .padding(.bottom, 0)
    }

    // MARK: - Section Title Helpers

    @ViewBuilder
    private func sectionTitle(_ text: String) -> some View {
        sectionTitleView(text)
    }

    private func sectionTitleView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(C.text)
            .padding(.top, 4)
    }
}
