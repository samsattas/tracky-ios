import SwiftUI

struct PricingView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var isAnnual = true

    private let features: [(icon: String, label: String, free: String?, premium: String)] = [
        ("arrow.left.arrow.right", "Transacciones/mes", "50", "Ilimitadas"),
        ("creditcard", "Cuentas bancarias", "1", "Ilimitadas"),
        ("wand.and.stars", "Reglas automáticas", nil, "Ilimitadas"),
        ("square.and.arrow.up", "Exportar CSV/PDF", nil, "Incluido"),
        ("envelope", "Resumen mensual", nil, "Incluido"),
        ("bell.badge", "Alertas de gasto", nil, "Incluido"),
        ("chart.bar.xaxis", "Reportes avanzados", nil, "Incluido"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBarView(
                    title: "Planes",
                    leading: AnyView(
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium)).foregroundColor(C.text)
                                .frame(width: 36, height: 36).background(C.surface2).cornerRadius(18)
                        }
                    )
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Billing toggle
                        HStack(spacing: 4) {
                            billingButton("Mensual", selected: !isAnnual) { isAnnual = false }
                            billingButton("Anual", selected: isAnnual, badge: "2 meses gratis") { isAnnual = true }
                        }
                        .padding(4)
                        .background(C.surface2)
                        .cornerRadius(Radii.full)

                        // Price cards side by side
                        HStack(spacing: 10) {
                            priceCard(
                                name: "Free",
                                price: "Gratis",
                                period: "para siempre",
                                isPremium: false,
                                isCurrent: true
                            )
                            priceCard(
                                name: "Premium",
                                price: isAnnual ? "$12.900" : "$17.900",
                                period: isAnnual ? "/mes · $154.800/año" : "/mes",
                                isPremium: true,
                                isCurrent: false
                            )
                        }

                        // Features table
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text("Característica")
                                    .font(.system(size: 11, weight: .bold)).foregroundColor(C.textMuted).tracking(0.5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Free").font(.system(size: 11, weight: .bold)).foregroundColor(C.textMuted).frame(width: 64, alignment: .center)
                                Text("Premium").font(.system(size: 11, weight: .bold)).foregroundColor(C.premium).frame(width: 72, alignment: .center)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(C.surface2)
                            .cornerRadius(Radii.md, corners: [.topLeft, .topRight])

                            ForEach(Array(features.enumerated()), id: \.offset) { i, f in
                                HStack(spacing: 8) {
                                    Image(systemName: f.icon).font(.system(size: 12)).foregroundColor(C.textMuted).frame(width: 20)
                                    Text(f.label).font(.system(size: 12.5)).foregroundColor(C.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Group {
                                        if let freeVal = f.free {
                                            Text(freeVal).font(.system(size: 12, weight: .semibold)).foregroundColor(C.textMuted)
                                        } else {
                                            Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(C.textSubtle)
                                        }
                                    }
                                    .frame(width: 64, alignment: .center)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold)).foregroundColor(C.premium)
                                        .frame(width: 72, alignment: .center)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 11)
                                if i < features.count - 1 { Divider() }
                            }
                        }
                        .background(C.surface)
                        .cornerRadius(Radii.lg)
                        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))

                        // CTA
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill").font(.system(size: 14))
                                Text("Comenzar \(isAnnual ? "Plan Anual" : "Plan Mensual")")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(C.premium)
                            .cornerRadius(Radii.lg)
                        }
                        .buttonStyle(.plain)

                        Text("Cancela cuando quieras · Sin compromisos")
                            .font(.system(size: 11)).foregroundColor(C.textSubtle)

                        Spacer(minLength: 24)
                    }
                    .padding(16)
                }
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private func billingButton(_ title: String, selected: Bool, badge: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title).font(.system(size: 12, weight: .bold))
                    .foregroundColor(selected ? C.text : C.textMuted)
                if let b = badge {
                    Text(b)
                        .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(C.income).cornerRadius(Radii.full)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(selected ? C.surface : Color.clear)
            .cornerRadius(Radii.full)
        }
        .buttonStyle(.plain)
    }

    private func priceCard(name: String, price: String, period: String, isPremium: Bool, isCurrent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if isPremium {
                Text("MÁS POPULAR")
                    .font(.system(size: 9, weight: .bold)).foregroundColor(.white).tracking(1)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(C.premium).cornerRadius(Radii.full)
            }
            Text(name)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(isPremium ? C.premium : C.text)
            Text(price)
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(C.text)
            Text(period)
                .font(.system(size: 10)).foregroundColor(C.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(isPremium ? C.premiumSoft : C.surface)
        .cornerRadius(Radii.lg)
        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(isPremium ? C.premium.opacity(0.5) : C.border, lineWidth: isPremium ? 1.5 : 1))
    }
}

