import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    private let steps = [
        (icon: "bell.badge.fill",        color: "#009f89", title: "Lee tus notificaciones",      sub: "Tracky captura las alertas de tu banco automáticamente."),
        (icon: "tray.and.arrow.down.fill",color: "#0ea053", title: "Bandeja de pendientes",       sub: "Cada transacción espera tu aprobación antes de registrarse."),
        (icon: "chart.pie.fill",          color: "#168dd9", title: "Analiza tu dinero",            sub: "Dashboard, tendencias y top comercios en tiempo real."),
    ]

    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            LogoView(size: 26).padding(.bottom, 40)

            // Feature cards
            TabView(selection: $currentPage) {
                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                    featureCard(step: step).tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 260)

            // Page dots
            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? C.primary : C.border)
                        .frame(width: i == currentPage ? 20 : 6, height: 6)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    if currentPage < steps.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        appState.onboardingStep = 1
                    }
                }) {
                    Text(currentPage < steps.count - 1 ? "Siguiente" : "Comenzar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(C.primaryFg)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(C.primary)
                        .cornerRadius(Radii.md)
                }

                Button(action: { appState.isSignedIn = true; appState.needsOnboarding = false }) {
                    Text("Saltar")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(C.textMuted)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(C.bg.ignoresSafeArea())
    }

    private func featureCard(step: (icon: String, color: String, title: String, sub: String)) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: step.color).opacity(0.15))
                    .frame(width: 96, height: 96)
                Image(systemName: step.icon)
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(Color(hex: step.color))
            }
            Text(step.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(C.text)
                .multilineTextAlignment(.center)
            Text(step.sub)
                .font(.system(size: 14))
                .foregroundColor(C.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
    }
}
