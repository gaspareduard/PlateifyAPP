import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var user: User? {
        didSet {
            if let id = user?.id {
                UserDefaults.standard.set(id, forKey: "userId")
                isAuthenticated = true
                // Initialize profile fields when user is set
                if let user = user {
                    firstName = user.firstName
                    lastName = user.lastName
                    username = user.username
                    bio = user.bio ?? ""
                    profileImageURL = user.profileImageURL
                    plateNumbers = user.plateNumbers
                    sex = user.sex.isEmpty ? "Masculin" : user.sex
                        if let bd = user.birthdate {
                            birthdate = bd
                        }
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "userId")
                isAuthenticated = false
                // Clear profile fields when user is nil
                firstName = ""
                lastName = ""
                username = ""
                bio = ""
                profileImageURL = nil
                plateNumbers = []
                sex = "Masculin"
                    birthdate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? Date()
            }
        }
    }
    @Published private(set) var isAuthenticated = false
    @Published var error: Error?
    @Published var isLoading = false
    @Published var showTerms = false
    
    // MARK: - Profile Published State
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var username: String = ""
    @Published var bio: String = ""
    @Published var profileImageURL: String?
    @Published var profileImage: Image?
    @Published var imageData: Data?
    @Published var showImagePicker = false
    @Published var plateNumbers: [String] = []
    
    @Published var sex: String = "Masculin"
    @Published var birthdate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? Date()
    
    // MARK: - Profile Stats
    @Published var friendCount = 0
    @Published var chatCount = 0
    @Published var searchCount = 0

    // MARK: - Dependencies
    private let auth = Auth.auth()
    private let userService: UserService
    private var authStateListener: AuthStateDidChangeListenerHandle?

    // MARK: - Initializers
    init(userService: UserService = UserService()) {
        self.userService = userService
        setupAuthStateListener()
        print("DEBUG: AuthenticationViewModel initialized with UserService")
    }

    // Preview initializer
    init(previewUser: User, userService: UserService = UserService()) {
        self.userService = userService
        self.user = previewUser
        self.isAuthenticated = true
        UserDefaults.standard.set(previewUser.id, forKey: "userId")
        print("DEBUG: AuthenticationViewModel initialized with preview user")
    }

    deinit {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }

    // MARK: - Sign Up
    func signUp(
        email: String,
        password: String,
        username: String,
        firstName: String,
        lastName: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let newUser = User(
                id: result.user.uid,
                username: username,
                email: email,
                firstName: firstName,
                lastName: lastName,
                plateNumbers: [],
                bio: nil,
                profileImageURL: nil,
                isOnline: true,
                lastSeen: Date(),
                privacySettings: PrivacySettings(
                    showPlateInSearch: true,
                    acceptDMsFromAnyone: false,
                    showOnlineStatus: true
                ),
                createdAt: nil,
                updatedAt: nil,
                hasCompletedOnboarding: false,
                plateSearchCount: 0,
                sex: "",
                allowNearbyDiscovery: true,
                allowPlateSuggestions: true,
                latitude: nil,
                longitude: nil,
                lastLocationUpdate: nil,
                birthdate: nil,
                preferredSex: nil,
                maxDiscoveryDistance: nil
            )

            try await userService.createUser(newUser)
            userService.currentUser = newUser
            self.user = newUser
        } catch {
            self.error = error
            throw error
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await auth.signIn(withEmail: email, password: password)
            // auth state listener will fetch and assign the user
        } catch {
            self.error = error
            throw error
        }
    }

    // MARK: - Sign Out
    func signOut() throws {
        do {
            try auth.signOut()
            userService.currentUser = nil
            self.user = nil
        } catch {
            self.error = error
            throw error
        }
    }

    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            self.error = error
            throw error
        }
    }

    // MARK: - Profile Operations
    func saveProfile() async {
        guard var currentUser = user else {
            error = NSError(domain: "AuthVM", code: -1, 
                          userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Update user model
        currentUser.firstName = firstName
        currentUser.lastName = lastName
        currentUser.username = username
        currentUser.bio = bio.isEmpty ? nil : bio
        currentUser.plateNumbers = plateNumbers
        currentUser.sex = sex
        currentUser.birthdate = birthdate
        
        // Upload image if changed
        if let data = imageData {
            do {
                guard let uid = currentUser.id else {
                    error = NSError(domain: "AuthVM", code: -1, 
                                  userInfo: [NSLocalizedDescriptionKey: "Invalid user identifier"])
                    return
                }
                
                let url = try await userService.uploadProfileImage(data, userId: uid)
                currentUser.profileImageURL = url.absoluteString
                self.profileImageURL = url.absoluteString
            } catch {
                self.error = error
                return
            }
        }
        
        do {
            try await userService.updateUser(currentUser)
            self.user = currentUser
            print("DEBUG: Profile updated successfully")
        } catch {
            self.error = error
            print("DEBUG: Failed to update profile: \(error.localizedDescription)")
        }
    }
    
    func refreshProfile() async {
        guard let currentUser = user else {
            error = NSError(domain: "AuthVM", code: -1, 
                          userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            return
        }
        
        isLoading = true
        defer { isLoading = false }

        do {
            let fresh = try await userService.fetchUser(id: currentUser.id!)
            self.user = fresh
            print("DEBUG: Profile refreshed successfully")
        } catch {
            self.error = error
            print("DEBUG: Failed to refresh profile: \(error.localizedDescription)")
        }
    }
    
    func loadStats() async {
        guard let currentUser = user else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let db = Firestore.firestore()
        do {
            let friendsSnap = try await db
                .collection("friends")
                .whereField("userId", isEqualTo: currentUser.id!)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            friendCount = friendsSnap.count
            
            let chatsSnap = try await db
                .collection("chats")
                .whereField("participants", arrayContains: currentUser.id!)
                .getDocuments()
            chatCount = chatsSnap.count
            
            let searchesSnap = try await db
                .collection("searches")
                .whereField("userId", isEqualTo: currentUser.id!)
                .getDocuments()
            searchCount = searchesSnap.count
            
            print("DEBUG: Stats loaded - Friends: \(friendCount), Chats: \(chatCount), Searches: \(searchCount)")
        } catch {
            self.error = error
            print("DEBUG: Failed to load stats: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async {
        guard let currentUser = user,
              let firebaseUser = Auth.auth().currentUser else {
            error = NSError(domain: "AuthVM", code: -1, 
                          userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. Delete Firestore document
            try await userService.deleteCurrentUserDocument(id: currentUser.id!)
            
            // 2. Delete Firebase Auth account
            try await firebaseUser.delete()
            
            // 3. Sign out (this will clear the user state)
            try signOut()
            
            print("DEBUG: Account deleted successfully")
        } catch {
            self.error = error
            print("DEBUG: Failed to delete account: \(error.localizedDescription)")
        }
    }

    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateListener = auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }

            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    do {
                        let fetchedUser = try await self.userService.fetchUser(id: firebaseUser.uid)
                        self.userService.currentUser = fetchedUser
                        self.user = fetchedUser
                        print("DEBUG: User state updated via auth listener")
                    } catch {
                        self.error = error
                        self.user = nil
                        print("DEBUG: Failed to fetch user in auth listener: \(error.localizedDescription)")
                    }
                } else {
                    self.userService.currentUser = nil
                    self.user = nil
                    print("DEBUG: User signed out via auth listener")
                }
            }
        }
    }

    // MARK: - User Management
    func updateUser(_ updatedUser: User) {
        self.user = updatedUser
        userService.currentUser = updatedUser
    }
}

// MARK: - Custom Errors
enum AuthError: LocalizedError {
    case clientIDNotFound
    case presentationError
    case tokenError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .clientIDNotFound:
            return "DEBUG: Firebase client ID not found"
        case .presentationError:
            return "DEBUG: Could not present Google Sign In"
        case .tokenError:
            return "DEBUG: Failed to get authentication token"
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}
