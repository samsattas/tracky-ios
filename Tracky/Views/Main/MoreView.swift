import SwiftUI

struct MoreView: View {
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Más")
                        .font(.system(size: 24, weight: .heavy))
                        .tracking(-0.5)
                        .foregroundColor(C.text)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(C.bg)
                .overlay(alignment: .bottom) { Divider() }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        menuGroup {
                            menuRow(
                                icon: "tag.fill", iconBg: C.primarySoft, iconColor: C.primary,
                                title: "Categorías y reglas",
                                subtitle: "\(CATEGORIES.count) categorías · \(MOCK_RULES.count) reglas",
                                destination: AnyView(CategoriesView())
                            )
                            menuRow(
                                icon: "gearshape.fill", iconBg: C.surface2, iconColor: C.textMuted,
                                title: "Ajustes",
                                subtitle: "Preferencias y exportación",
                                destination: AnyView(SettingsView())
                            )
                            menuRow(
                                icon: "doc.text.fill", iconBg: C.infoSoft, iconColor: C.info,
                                title: "Exportar datos",
                                subtitle: "CSV o PDF del mes",
                                destination: AnyView(Text("Exportar").navigationTitle("Exportar"))
                            )
                            menuRowLast(
                                icon: "questionmark.circle.fill", iconBg: C.surface2, iconColor: C.textMuted,
                                title: "Ayuda y soporte",
                                destination: AnyView(Text("Ayuda").navigationTitle("Ayuda"))
                            )
                        }

                        Text("Tracky v1.0.0 · Hecho en Colombia")
                            .font(.system(size: 10.5))
                            .foregroundColor(C.textSubtle)
                            .padding(.top, 24)
                            .padding(.bottom, 12)
                    }
                    .padding(.top, 16)
                }
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private func menuGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(C.surface)
            .cornerRadius(Radii.lg)
            .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
            .padding(.horizontal, 16)
    }

    private func menuRow(icon: String, iconBg: Color, iconColor: Color, title: String, subtitle: String, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            rowContent(icon: icon, iconBg: iconBg, iconColor: iconColor, title: title, subtitle: subtitle)
                .overlay(alignment: .bottom) { Divider().padding(.leading, 60) }
        }
        .buttonStyle(.plain)
    }

    private func menuRowLast(icon: String, iconBg: Color, iconColor: Color, title: String, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            rowContent(icon: icon, iconBg: iconBg, iconColor: iconColor, title: title, subtitle: nil)
        }
        .buttonStyle(.plain)
    }

    private func rowContent(icon: String, iconBg: Color, iconColor: Color, title: String, subtitle: String?) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconBg)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(C.text)
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 11.5))
                        .foregroundColor(C.textMuted)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(C.textSubtle)
        }
        .padding(14)
    }
}
