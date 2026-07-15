import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var pendingStore: PendingStore
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            PendingView()
                .tabItem {
                    Label {
                        Text("Pendientes")
                    } icon: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: selectedTab == 1 ? "tray.fill" : "tray")
                            if pendingStore.count > 0 {
                                Text("\(min(pendingStore.count, 99))")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color(hex: "#e64343"))
                                    .cornerRadius(8)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label("Historial", systemImage: selectedTab == 2 ? "list.bullet.rectangle.fill" : "list.bullet.rectangle")
                }
                .tag(2)

            AccountsView()
                .tabItem {
                    Label("Cuentas", systemImage: selectedTab == 3 ? "wallet.bifold.fill" : "wallet.bifold")
                }
                .tag(3)

            MoreView()
                .tabItem {
                    Label("Más", systemImage: "ellipsis")
                }
                .tag(4)
        }
        .tint(C.primary)
    }
}
