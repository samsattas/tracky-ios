import SwiftUI

struct AccountsView: View {
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @EnvironmentObject var accountStore: AccountStore
    @State private var showNewAccount = false

    private var accounts:       [Account] { accountStore.items }
    private var creditAccounts: [Account] { accountStore.creditAccounts }
    private var debitAccounts:  [Account] { accountStore.debitAccounts }
    private var totalBalance:   Double    { accountStore.totalBalance }
    private var totalUsed:      Double    { accountStore.totalUsed }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBarView(
                    title: "Cuentas",
                    subtitle: "\(accounts.count) cuenta\(accounts.count != 1 ? "s" : "") registrada\(accounts.count != 1 ? "s" : "")",
                    trailing: AnyView(
                        Button(action: { showNewAccount = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(C.primary)
                                .cornerRadius(11)
                        }
                    )
                )

                // Summary tiles
                if !accounts.isEmpty {
                    HStack(spacing: 8) {
                        StatTileView(label: "Saldo total", value: fmtCOP(totalBalance), tone: .income, icon: "wallet.bifold.fill")
                        if !creditAccounts.isEmpty {
                            StatTileView(label: "Deuda TC", value: fmtCOP(totalUsed), tone: .expense, icon: "creditcard.fill")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 14)
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {

                        // Credit cards
                        if !creditAccounts.isEmpty {
                            Text("TARJETAS DE CRÉDITO")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(C.textMuted)
                                .tracking(1)
                                .padding(.top, 2)
                            ForEach(creditAccounts) { a in
                                NavigationLink(destination: AccountDetailView(account: a)) {
                                    AccountCardView(account: a)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Debit / wallets
                        if !debitAccounts.isEmpty {
                            Text("DÉBITO Y BILLETERAS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(C.textMuted)
                                .tracking(1)
                                .padding(.top, creditAccounts.isEmpty ? 2 : 8)
                            ForEach(debitAccounts) { a in
                                NavigationLink(destination: AccountDetailView(account: a)) {
                                    AccountCardView(account: a)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Listening indicator
                        HStack(spacing: 12) {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 11)
                                    .fill(C.surface2)
                                    .frame(width: 38, height: 38)
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 15)).foregroundColor(C.textMuted)
                                    .frame(width: 38, height: 38)
                                Circle().fill(C.primary).frame(width: 8, height: 8).offset(x: 4, y: -4)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Escuchando notificaciones")
                                    .font(.system(size: 12.5, weight: .bold)).foregroundColor(C.text)
                                Text("Las cuentas también aparecen solas cuando recibes una notificación bancaria.")
                                    .font(.system(size: 11)).foregroundColor(C.textMuted).lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(C.borderStrong, style: StrokeStyle(lineWidth: 1.5, dash: [5])))
                        .padding(.top, 4)

                        Button(action: { showNewAccount = true }) {
                            HStack(spacing: 5) {
                                Image(systemName: "plus").font(.system(size: 11))
                                Text("Agregar una cuenta manualmente").font(.system(size: 11.5, weight: .semibold))
                            }
                            .foregroundColor(C.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .background(C.bg.ignoresSafeArea())
            .navigationBarHidden(true)
            .task { await accountStore.load() }
            .sheet(isPresented: $showNewAccount) { NewAccountView() }
        }
    }
}

// MARK: - Placeholders

struct AccountDetailView: View {
    let account: Account
    var body: some View {
        Text(account.alias).navigationTitle("Cuenta")
    }
}

struct NewAccountView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Text("Nueva cuenta")
                .navigationTitle("Nueva cuenta")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                }
        }
    }
}
