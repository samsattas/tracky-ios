import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var session:  SessionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var showPass = false
    @State private var loading  = false
    @State private var error    = ""
    @State private var step: Step = .form

    // Verification step
    @State private var code     = ""
    @State private var signUpId = ""

    enum Step { case form, verify }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                LogoView(size: 22).padding(.top, 4)

                if step == .form {
                    formStep
                } else {
                    verifyStep
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .background(C.bg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Form Step

    private var formStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Crea tu cuenta")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.6)
                .foregroundColor(C.text)
                .padding(.top, 4)
            Text("Empieza gratis, sin tarjeta")
                .font(.system(size: 13.5))
                .foregroundColor(C.textMuted)
                .padding(.bottom, 4)

            googleButton

            divider

            inputRow(icon: "person.fill",    placeholder: "Nombre completo",  text: $name)
            inputRow(icon: "envelope.fill",  placeholder: "tu@email.com",      text: $email,    keyboard: .emailAddress, autoCapitalize: .never)

            HStack(spacing: 10) {
                Button(action: { showPass.toggle() }) {
                    Image(systemName: showPass ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15)).foregroundColor(C.textMuted)
                }
                if showPass {
                    TextField("Contraseña", text: $password)
                        .font(.system(size: 14)).foregroundColor(C.text)
                } else {
                    SecureField("Contraseña", text: $password)
                        .font(.system(size: 14)).foregroundColor(C.text)
                }
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
            .background(C.surface).cornerRadius(Radii.md)
            .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))

            if !error.isEmpty {
                Text(error).font(.system(size: 12.5, weight: .medium)).foregroundColor(C.expense)
            }

            Button(action: handleRegister) {
                HStack { Spacer()
                    if loading { ProgressView().tint(.white) }
                    else { Text("Crear cuenta").font(.system(size: 16, weight: .bold)).foregroundColor(C.primaryFg) }
                    Spacer() }
                .frame(height: 52).background(C.primary).cornerRadius(Radii.md)
            }
            .disabled(loading)

            HStack {
                Spacer()
                Text("¿Ya tienes cuenta? ").font(.system(size: 13)).foregroundColor(C.textMuted)
                NavigationLink(destination: SignInView()) {
                    Text("Ingresar").font(.system(size: 13, weight: .bold)).foregroundColor(C.primary)
                }
                Spacer()
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Verify Step

    private var verifyStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(C.primarySoft)
                    .frame(width: 56, height: 56)
                Image(systemName: "shield.checkered")
                    .font(.system(size: 26)).foregroundColor(C.primary)
            }
            .padding(.top, 16)

            Text("Verifica tu correo")
                .font(.system(size: 26, weight: .heavy)).tracking(-0.6).foregroundColor(C.text)
            Text("Enviamos un código de 6 dígitos a \(email)")
                .font(.system(size: 13.5)).foregroundColor(C.textMuted)

            TextField("000000", text: $code)
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
                .tracking(6)
                .keyboardType(.numberPad)
                .padding(.vertical, 14).padding(.horizontal, 14)
                .background(C.surface).cornerRadius(Radii.md)
                .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))

            if !error.isEmpty {
                Text(error).font(.system(size: 12.5, weight: .medium)).foregroundColor(C.expense)
            }

            Button(action: handleVerify) {
                HStack { Spacer()
                    if loading { ProgressView().tint(.white) }
                    else { Text("Verificar").font(.system(size: 16, weight: .bold)).foregroundColor(C.primaryFg) }
                    Spacer() }
                .frame(height: 52).background(C.primary).cornerRadius(Radii.md)
            }
            .disabled(loading)
        }
    }

    // MARK: - Helpers

    private var googleButton: some View {
        Button(action: handleGoogleSignUp) {
            HStack(spacing: 10) {
                Spacer()
                Image(systemName: "globe").font(.system(size: 16, weight: .medium)).foregroundColor(C.text)
                Text("Continuar con Google").font(.system(size: 15, weight: .semibold)).foregroundColor(C.text)
                Spacer()
            }
            .frame(height: 50).background(C.surface).cornerRadius(Radii.md)
            .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))
        }
    }

    private var divider: some View {
        HStack(spacing: 10) {
            Rectangle().fill(C.border).frame(height: 1)
            Text("o").font(.system(size: 12, weight: .medium)).foregroundColor(C.textMuted)
            Rectangle().fill(C.border).frame(height: 1)
        }
    }

    private func inputRow(
        icon: String, placeholder: String, text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        autoCapitalize: TextInputAutocapitalization = .sentences
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 15)).foregroundColor(C.textMuted)
            TextField(placeholder, text: text)
                .font(.system(size: 14)).foregroundColor(C.text)
                .keyboardType(keyboard).textInputAutocapitalization(autoCapitalize).autocorrectionDisabled()
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
        .background(C.surface).cornerRadius(Radii.md)
        .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))
    }

    // MARK: - Actions

    private func handleRegister() {
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
            error = "Completa todos los campos"; return
        }
        loading = true; error = ""
        Task {
            do {
                let parts     = name.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
                let firstName = parts.first ?? name
                let lastName  = parts.count > 1 ? parts.dropFirst().joined(separator: " ") : ""
                let id = try await ClerkService.shared.signUp(firstName: firstName, lastName: lastName, email: email, password: password)
                signUpId = id
                try await ClerkService.shared.prepareVerification(signUpId: id)
                step = .verify
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }

    private func handleVerify() {
        guard code.count == 6 else { error = "El código debe tener 6 dígitos"; return }
        loading = true; error = ""
        Task {
            do {
                let (token, userId) = try await ClerkService.shared.attemptVerification(signUpId: signUpId, code: code)
                session.signIn(token: token, userId: userId)
                appState.needsOnboarding = true
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }

    private func handleGoogleSignUp() {
        error = "Usa email y contraseña por ahora"
    }
}
