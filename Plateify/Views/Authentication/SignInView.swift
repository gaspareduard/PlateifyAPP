import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Environment(\.isPreview) private var isPreview
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showPassword: Bool = true
    @State private var goToSignUp: Bool = false
    
    // Validation states
    @State private var isEmailValid: Bool = false
    @State private var isPasswordValid: Bool = false
    
    // Error messages
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        isEmailValid = isValid
        emailError = isValid ? "" : "Adresa de email nu este validă"
    }
    
    private func validatePassword() {
        let valid = password.count >= 8
        isPasswordValid = valid
        passwordError = valid ? "" : "Parola trebuie să aibă cel puțin 8 caractere"
    }
    
    private func isFormValid() -> Bool {
        return isEmailValid && isPasswordValid
    }
    
    private func handleSignIn() {
        Task {
            do {
                try await authViewModel.signIn(email: email, password: password)
            } catch {
                authViewModel.error = error
            }
        }
    }
    
    private func signIn() async throws {
        do {
            try await authViewModel.signIn(email: email, password: password)
        } catch {
            authViewModel.error = error
        }
    }
    
    
    private func resetPassword() async throws {
        do {
            try await authViewModel.resetPassword(email: email)
        } catch {
            authViewModel.error = error
        }
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 24)
                
                // Logo and Title
                LogoAndText()
                
                                
                VStack(alignment: .leading, spacing: 12) {
                    EmailField(email: $email, error: $emailError, onValidate: validateEmail)
                    
                    PasswordField(password: $password, error: $passwordError, onValidate: validatePassword)
                }
                
                HStack {
                    Toggle(isOn: $rememberMe) {
                        Text("Ține-mă minte")
                            .font(.subheadline)
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .frame(width: 140, alignment: .leading)
                    Spacer()
                    Button("Ai uitat parola?") {
                        showForgotPassword = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                
                Button(action: handleSignIn) {
                    if authViewModel.isLoading {
                        LoadingView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Conectare")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(authViewModel.isLoading)
                
                DividerSignIn()
                
                // Social Buttons
                HStack(spacing: 16) {
                    SocialButton(icon: "g.circle", text: "Google") {}
                    SocialButton(icon: "applelogo", text: "Apple") {}
                }
                .padding(.horizontal, 24)
                
                HStack {
                    Text("Nu ai cont?")
                    NavigationLink(destination: SignUpView().environmentObject(authViewModel), isActive: $goToSignUp) {
                        Button("Înregistrează-te") {
                            goToSignUp = true
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
            .alert("Recuperare parolă", isPresented: $showForgotPassword) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Funcționalitatea de recuperare a parolei nu este implementată încă.")
            }
        }
    }
    
    private struct EmailField: View {
        @Binding var email: String
        @Binding var error: String
        let onValidate: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Email").font(.subheadline).fontWeight(.medium)
                HStack {
                    Image(systemName: "envelope").foregroundColor(.gray)
                    TextField("Introdu adresa de email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: email) { _ in onValidate() }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                if !error.isEmpty {
                    Text(error).font(.caption).foregroundColor(.red)
                }
            }
        }
    }
    
    private struct PasswordField: View {
        @Binding var password: String
        @Binding var error: String
        let onValidate: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Parolă").font(.subheadline).fontWeight(.medium)
                HStack {
                    Image(systemName: "lock").foregroundColor(.gray)
                    SecureField("Introdu parola", text: $password)
                        .onChange(of: password) { _ in onValidate() }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                if !error.isEmpty {
                    Text(error).font(.caption).foregroundColor(.red)
                }
            }
        }
    }
    
    private struct SocialButton: View {
        let icon: String, text: String, action: () -> Void
        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                    Text(text)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
    }
    
    
}

#Preview {
    SignInView()
        .environment(\.isPreview, true)
        .environmentObject(AuthenticationViewModel())
} 

extension SignInView{
    struct DividerSignIn: View {
        var body: some View {
            HStack {
                Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
                Text("Sau continuă cu")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
            }
        }
    }
    
    struct LogoAndText: View {
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: "car.fill")
                    .resizable()
                    .frame(width: 40, height: 32)
                    .foregroundColor(Color.blue)
                
                Text("Plateify")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.blue)
                
                Text("Bine ai revenit!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
            }
        }
    }
    
}


