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
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var plateNumbers: [String] = []
    @State private var confirmPassword: String = ""
    @State private var showTermsOfService: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var goToSignIn: Bool = false
    @State private var agreedToTerms: Bool = false
    
    // Validation states
    @State private var isEmailValid: Bool = false
    @State private var isPasswordValid: Bool = false
    @State private var isFirstNameValid: Bool = false
    @State private var isLastNameValid: Bool = false
    @State private var isPlateNumberValid: Bool = true // Default to true since it's optional
    @State private var doPasswordsMatch: Bool = false
    
    // Error messages
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var firstNameError: String = ""
    @State private var lastNameError: String = ""
    @State private var plateNumberError: String = ""
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
    
    private func validatePlateNumbers() {
        // If plateNumbers is empty, it's valid (since it's optional)
        if plateNumbers.isEmpty {
            isPlateNumberValid = true
            plateNumberError = ""
            return
        }
        // Only validate if a plate number is provided
        let plateRegex = "^[A-Z0-9]{1,8}$"
        let platePredicate = NSPredicate(format: "SELF MATCHES %@", plateRegex)
        isPlateNumberValid = plateNumbers.allSatisfy { platePredicate.evaluate(with: $0.uppercased()) }
        plateNumberError = isPlateNumberValid ? "" : "Please enter a valid plate number or leave it empty"
    }
    
    private func validatePasswordMatch() {
        doPasswordsMatch = password == confirmPassword
        confirmPasswordError = doPasswordsMatch ? "" : "Passwords do not match"
    }
    
    private func isFormValid() -> Bool {
        return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword && agreedToTerms
    }
    
    private func handleSignUp() {
        guard !isPreview else { return }
        
        isLoading = true
        Task {
            do {
                try await signUp()
            } catch {
                await handleError(error)
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func signUp() async throws {
        do {
            // Only check for existing plate numbers if one is provided
            if !plateNumbers.isEmpty {
                let db = Firestore.firestore()
                let plateQuery = try await db.collection("users")
                    .whereField("plateNumbers", arrayContainsAny: plateNumbers.map { $0.uppercased() })
                    .getDocuments()
                
                guard plateQuery.documents.isEmpty else {
                    throw SignUpError.plateNumberAlreadyExists
                }
            }
            
            // Create the user account
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create the user profile in Firestore
            let db = Firestore.firestore()
            var userData: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "createdAt": FieldValue.serverTimestamp(),
                "isOnline": true,
                "lastSeen": FieldValue.serverTimestamp(),
                "profileImageURL": "",
                "bio": "",
                "friends": [],
                "friendRequests": [],
                "blockedUsers": [],
                "privacySettings": [
                    "showPlateNumber": true,
                    "showOnlineStatus": true,
                    "allowFriendRequests": true
                ]
            ]
            
            // Only add plate numbers if one is provided
            if !plateNumbers.isEmpty {
                userData["plateNumbers"] = plateNumbers.map { $0.uppercased() }
            }
            
            try await db.collection("users").document(result.user.uid).setData(userData)
            
            // Update the auth state
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
            if let signUpError = error as? SignUpError {
                switch signUpError {
                case .plateNumberAlreadyExists:
                    errorMessage = "This plate number is already registered."
                }
            } else if let authError = error as? AuthErrorCode {
                switch authError.code {
                case .emailAlreadyInUse:
                    errorMessage = "This email is already registered. Please sign in instead."
                case .invalidEmail:
                    errorMessage = "Invalid email address."
                case .weakPassword:
                    errorMessage = "The password is too weak. Please choose a stronger password."
                default:
                    errorMessage = "An error occurred during sign up. Please try again."
                }
            } else {
                errorMessage = "An error occurred during sign up. Please try again."
            }
            showError = true
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
                // Illustration
                Text("Creează Cont")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                Text("Conectează-te cu șoferii din jurul tău")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
                
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
                        if showPassword {
                            TextField("Creează o parolă", text: $password)
                        } else {
                            SecureField("Creează o parolă", text: $password)
                        }
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Text("Confirmă Parola")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        if showConfirmPassword {
                            TextField("Confirmă parola", text: $confirmPassword)
                        } else {
                            SecureField("Confirmă parola", text: $confirmPassword)
                        }
                        Button(action: { showConfirmPassword.toggle() }) {
                            Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                HStack(alignment: .center) {
                    Toggle(isOn: $agreedToTerms) {
                        VStack(alignment:.leading) {
                            HStack(spacing: 2) {
                                Text("Sunt de acord cu ")
                                Button("Termenii și Condițiile") {}
                                    .foregroundColor(.blue)
                                Text("și")
                                
                            }
                            
                            Button("Politica de Confidențialitate") {}
                                .foregroundColor(.blue)
                        }.font(.footnote)
                    }
                    .toggleStyle(CheckboxToggleStyle())
            
            Spacer()
                }
                .padding(.top, 4)
                
                Button(action: handleSignUp) {
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
                .background(isFormValid() ? Color.blue : Color(.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!isFormValid() || isLoading)
                
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
                    Text("Sau continuă cu")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
                }
                
                HStack(spacing: 16) {
                    Button(action: { /* TODO: Google sign up */ }) {
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
                    Button(action: { /* TODO: Apple sign up */ }) {
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
                    Text("Ai deja un cont?")
                    NavigationLink(destination: SignInView().environmentObject(authViewModel), isActive: $goToSignIn) {
                        Button("Conectează-te") {
                            goToSignIn = true
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
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


