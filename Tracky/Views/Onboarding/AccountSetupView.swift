import SwiftUI

struct AccountSetupView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var selectedBank: BankId = .bogota
    @State private var accountType: AccountType = .debit
    @State private var last4 = ""
    @State private var alias = ""
    @State private var showBankPicker = false
    @State private var loading = false

    private var b: BankMeta { selectedBank.meta }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Configura tu primera cuenta")
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundColor(C.text)
                Text("Puedes añadir más cuentas después.")
                    .font(.system(size: 13))
                    .foregroundColor(C.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    // Bank selector
                    Button(action: { showBankPicker = true }) {
                        HStack(spacing: 12) {
                            BankBadgeView(bank: selectedBank, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Banco")
                                    .font(.system(size: 10.5, weight: .semibold))
                                    .foregroundColor(C.textMuted)
                                    .textCase(.uppercase)
                                Text(b.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(C.text)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(C.textSubtle)
                        }
                        .padding(14)
                        .background(C.surface)
                        .cornerRadius(Radii.lg)
                        .overlay(RoundedRectangle(cornerRadius: Radii.lg).stroke(C.border, lineWidth: 1))
                    }

                    // Account type picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tipo de cuenta")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(C.textMuted)
                            .textCase(.uppercase)
                            .tracking(0.8)
                        HStack(spacing: 8) {
                            ForEach(AccountType.allCases, id: \.self) { type in
                                typeChip(type)
                            }
                        }
                    }

                    // Last 4 digits
                    formField(icon: "creditcard.fill", placeholder: "Últimos 4 dígitos", text: $last4, keyboard: .numberPad)

                    // Alias
                    formField(icon: "tag.fill", placeholder: "Alias (ej: Bogotá Platinum)", text: $alias)
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: handleSave) {
                    HStack { Spacer()
                        if loading { ProgressView().tint(.white) }
                        else { Text("Guardar y continuar").font(.system(size: 16, weight: .bold)).foregroundColor(C.primaryFg) }
                        Spacer() }
                    .frame(height: 52).background(C.primary).cornerRadius(Radii.md)
                }
                .disabled(loading)

                Button(action: { appState.isSignedIn = true; appState.needsOnboarding = false }) {
                    Text("Hacerlo después")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(C.textMuted)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(C.bg.ignoresSafeArea())
        .sheet(isPresented: $showBankPicker) { bankPickerSheet }
    }

    private func typeChip(_ type: AccountType) -> some View {
        let selected = accountType == type
        return Button(action: { accountType = type }) {
            Text(type.displayName)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundColor(selected ? C.primaryInk : C.textMuted)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: Radii.full)
                        .fill(selected ? C.primarySoft : C.surface2)
                        .overlay(RoundedRectangle(cornerRadius: Radii.full)
                            .stroke(selected ? C.primary : C.border, lineWidth: 1))
                )
        }.buttonStyle(.plain)
    }

    private func formField(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 15)).foregroundColor(C.textMuted)
            TextField(placeholder, text: text)
                .font(.system(size: 14)).foregroundColor(C.text).keyboardType(keyboard)
        }
        .padding(.vertical, 13).padding(.horizontal, 14)
        .background(C.surface).cornerRadius(Radii.md)
        .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))
    }

    private var bankPickerSheet: some View {
        NavigationStack {
            List(BankId.allCases.filter { $0 != .unknown && $0 != .cash }, id: \.self) { bankId in
                Button(action: { selectedBank = bankId; showBankPicker = false }) {
                    HStack(spacing: 12) {
                        BankBadgeView(bank: bankId, size: 36)
                        Text(bankId.meta.name).font(.system(size: 14)).foregroundColor(.primary)
                        Spacer()
                        if selectedBank == bankId {
                            Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar banco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { showBankPicker = false }
                }
            }
        }
    }

    private func handleSave() {
        loading = true
        // TODO: POST /accounts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            loading = false
            appState.isSignedIn = true; appState.needsOnboarding = false
        }
    }
}
