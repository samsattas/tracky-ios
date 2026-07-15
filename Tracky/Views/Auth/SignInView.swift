import SwiftUI

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var session:  SessionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    private var C: AppColors { scheme == .dark ? .dark : .light }

    @State private var email    = ""
    @State private var password = ""
    @State private var showPass = false
    @State private var loading  = false
    @State private var error    = ""
    // Second factor (new-device verification): non-nil while waiting for the email code
    @State private var signInId = ""
    @State private var code     = ""

    private var needsCode: Bool { !signInId.isEmpty }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                LogoView(size: 22)
                    .padding(.top, 4)

                Text("Bienvenido de vuelta")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.6)
                    .foregroundColor(C.text)
                    .padding(.top, 4)

                Text("Ingresa a tu cuenta Tracky")
                    .font(.system(size: 13.5))
                    .foregroundColor(C.textMuted)
                    .padding(.bottom, 4)

                if needsCode {
                    // Second factor: email code sent to verify this device
                    Text("Te enviamos un código a \(email)")
                        .font(.system(size: 13))
                        .foregroundColor(C.textMuted)

                    inputField(
                        icon: "key.fill",
                        placeholder: "Código de 6 dígitos",
                        text: $code,
                        keyboard: .numberPad
                    )
                } else {
                    // Google button
                    googleButton

                    divider

                    // Email field
                    inputField(
                        icon: "envelope.fill",
                        placeholder: "tu@email.com",
                        text: $email,
                        keyboard: .emailAddress,
                        autoCapitalize: .never
                    )

                    // Password field
                    passwordField
                }

                if !error.isEmpty {
                    Text(error)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundColor(C.expense)
                }

                // Sign in / verify button
                Button(action: needsCode ? handleVerifyCode : handleSignIn) {
                    HStack {
                        Spacer()
                        if loading {
                            ProgressView().tint(.white)
                        } else {
                            Text(needsCode ? "Verificar" : "Ingresar")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(C.primaryFg)
                        }
                        Spacer()
                    }
                    .frame(height: 52)
                    .background(C.primary)
                    .cornerRadius(Radii.md)
                }
                .disabled(loading)

                HStack {
                    Spacer()
                    Text("¿No tienes cuenta? ")
                        .font(.system(size: 13))
                        .foregroundColor(C.textMuted)
                    NavigationLink(destination: SignUpView()) {
                        Text("Regístrate")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(C.primary)
                    }
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .background(C.bg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }

    // MARK: - Subviews

    private var googleButton: some View {
        Button(action: handleGoogleSignIn) {
            HStack(spacing: 10) {
                Spacer()
                Image(systemName: "globe")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(C.text)
                Text("Continuar con Google")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(C.text)
                Spacer()
            }
            .frame(height: 50)
            .background(C.surface)
            .cornerRadius(Radii.md)
            .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))
        }
    }

    private var divider: some View {
        HStack(spacing: 10) {
            Rectangle().fill(C.border).frame(height: 1)
            Text("o")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(C.textMuted)
            Rectangle().fill(C.border).frame(height: 1)
        }
    }

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        autoCapitalize: TextInputAutocapitalization = .sentences
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(C.textMuted)
            TextField(placeholder, text: text)
                .font(.system(size: 14))
                .foregroundColor(C.text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autoCapitalize)
                .autocorrectionDisabled()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(C.surface)
        .cornerRadius(Radii.md)
        .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))
    }

    private var passwordField: some View {
        HStack(spacing: 10) {
            Button(action: { showPass.toggle() }) {
                Image(systemName: showPass ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 15))
                    .foregroundColor(C.textMuted)
            }
            if showPass {
                TextField("Contraseña", text: $password)
                    .font(.system(size: 14))
                    .foregroundColor(C.text)
            } else {
                SecureField("Contraseña", text: $password)
                    .font(.system(size: 14))
                    .foregroundColor(C.text)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(C.surface)
        .cornerRadius(Radii.md)
        .overlay(RoundedRectangle(cornerRadius: Radii.md).stroke(C.border, lineWidth: 1))
    }

    // MARK: - Actions

    private func handleSignIn() {
        guard !email.isEmpty && !password.isEmpty else { error = "Completa todos los campos"; return }
        loading = true; error = ""
        Task {
            do {
                switch try await ClerkService.shared.signIn(email: email, password: password) {
                case .complete(let token, let userId, let firstName):
                    session.signIn(token: token, userId: userId, firstName: firstName)
                case .needsSecondFactor(let id):
                    // New device: Clerk requires an email code — send it and show the code field
                    try await ClerkService.shared.prepareSecondFactor(signInId: id)
                    signInId = id
                }
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }

    private func handleVerifyCode() {
        guard !code.isEmpty else { error = "Ingresa el código"; return }
        loading = true; error = ""
        Task {
            do {
                let (token, userId, firstName) = try await ClerkService.shared.attemptSecondFactor(signInId: signInId, code: code)
                session.signIn(token: token, userId: userId, firstName: firstName)
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }

    private func handleGoogleSignIn() {
        // Google OAuth requires ASWebAuthenticationSession — coming soon
        error = "Usa email y contraseña por ahora"
    }
}
