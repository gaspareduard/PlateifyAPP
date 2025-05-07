import SwiftUI

struct SignInView: View {
    @Environment(\.isPreview) private var isPreview
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showForgotPasswordAlert: Bool = false
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showPassword: Bool = true
    
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
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Sign in")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                VStack(spacing: 10) {
                    CustomFormField(value: $email, icon: "at", isSecure: false, placeHolder: "Email")
                        .onChange(of: email) { oldValue, newValue in
                            validateEmail()
                        }
                    if !emailError.isEmpty {
                        Text(emailError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    ZStack(alignment: .trailing) {
                        CustomFormField(value: $password, icon: "lock", isSecure: showPassword, placeHolder: "Password")
                            .onChange(of: password) { oldValue, newValue in
                                validatePassword()
                            }
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .accentColor(.gray)
                        }.padding(.horizontal)
                    }
                    if !passwordError.isEmpty {
                        Text(passwordError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                VStack {
                    Button(action: {
                        // Temporarily disabled Firebase signin
                        // Task {
                        //     do {
                        //         try await authViewModel.signIn(email: email, password: password)
                        //     } catch {
                        //         showError = true
                        //     }
                        // }
                        isLoading = true
                        // Simulate network delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign in")
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(primaryColor: .white, accentColor: .blue))
                    .disabled(!isFormValid() || isLoading)
                    
                    Text("Forgot Password?")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showForgotPasswordAlert = true
                        }
                }
                
                Spacer()
                
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign up")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("An error occurred")
            }
            .alert("Reset Password", isPresented: $showForgotPasswordAlert) {
                TextField("Enter your email", text: $email)
                Button("Cancel", role: .cancel) { }
                Button("Send Reset Link") {
                    if !isPreview {
                        // Temporarily disabled Firebase reset password
                        // Task {
                        //     do {
                        //         try await authViewModel.resetPassword(email: email)
                        //     } catch {
                        //         showError = true
                        //     }
                        // }
                        isLoading = true
                        // Simulate network delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
                }
            } message: {
                Text("We'll send you a link to reset your password")
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(\.isPreview, true)
} 