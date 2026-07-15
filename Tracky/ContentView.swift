import SwiftUI

struct ContentView: View {
    @StateObject private var session      = SessionStore.shared
    @StateObject private var appState     = AppState()
    @StateObject private var pendingStore = PendingStore()
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var accountStore = AccountStore()
    @StateObject private var rulesStore   = RulesStore()

    var body: some View {
        Group {
            if session.isSignedIn {
                if appState.needsOnboarding {
                    onboardingFlow
                } else {
                    MainTabView()
                        .task { await loadAll() }
                }
            } else {
                LandingView()
            }
        }
        .environmentObject(session)
        .environmentObject(appState)
        .environmentObject(pendingStore)
        .environmentObject(historyStore)
        .environmentObject(accountStore)
        .environmentObject(rulesStore)
    }

    @ViewBuilder
    private var onboardingFlow: some View {
        switch appState.onboardingStep {
        case 0: WelcomeView()
        case 1: PermissionsView()
        case 2: AccountSetupView()
        default: MainTabView()
        }
    }

    private func loadAll() async {
        async let p: () = pendingStore.load()
        async let h: () = historyStore.load()
        async let a: () = accountStore.load()
        async let r: () = rulesStore.load()
        _ = await (p, h, a, r)
    }
}
