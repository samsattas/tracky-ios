import SwiftUI

class AppState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var needsOnboarding: Bool = false
    @Published var onboardingStep: Int = 0
    // Main tab selection: 0 Inicio, 1 Pendientes, 2 Historial, 3 Cuentas, 4 Más
    @Published var selectedTab: Int = 0
}
