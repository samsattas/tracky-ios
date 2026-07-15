import SwiftUI

struct PermissionsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle().fill(C.primarySoft).frame(width: 100, height: 100)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(C.primary)
            }
            .padding(.bottom, 32)

            Text("Permiso de\nnotificaciones")
                .font(.system(size: 28, weight: .heavy))
                .tracking(-0.5)
                .foregroundColor(C.text)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Text("Tracky necesita leer las notificaciones de tu banco para detectar transacciones automáticamente.")
                .font(.system(size: 14))
                .foregroundColor(C.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
                .padding(.bottom, 36)

            // Features list
            VStack(spacing: 16) {
                permissionRow(
                    icon: "bell.fill", color: C.primary,
                    title: "Lee alertas bancarias",
                    sub: "Solo notificaciones de tus bancos configurados."
                )
                permissionRow(
                    icon: "lock.shield.fill", color: C.income,
                    title: "100% privado",
                    sub: "Los datos nunca salen de tu dispositivo."
                )
                permissionRow(
                    icon: "hand.raised.fill", color: C.info,
                    title: "Tú decides qué se registra",
                    sub: "Nada se guarda sin tu aprobación."
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button(action: handleGrantPermission) {
                    Text("Permitir acceso")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(C.primaryFg)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(C.primary)
                        .cornerRadius(Radii.md)
                }

                Button(action: { appState.onboardingStep = 2 }) {
                    Text("Ahora no")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(C.textMuted)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(C.bg.ignoresSafeArea())
    }

    private func permissionRow(icon: String, color: Color, title: String, sub: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 11)
                    .fill(color.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundColor(C.text)
                Text(sub)
                    .font(.system(size: 11.5))
                    .foregroundColor(C.textMuted)
            }
            Spacer()
        }
    }

    private func handleGrantPermission() {
        // TODO: UNUserNotificationCenter.requestAuthorization for push
        // On Android this would trigger NotificationListenerService intent
        appState.onboardingStep = 2
    }
}
