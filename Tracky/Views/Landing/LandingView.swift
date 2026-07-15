import SwiftUI

struct LandingView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    private let demoTx = PendingTransaction(
        id: "demo", bank: .bogota, accountType: .credit, last4: "3243",
        merchant: "AliExpress", amount: 58201, date: "2026-05-21",
        category: "shopping", raw: nil
    )
    private let featureBanks: [BankId] = [.bogota, .bancolombia, .davivienda, .bbva, .nequi, .daviplata, .scotia]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection
                        demoSection
                        featuresGrid
                        bankStrip
                        footerCTA
                    }
                }
                navBar
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    // MARK: - Nav bar
    private var navBar: some View {
        HStack {
            LogoView(size: 22)
            Spacer()
            NavigationLink(destination: SignInView()) {
                Text("Ingresar")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(C.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .overlay(
                        Capsule().stroke(C.borderStrong, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            C.bg.opacity(0.95)
                .overlay(alignment: .bottom) { Divider() }
        )
    }

    // MARK: - Hero
    private var heroSection: some View {
        ZStack {
            Circle().fill(C.primarySoft).frame(width: 280).offset(x: 90, y: -60)
            Circle().fill(C.incomeSoft.opacity(0.5)).frame(width: 220).offset(x: -80, y: 160)
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 60) // nav bar offset

                // Badge pill
                HStack(spacing: 6) {
                    ZStack {
                        Circle().fill(C.primary).frame(width: 18, height: 18)
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Sin importar transacciones a mano")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(C.textMuted)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(C.surface).cornerRadius(Radii.full)
                .overlay(Capsule().stroke(C.border, lineWidth: 1))
                .padding(.bottom, 16)

                Text("Tu plata,\ncontada sola.")
                    .font(.system(size: 36, weight: .heavy))
                    .tracking(-1)
                    .foregroundColor(C.text)
                    .lineSpacing(2)
                    .padding(.bottom, 14)

                (Text("Tracky lee las notificaciones de tu banco y arma tu contabilidad personal. ")
                    .foregroundColor(C.textMuted)
                + Text("Cualquier banco, sin configurar. ")
                    .fontWeight(.bold).foregroundColor(C.text)
                + Text("Tú solo apruebas o descartas.")
                    .foregroundColor(C.textMuted))
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .padding(.bottom, 22)

                NavigationLink(destination: SignUpView()) {
                    HStack {
                        Spacer()
                        Text("Crear cuenta gratis")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(C.primaryFg)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(C.primaryFg)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(C.primary)
                    .cornerRadius(Radii.md)
                }

                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(C.textMuted)
                    Text("No pedimos claves de tu banco")
                        .font(.system(size: 11))
                        .foregroundColor(C.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }

    // MARK: - Demo
    private var demoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 10))
                        .foregroundColor(C.textMuted)
                    Text("Notificación entrante")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(C.textMuted)
                        .textCase(.uppercase)
                        .tracking(0.8)
                }

                Text("\"Banco de Bogota: Tu compra por **58,201** fue aprobada con Tarjeta Crédito **3243** el **21/05/26 14:21:54** en **aliexpress\"**")
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundColor(C.textMuted)
                    .lineSpacing(3)
                    .padding(10)
                    .background(C.surface2)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(C.border, lineWidth: 1))

                HStack {
                    Spacer()
                    Image(systemName: "arrow.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(C.primary)
                    Spacer()
                }

                PendingCardView(tx: demoTx)
            }
            .padding(14)
            .background(C.surface)
            .cornerRadius(Radii.lg)
            .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
    }

    // MARK: - Features Grid
    private let features: [(icon: String, title: String, sub: String, bg: String, fg: String)] = [
        ("tray.fill",          "Bandeja de pendientes",   "Revisa y aprueba con un swipe.",      "#d3f8ef", "#009f89"),
        ("sparkles",           "Categorías automáticas",  "Reglas que aprenden de ti.",           "#d7f9de", "#0ea053"),
        ("chart.pie.fill",     "Dashboard mensual",        "Tendencia, top y donut.",             "#d9f2ff", "#168dd9"),
        ("lock.fill",          "100% privado",             "Tus notis no salen del teléfono.",    "#f0e9ff", "#7c54cd"),
    ]

    private var featuresGrid: some View {
        let cols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        return LazyVGrid(columns: cols, spacing: 10) {
            ForEach(features, id: \.title) { f in
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: f.bg))
                            .frame(width: 32, height: 32)
                        Image(systemName: f.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: f.fg))
                    }
                    .padding(.bottom, 10)
                    Text(f.title)
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(C.text)
                        .padding(.bottom, 2)
                    Text(f.sub)
                        .font(.system(size: 11))
                        .foregroundColor(C.textMuted)
                        .lineSpacing(3)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(C.surface)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(C.border, lineWidth: 1))
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
    }

    // MARK: - Bank Strip
    private var bankStrip: some View {
        VStack(spacing: 8) {
            Text("FUNCIONA CON")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(C.textMuted)
                .tracking(1)
            Text("Cualquier banco que mande notificación")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(C.text)
                .tracking(-0.2)
            HStack(spacing: 8) {
                ForEach(featureBanks, id: \.rawValue) { b in
                    BankBadgeView(bank: b, size: 32)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(C.borderStrong, lineWidth: 1.5, dash: [4])
                        .frame(width: 32, height: 32)
                    Text("+")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(C.textMuted)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 32)
    }

    // MARK: - Footer CTA
    private var footerCTA: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("¿Empezamos?")
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.5)
                .foregroundColor(.white)
            Text("30 segundos. Sin tarjeta.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 4)
            NavigationLink(destination: SignUpView()) {
                HStack {
                    Spacer()
                    Text("Descargar Tracky")
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundColor(Color(hex: "#0f172a"))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#0f172a"))
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#0f172a"))
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

// MARK: - Corner Radius Helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Dash Stroke Helper

extension RoundedRectangle {
    func stroke(_ color: Color, lineWidth: CGFloat, dash: [CGFloat]) -> some View {
        self.stroke(style: StrokeStyle(lineWidth: lineWidth, dash: dash)).foregroundColor(color)
    }
}
