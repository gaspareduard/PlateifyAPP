//
//  SignUpView.swift
//  Plateify
//
//  Created by Eduard Gaspar on 28.03.2025.
//

import SwiftUI

struct SignUpView:View {
    @Environment(\.isPreview) private var isPreview
    // @StateObject private var authViewModel = AuthenticationViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var confirmPassword: String = ""
    @State private var showTermsOfService: Bool = false
    @State private var showError: Bool = false
    @State private var showForgotPasswordAlert: Bool = false
    @State private var isLoading: Bool = false
    
    // Validation states
    @State private var isEmailValid: Bool = false
    @State private var isPasswordValid: Bool = false
    @State private var isFirstNameValid: Bool = false
    @State private var isLastNameValid: Bool = false
    @State private var doPasswordsMatch: Bool = false
    
    // Error messages
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var firstNameError: String = ""
    @State private var lastNameError: String = ""
    @State private var confirmPasswordError: String = ""
    
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
        emailError = isEmailValid ? "" : "Please enter a valid email address"
    }
    
    private func validatePassword() {
        // Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        isPasswordValid = passwordPredicate.evaluate(with: password)
        passwordError = isPasswordValid ? "" : "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number"
    }
    
    private func validateNames() {
        isFirstNameValid = firstName.count >= 2 && firstName.count <= 50
        firstNameError = isFirstNameValid ? "" : "First name must be between 2 and 50 characters"
        
        isLastNameValid = lastName.count >= 2 && lastName.count <= 50
        lastNameError = isLastNameValid ? "" : "Last name must be between 2 and 50 characters"
    }
    
    private func validatePasswordMatch() {
        doPasswordsMatch = password == confirmPassword
        confirmPasswordError = doPasswordsMatch ? "" : "Passwords do not match"
    }
    
    private func isFormValid() -> Bool {
        return isEmailValid && isPasswordValid && isFirstNameValid && isLastNameValid && doPasswordsMatch
    }
    
    // Commented out Firebase-related function
    /*
    private func handleSignUp() async {
        if isFormValid() {
            do {
                try await authViewModel.signUp(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )
                // Handle successful sign up (e.g., navigate to main app)
            } catch {
                showError = true
            }
        }
    }
    */
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Sign up")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Fields(firstName: $firstName, lastName: $lastName, email: $email, password: $password, confirmPassword: $confirmPassword,
                      firstNameError: firstNameError, lastNameError: lastNameError, emailError: emailError,
                      passwordError: passwordError, confirmPasswordError: confirmPasswordError,
                      onFirstNameChange: validateNames,
                      onLastNameChange: validateNames,
                      onEmailChange: validateEmail,
                      onPasswordChange: { 
                          validatePassword()
                          validatePasswordMatch()
                      },
                      onConfirmPasswordChange: validatePasswordMatch)
                
                Spacer()
                
                VStack{
                    Button(action: {
                        // Temporarily disabled Firebase signup
                        // Task {
                        //     await handleSignUp()
                        // }
                        isLoading = true
                        // Simulate network delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }) {
                        HStack(){
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create account")
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(primaryColor: .white, accentColor: .blue))
                    .disabled(!isFormValid() || isLoading)
                    
                    Text("By creating an account you agree to our")
                        .font(.caption)
                    
                    Text("Terms of Service")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showTermsOfService = true
                        }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .sheet(isPresented: $showTermsOfService) {
                TermsOfServiceView(isPresented: $showTermsOfService)
            }
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

struct TermsOfServiceView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.title)
                        .bold()
                        .padding(.bottom)
                    
                    Group {
                        Text("1. Acceptance of Terms")
                            .font(.headline)
                        Text("By accessing and using Plateify, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, please do not use our service.")
                        
                        Text("2. Service Description")
                            .font(.headline)
                        Text("Plateify is a social networking platform that connects users based on their vehicle license plates. The service allows users to create profiles, interact with other users, and share information about their vehicles.")
                        
                        Text("3. User Accounts")
                            .font(.headline)
                        Text("• You must be at least 18 years old to create an account\n• You are responsible for maintaining the confidentiality of your account\n• You must provide accurate and complete information\n• You are responsible for all activities that occur under your account")
                        
                        Text("4. Privacy and Data Protection")
                            .font(.headline)
                        Text("• We collect and process personal information as described in our Privacy Policy\n• We implement security measures to protect your data\n• We do not share your personal information with third parties without your consent")
                        
                        Text("5. License Plate Information")
                            .font(.headline)
                        Text("• Users must only share license plate information that they own or have permission to share\n• Users are responsible for the accuracy of the license plate information they provide\n• Users must respect privacy and not misuse license plate information")
                        
                        Text("6. User Conduct")
                            .font(.headline)
                        Text("• Users must not engage in any illegal activities\n• Users must not harass, abuse, or harm other users\n• Users must not post false or misleading information\n• Users must not use the service for commercial purposes without authorization")
                        
                        Text("7. Content Guidelines")
                            .font(.headline)
                        Text("• All content must be appropriate and respectful\n• Users must not post offensive or inappropriate content\n• Users must respect intellectual property rights")
                        
                        Text("8. Termination")
                            .font(.headline)
                        Text("We reserve the right to terminate or suspend your account for violations of these terms or for any other reason at our discretion.")
                        
                        Text("9. Changes to Terms")
                            .font(.headline)
                        Text("We may modify these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms.")
                    }
                    .padding(.bottom, 5)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

#Preview {
    SignUpView()
        .environment(\.isPreview, true)
}

extension SignUpView {
    struct Fields: View {
        @Binding var firstName: String
        @Binding var lastName: String
        @Binding var email: String
        @State private var showPassowrd:Bool = true
        @Binding var password: String
        @Binding var confirmPassword: String
        let firstNameError: String
        let lastNameError: String
        let emailError: String
        let passwordError: String
        let confirmPasswordError: String
        let onFirstNameChange: () -> Void
        let onLastNameChange: () -> Void
        let onEmailChange: () -> Void
        let onPasswordChange: () -> Void
        let onConfirmPasswordChange: () -> Void
        
        var body: some View {
            VStack(spacing: 10){
                CustomFormField(value: $firstName, icon: "person", isSecure: false, placeHolder: "First name")
                    .onChange(of: firstName) { oldValue, newValue in
                        onFirstNameChange()
                    }
                if !firstNameError.isEmpty {
                    Text(firstNameError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                CustomFormField(value: $lastName, icon: "person.fill", isSecure: false, placeHolder: "Last name")
                    .onChange(of: lastName) { oldValue, newValue in
                        onLastNameChange()
                    }
                if !lastNameError.isEmpty {
                    Text(lastNameError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                CustomFormField(value: $email, icon: "at", isSecure: false, placeHolder: "Email")
                    .onChange(of: email) { oldValue, newValue in
                        onEmailChange()
                    }
                if !emailError.isEmpty {
                    Text(emailError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                ZStack(alignment: .trailing){
                    CustomFormField(value: $password, icon: "lock", isSecure: showPassowrd, placeHolder: "Password")
                        .onChange(of: password) { oldValue, newValue in
                            onPasswordChange()
                        }
                    Button {
                        showPassowrd.toggle()
                    } label: {
                        Image(systemName: self.showPassowrd ? "eye.slash" : "eye")
                            .accentColor(.gray)
                    }.padding(.horizontal)
                }
                if !passwordError.isEmpty {
                    Text(passwordError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                ZStack(alignment: .trailing){
                    CustomFormField(value: $confirmPassword, icon: "lock.fill", isSecure: showPassowrd, placeHolder: "Confirm Password")
                        .onChange(of: confirmPassword) { oldValue, newValue in
                            onConfirmPasswordChange()
                        }
                    Button {
                        showPassowrd.toggle()
                    } label: {
                        Image(systemName: self.showPassowrd ? "eye.slash" : "eye")
                            .accentColor(.gray)
                    }.padding(.horizontal)
                }
                if !confirmPasswordError.isEmpty {
                    Text(confirmPasswordError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
    }
}

private struct IsPreviewKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewKey.self] }
        set { self[IsPreviewKey.self] = newValue }
    }
}


