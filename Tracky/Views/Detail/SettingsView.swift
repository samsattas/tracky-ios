import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var weeklyEmail      = true
    @State private var dailyReminder   = false
    @State private var showSignOutAlert = false
    @ObservedObject private var session = SessionStore.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBarView(title: "Ajustes")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        // Profile card
                        profileCard

                        // Plan
                        planCard

                        // Processing group
                        settingsGroup("PROCESAMIENTO DE NOTIFICACIONES") {
                            NavigationLink(destination: Text("Bancos soportados").navigationTitle("Bancos")) {
                                settingsRow(icon: "building.columns.fill", iconBg: C.primarySoft, iconColor: C.primary,
                                    label: "Bancos soportados", detail: "7 activos")
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading, 60)
                            NavigationLink(destination: Text("Plantillas").navigationTitle("Plantillas")) {
                                settingsRow(icon: "doc.text.fill", iconBg: C.infoSoft, iconColor: C.info,
                                    label: "Plantillas de extracción", detail: "Personalizar")
                            }
                            .buttonStyle(.plain)
                        }

                        // Communication
                        settingsGroup("COMUNICACIÓN") {
                            settingsToggle(icon: "envelope.fill", iconBg: C.primarySoft, iconColor: C.primary,
                                label: "Resumen semanal por email",
                                sublabel: "Recibe un resumen los lunes",
                                value: $weeklyEmail)
                            Divider().padding(.leading, 60)
                            settingsToggle(icon: "bell.fill", iconBg: C.warningSoft, iconColor: C.warning,
                                label: "Recordatorio diario",
                                sublabel: "Aviso si hay pendientes sin revisar",
                                value: $dailyReminder)
                        }

                        // Data
                        settingsGroup("DATOS") {
                            NavigationLink(destination: PricingView()) {
                                settingsRow(icon: "square.and.arrow.up.fill", iconBg: C.premiumSoft, iconColor: C.premium,
                                    label: "Exportar datos", detail: "Premium")
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading, 60)
                            Button(action: {}) {
                                settingsRow(icon: "shield.fill", iconBg: C.infoSoft, iconColor: C.info,
                                    label: "Política de privacidad", detail: nil)
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading, 60)
                            Button(action: {}) {
                                settingsRow(icon: "doc.fill", iconBg: C.surface2, iconColor: C.textMuted,
                                    label: "Términos de servicio", detail: nil)
                            }
                            .buttonStyle(.plain)
                        }

                        // Sign out
                        Button(action: { showSignOutAlert = true }) {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.right.square.fill")
                                    .font(.system(size: 14))
                                Text("Cerrar sesión")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                            }
                            .foregroundColor(C.expense)
                            .padding(.vertical, 14)
                            .background(C.expenseSoft)
                            .cornerRadius(Radii.lg)
                            .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.expense.opacity(0.3), lineWidth: 1))
                        }
                        .padding(.top, 8)

                        Text("Tracky v1.0.0 · Hecho con ❤️ en Colombia")
                            .font(.system(size: 10.5)).foregroundColor(C.textSubtle)
                            .padding(.vertical, 12)

                        Spacer(minLength: 24)
                    }
                    .padding(16)
                }
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
            .alert("Cerrar sesión", isPresented: $showSignOutAlert) {
                Button("Cerrar sesión", role: .destructive) { SessionStore.shared.signOut() }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Seguro que quieres cerrar sesión?")
            }
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(C.primarySoft).frame(width: 52, height: 52)
                Text("S").font(.system(size: 22, weight: .heavy)).foregroundColor(C.primaryInk)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Samuel Satizábal")
                    .font(.system(size: 15, weight: .bold)).foregroundColor(C.text)
                Text("samuelsatizabaltascon@gmail.com")
                    .font(.system(size: 11.5)).foregroundColor(C.textMuted)
            }
            Spacer()
            Image(systemName: "pencil").font(.system(size: 13)).foregroundColor(C.textMuted)
        }
        .padding(14)
        .background(C.surface)
        .cornerRadius(Radii.lg)
        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
    }

    // MARK: - Plan Card

    private var planCard: some View {
        NavigationLink(destination: PricingView()) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(C.premiumSoft).frame(width: 38, height: 38)
                    Image(systemName: "star.fill").font(.system(size: 16)).foregroundColor(C.premium)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan Free").font(.system(size: 14, weight: .bold)).foregroundColor(C.text)
                    Text("Mejora a Premium para desbloquear todo")
                        .font(.system(size: 11.5)).foregroundColor(C.textMuted)
                }
                Spacer()
                Text("Mejorar")
                    .font(.system(size: 11.5, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(C.premium).cornerRadius(8)
            }
            .padding(14)
            .background(C.premiumSoft)
            .cornerRadius(Radii.lg)
            .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.premium.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func settingsGroup<Content: View>(_ header: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.system(size: 11, weight: .bold)).foregroundColor(C.textMuted).tracking(1)
            VStack(spacing: 0) { content() }
                .background(C.surface)
                .cornerRadius(Radii.lg)
                .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
        }
    }

    private func settingsRow(icon: String, iconBg: Color, iconColor: Color, label: String, detail: String?) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9).fill(iconBg).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(iconColor)
            }
            Text(label).font(.system(size: 13.5, weight: .medium)).foregroundColor(C.text)
            Spacer()
            if let d = detail {
                Text(d).font(.system(size: 12)).foregroundColor(C.textMuted)
            }
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(C.textSubtle)
        }
        .padding(14)
    }

    private func settingsToggle(icon: String, iconBg: Color, iconColor: Color, label: String, sublabel: String, value: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9).fill(iconBg).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 13.5, weight: .medium)).foregroundColor(C.text)
                Text(sublabel).font(.system(size: 11.5)).foregroundColor(C.textMuted)
            }
            Spacer()
            Toggle("", isOn: value).labelsHidden().tint(C.primary)
        }
        .padding(14)
    }
}
