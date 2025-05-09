import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Environment(\.isPreview) private var isPreview
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var isLoading: Bool = false
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
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
        emailError = isEmailValid ? "" : "Please enter a valid email address"
    }
    
    private func validatePassword() {
        isPasswordValid = password.count >= 8
        passwordError = isPasswordValid ? "" : "Password must be at least 8 characters long"
    }
    
    private func isFormValid() -> Bool {
        return isEmailValid && isPasswordValid
    }
    
    private func handleSignIn() {
        guard !isPreview else { return }
        
        isLoading = true
        Task {
            do {
                try await signIn()
            } catch {
                await handleError(error)
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func signIn() async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                authViewModel.isAuthenticated = true
                UserDefaults.standard.set(result.user.uid, forKey: "currentUserId")
            }
        } catch {
            throw error
        }
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            if let authError = error as? AuthErrorCode {
                switch authError.code {
                case .wrongPassword:
                    errorMessage = "Incorrect password. Please try again."
                case .invalidEmail:
                    errorMessage = "Invalid email address."
                case .userNotFound:
                    errorMessage = "No account found with this email."
                default:
                    errorMessage = "An error occurred. Please try again."
                }
            } else {
                errorMessage = "An error occurred. Please try again."
            }
            showError = true
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                await MainActor.run {
                    showForgotPassword = false
                    errorMessage = "Password reset email sent. Please check your inbox."
                    showError = true
                }
            } catch {
                await handleError(error)
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 24)
                // Logo and Title
                VStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .resizable()
                        .frame(width: 40, height: 32)
                        .foregroundColor(Color.blue)
                    Text("Plateify")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.blue)
                }
                
                Text("Bine ai revenit!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Introdu adresa de email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Text("Parolă")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Introdu parola", text: $password)
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
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
                    if isLoading {
                        ProgressView()
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
                .disabled(isLoading)
                
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
                    Text("Sau continuă cu")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
                }
                
                HStack(spacing: 16) {
                    Button(action: { /* TODO: Google sign in */ }) {
                        HStack {
                            Image(systemName: "g.circle")
                            Text("Google")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    Button(action: { /* TODO: Apple sign in */ }) {
                        HStack {
                            Image(systemName: "applelogo")
                            Text("Apple")
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
}

#Preview {
    SignInView()
        .environment(\.isPreview, true)
        .environmentObject(AuthenticationViewModel())
} 