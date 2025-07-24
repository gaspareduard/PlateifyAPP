//
//  SignUpView.swift
//  Plateify
//
//  Created by Eduard Gaspar on 28.03.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Environment(\.isPreview) private var isPreview
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form State
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false

    // MARK: - Validation & Errors
    @State private var firstNameError = ""
    @State private var lastNameError = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    private var isFormValid: Bool {
        [firstNameError, lastNameError, emailError, passwordError, confirmPasswordError]
            .allSatisfy(
                { $0.isEmpty }
            ) && agreedToTerms
    }
    
    private func validateEmail() {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let valid = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
        emailError = valid ? "" : "Adresa de email nu este validă"
    }
    
    private func validatePassword() {
        let pattern = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let valid = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: password)
        passwordError = valid ? "" : "Parola trebuie să aibă minim 8 caractere, literă mare și cifră"
    }
    
    private func validateFirstName() {
        firstNameError = (2...50).contains(firstName.count) ? "" : "Prenumele trebuie să aibă între 2 și 50 de caractere"
    }

    private func validateLastName() {
        lastNameError = (2...50).contains(lastName.count) ? "" : "Numele trebuie să aibă între 2 și 50 de caractere"
    }
    
    private func validateConfirmPassword() {
        confirmPasswordError = (password == confirmPassword) ? "" : "Parolele nu coincid"
    }
    
    
    private func signUp() {
        Task {
            do {
                try await authViewModel.signUp(
                    email: email,
                    password: password,
                    username: email.components(separatedBy: "@").first ?? "",
                    firstName: firstName,
                    lastName: lastName
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
    

    
    var body: some View {
        NavigationStack {
            VStack() {
                VStack(spacing: 24) {
                    
                    // Title and subtitle
                    SignUpViewTitle()
                    
                    // Form fields
                    VStack(spacing: 16) {
                        TextFieldView(label: "Prenume", text: $firstName, error: $firstNameError, onChange: validateFirstName)
                        TextFieldView(label: "Nume", text: $lastName, error: $lastNameError, onChange: validateLastName)
                        EmailField(email: $email, error: $emailError, onValidate: validateEmail)
                        PasswordField(password: $password, error: $passwordError, onValidate: validatePassword)
                        PasswordField(label: "Confirmă parola", password: $confirmPassword, error: $confirmPasswordError, onValidate: validateConfirmPassword)
                    }
                                        
                    
                    // Terms and conditions
                    TermsToggle(isOn: $agreedToTerms)
                                        
                    
                    // Sign up button
                    SignUpButton(
                        isLoading:authViewModel.isLoading,
                        isFormValid: isFormValid,
                        action: signUp
                    )
                    
                    // Social sign up
                    SocialSignUpView()
                    
                    // Sign in link
                    HStack {
                        Text("Ai deja un cont?")
                        Button("Conectează-te") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
            .alert("Eroare", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { showErrorAlert = false }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

// Custom error type for sign-up specific errors
enum SignUpError: Error {
    case plateNumberAlreadyExists
}

extension SignUpView {
    struct Fields: View {
        @Binding var firstName: String
        @Binding var lastName: String
        @Binding var email: String
        @Binding var plateNumbers: [String]
        @Binding var password: String
        @Binding var confirmPassword: String
        @Binding var showPassword: Bool
        
        let firstNameError: String
        let lastNameError: String
        let emailError: String
        let plateNumberError: String
        let passwordError: String
        let confirmPasswordError: String
        
        let onFirstNameChange: () -> Void
        let onLastNameChange: () -> Void
        let onEmailChange: () -> Void
        let onPlateNumbersChange: () -> Void
        let onPasswordChange: () -> Void
        let onConfirmPasswordChange: () -> Void
        
        var body: some View {
            VStack(spacing: 10) {
                CustomFormField(value: $firstName, icon: "person", isSecure: false, placeHolder: "First name")
                    .onChange(of: firstName) { oldValue, newValue in
                        onFirstNameChange()
                    }
                    .textInputAutocapitalization(.words)
                if !firstNameError.isEmpty {
                    Text(firstNameError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                CustomFormField(value: $lastName, icon: "person.fill", isSecure: false, placeHolder: "Last name")
                    .onChange(of: lastName) { oldValue, newValue in
                        onLastNameChange()
                    }
                    .textInputAutocapitalization(.words)
                if !lastNameError.isEmpty {
                    Text(lastNameError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                CustomFormField(value: $email, icon: "at", isSecure: false, placeHolder: "Email")
                    .onChange(of: email) { oldValue, newValue in
                        onEmailChange()
                    }
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if !emailError.isEmpty {
                    Text(emailError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                NumberPlateInputView(plateNumber: $plateNumbers[0])
                if !plateNumberError.isEmpty {
                    Text(plateNumberError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                ZStack(alignment: .trailing) {
                    CustomFormField(value: $password, icon: "lock", isSecure: showPassword, placeHolder: "Password")
                        .onChange(of: password) { oldValue, newValue in
                            onPasswordChange()
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
                
                ZStack(alignment: .trailing) {
                    CustomFormField(value: $confirmPassword, icon: "lock.fill", isSecure: showPassword, placeHolder: "Confirm Password")
                        .onChange(of: confirmPassword) { oldValue, newValue in
                            onConfirmPasswordChange()
                        }
                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
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

#Preview {
    SignUpView()
        .environment(\.isPreview, true)
        .environmentObject(AuthenticationViewModel())
}

struct TermsOfServiceView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.title)
                        .bold()
                        .padding(.bottom)
                    
                    Group {
                        Text("1. Acceptance of Terms")
                            .font(.headline)
                        Text("By accessing and using Plateify, you agree to be bound by these Terms of Service and all applicable laws and regulations.")
                        
                        Text("2. User Accounts")
                            .font(.headline)
                        Text("You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.")
                        
                        Text("3. Privacy")
                            .font(.headline)
                        Text("Your use of Plateify is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices.")
                        
                        Text("4. User Content")
                            .font(.headline)
                        Text("You retain all rights to any content you submit, post or display on Plateify. By submitting content, you grant Plateify a worldwide, non-exclusive license to use, copy, modify, and distribute your content.")
                    }
                    
                    Group {
                        Text("5. Prohibited Activities")
                            .font(.headline)
                        Text("You agree not to engage in any of the following activities:\n- Violating laws or regulations\n- Impersonating others\n- Interfering with the operation of the service\n- Collecting user information without consent")
                        
                        Text("6. Termination")
                            .font(.headline)
                        Text("We reserve the right to terminate or suspend your account at any time for any reason without notice.")
                    }
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
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

private struct TextFieldView: View {
    let label: String
    @Binding var text: String
    @Binding var error: String
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline).fontWeight(.medium)
            TextField(label, text: $text)
                .autocapitalization(.words).disableAutocorrection(true)
                .padding(12).background(Color(.systemGray6)).cornerRadius(8)
                .onChange(of: text) { _ in onChange() }
            if !error.isEmpty { Text(error).font(.caption).foregroundColor(.red) }
        }
    }
}

private struct PasswordField: View {
    var label: String = "Parolă"
    @Binding var password: String
    @Binding var error: String
    let onValidate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.subheadline).fontWeight(.medium)
            HStack {
                Image(systemName: "lock").foregroundColor(.gray)
                SecureField(label, text: $password)
                    .onChange(of: password) { _ in onValidate() }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            if !error.isEmpty { Text(error).font(.caption).foregroundColor(.red) }
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
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: email) { _ in onValidate() }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            if !error.isEmpty { Text(error).font(.caption).foregroundColor(.red) }
        }
    }
}

private struct TermsToggle: View {
    @Binding var isOn: Bool
    var body: some View {
        Toggle(isOn: $isOn) {
            Text("Sunt de acord cu Termenii și Condițiile și Politica de Confidențialitate")
                .font(.footnote)
        }
        .toggleStyle(CheckboxToggleStyle())
    }
}

private struct TermsAndConditionsView: View {
    @Binding var agreedToTerms: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            Toggle(isOn: $agreedToTerms) {
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Text("Sunt de acord cu ")
                        Button("Termenii și Condițiile") {}
                            .foregroundColor(.blue)
                        Text("și")
                    }
                    Button("Politica de Confidențialitate") {}
                        .foregroundColor(.blue)
                }
                .font(.footnote)
            }
            .toggleStyle(CheckboxToggleStyle())
            Spacer()
        }
        .padding(.top, 4)
    }
}

private struct SignUpButton: View {
    let isLoading: Bool
    let isFormValid: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Creează Cont")
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isFormValid ? Color.blue : Color(.systemGray4))
        .foregroundColor(.white)
        .cornerRadius(8)
        .disabled(!isFormValid || isLoading)
    }
}

private struct SocialSignUpView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
                Text("Sau continuă cu")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
            }
            
            HStack(spacing: 16) {
                SocialButton(icon: "g.circle", text: "Google") {
                    // TODO: Google sign up
                }
                SocialButton(icon: "applelogo", text: "Apple") {
                    // TODO: Apple sign up
                }
            }
        }
    }
}

private struct SocialButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
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


extension SignUpView{
    struct SignUpViewTitle: View {
        var body: some View {
            VStack(spacing: 4) {
                Text("Creează Cont")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Conectează-te cu șoferii din jurul tău")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}


