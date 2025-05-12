import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingFinalDeleteAlert = false
    @State private var friendCount = 36
    @State private var chatCount = 0
    @State private var searchCount = 247
    @State private var dayStreak = 14
    @State private var isRefreshing = false
    @State private var showEditPlate = false
    @State private var tempPlateNumber = ""
    
    var body: some View {
        NavigationStack {
            ScrollView() {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 0) {
                        
                        // Profile Image with gradient
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.2)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 130, height: 130)
                            AsyncImage(url: URL(string: authViewModel.user?.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                        // Name and plate
                        Text("\(authViewModel.user?.firstName ?? "Firstname") \(authViewModel.user?.lastName ?? "Lastname")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 4)
                        
                        HStack(spacing: 0) {
                            
                            // Number plate container
                            HStack(spacing: 8) {
                                // "RO" section
                                Text("RO")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(Color(red: 0, green: 0, blue: 139/255))
                                    .cornerRadius(4)

                                // Plate number
                                Text(authViewModel.user?.plateNumbers.first ?? "B 72 GGG")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.trailing, 8)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                        }
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        Button(action: { showingEditProfile = true }) {
                            Text("Edit Profile")
                                .font(.body)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .padding(.top, 8)
                        }
                        .padding(.bottom, 8)
                    }

                    // Stats
                    HStack(spacing: 12) {
                        ProfileStatItem(value: "\(searchCount)", label: "Searches", color: .blue)
                        ProfileStatItem(value: "\(dayStreak)", label: "Day Streak", color: .yellow)
                        ProfileStatItem(value: "36", label: "Connections", color: .red)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                    
                    VStack(alignment: .leading){
                        Text("Vehicule")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top)
                            
                        VStack(spacing: 12) {
                            ProfileTabItem(icon: "car.2.fill", label: "Adauga numar vehicul nou", color: .blue, destination: AnyView(Text("Lista vehicule")))
                        }
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        Text("Generale")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top)
                            
                        VStack(spacing: 12) {
                            ProfileTabItem(icon: "shield.lefthalf.filled", label: "Privacy Settings", color: .blue, destination: AnyView(Text("Privacy Settings View")))
                            ProfileTabItem(icon: "gearshape.fill", label: "General settings", color: .black, destination: AnyView(Text("General settings")))
                            ProfileTabItem(icon: "trophy.fill", label: "Achievements", color: .yellow, destination: AnyView(Text("Achievements View")))
                            ProfileTabItem(icon: "bell.fill", label: "Notification Preferences", color: .gray, destination: AnyView(Text("Notification Preferences View")))
                        }
                    }.padding(.horizontal)
                    

                    VStack(alignment: .leading){
                        Text("Actiuni Cont")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ProfileTabItem(icon: "door.left.hand.open", label: "Deconectare", color: .red, destination: AnyView(Text("Achievements View")))
                            
                            ProfileTabItem(icon: "trash", label: "Sterge contul", color: .red, destination: AnyView(Text("Achievements View")))
                        }
                            
                    }.padding(.horizontal)
                        .padding(.top)
                    
                    
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 4)
                        RecentActivityItem(icon: "magnifyingglass", iconColor: .blue, text: "Someone searched for your plate", time: "2h ago")
                        RecentActivityItem(icon: "person.crop.circle.badge.plus", iconColor: .red, text: "New connection with B 123 ABC", time: "1d ago")
                        RecentActivityItem(icon: "rosette", iconColor: .yellow, text: "Earned \"Social Butterfly\" badge", time: "2d ago")
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditProfile) {
                if let user = authViewModel.user {
                    EditProfileView(user: user)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet(showingDeleteAccountAlert: $showingDeleteAccountAlert)
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        do {
                            try authViewModel.signOut()
                            UserDefaults.standard.removeObject(forKey: "currentUserId")
                            UserDefaults.standard.removeObject(forKey: "profileImageURL")
                            UserDefaults.standard.removeObject(forKey: "displayName")
                            UserDefaults.standard.removeObject(forKey: "plateNumbers")
                            UserDefaults.standard.removeObject(forKey: "bio")
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            // First delete confirmation
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showingFinalDeleteAlert = true
                }
            } message: {
                Text("Are you sure you want to delete your account? This action is permanent.")
            }
            // Final delete confirmation
            .alert("This cannot be undone", isPresented: $showingFinalDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { await deleteAccount() }
                }
            } message: {
                Text("Deleting your account is irreversible. Are you absolutely sure?")
            }
            .task { await loadStats() }
            .sheet(isPresented: $showEditPlate) {
                EditPlateSheet(tempPlateNumber: $tempPlateNumber) { newPlate in
                    if var user = authViewModel.user {
                        user.plateNumbers = newPlate.isEmpty ? [] : [newPlate]
                        authViewModel.user = user
                    }
                    showEditPlate = false
                } onCancel: {
                    showEditPlate = false
                }
            }
        }
    }
    
    private func refreshProfile() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        // Refresh user data
        if let userId = authViewModel.user?.id {
            do {
                let db = Firestore.firestore()
                let document = try await db.collection("users").document(userId).getDocument()
                if let userData = document.data() {
                    // Update the user in AuthenticationViewModel
                    authViewModel.user = User(
                        id: userId,
                        username: userData["username"] as? String ?? "",
                        email: userData["email"] as? String ?? "",
                        firstName: userData["firstName"] as? String ?? "",
                        lastName: userData["lastName"] as? String ?? "",
                        plateNumbers: userData["plateNumbers"] as? [String] ?? [],
                        bio: userData["bio"] as? String,
                        profileImageURL: userData["profileImageURL"] as? String,
                        isOnline: userData["isOnline"] as? Bool ?? false,
                        lastSeen: (userData["lastSeen"] as? Timestamp)?.dateValue(),
                        privacySettings: PrivacySettings(
                            showPlateInSearch: userData["showPlateInSearch"] as? Bool ?? true,
                            acceptDMsFromAnyone: userData["acceptDMsFromAnyone"] as? Bool ?? false,
                            showOnlineStatus: userData["showOnlineStatus"] as? Bool ?? true
                        ),
                        createdAt: (userData["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        updatedAt: (userData["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                        hasCompletedOnboarding: userData["hasCompletedOnboarding"] as? Bool ?? false,
                        plateSearchCount: userData["plateSearchCount"] as? Int ?? 0,
                        sex: userData["sex"] as? String ?? "",
                        allowNearbyDiscovery: userData["allowNearbyDiscovery"] as? Bool ?? true,
                        allowSomethingElse: userData["allowSomethingElse"] as? Bool ?? true,
                        latitude: userData["latitude"] as? Double,
                        longitude: userData["longitude"] as? Double,
                        lastLocationUpdate: (userData["lastLocationUpdate"] as? Timestamp)?.dateValue(),
                        birthdate: (userData["birthdate"] as? Timestamp)?.dateValue(),
                        preferredSex: userData["preferredSex"] as? String,
                        maxDiscoveryDistance: userData["maxDiscoveryDistance"] as? Int
                    )
                }
            } catch {
                print("Error refreshing user data: \(error.localizedDescription)")
            }
        }
        
        // Refresh stats
        await loadStats()
    }
    
    private func loadStats() async {
        guard let userId = authViewModel.user?.id else { return }
        let db = Firestore.firestore()
        
        do {
            // Get friend count
            let friendsSnapshot = try await db.collection("friends")
                .whereField("userId", isEqualTo: userId)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            friendCount = friendsSnapshot.documents.count
            
            // Get chat count
            let chatsSnapshot = try await db.collection("chats")
                .whereField("participants", arrayContains: userId)
                .getDocuments()
            chatCount = chatsSnapshot.documents.count
            
            // Get search count
            let searchesSnapshot = try await db.collection("searches")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            searchCount = searchesSnapshot.documents.count
        } catch {
            print("Error loading stats: \(error.localizedDescription)")
        }
    }
    
    private func deleteAccount() async {
        guard let user = authViewModel.user else { return }
        let db = Firestore.firestore()
        let userId = user.id
        do {
            // 1. Delete user document from Firestore
            try await db.collection("users").document(userId).delete()
            // 2. Delete user from Firebase Auth
            if let currentUser = Auth.auth().currentUser {
                try await currentUser.delete()
            }
            // 3. Sign out and clear local data
            try authViewModel.signOut()
            UserDefaults.standard.removeObject(forKey: "currentUserId")
            UserDefaults.standard.removeObject(forKey: "profileImageURL")
            UserDefaults.standard.removeObject(forKey: "displayName")
            UserDefaults.standard.removeObject(forKey: "plateNumbers")
            UserDefaults.standard.removeObject(forKey: "bio")
        } catch {
            print("Error deleting account: \(error.localizedDescription)")
            // Optionally, show an alert to the user
        }
    }
}

struct ProfileStatItem: View {
    let value: String
    let label: String
    let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color(.systemGray5), radius: 2, x: 0, y: 1)
    }
}

struct EditPlateSheet: View {
    @Binding var tempPlateNumber: String
    var onSave: (String) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Edit Number Plate")
                    .font(.title2)
                    .bold()
                NumberPlateInputView(plateNumber: $tempPlateNumber)
                    .padding(.horizontal)
                Spacer()
            }
            .padding()
            .navigationTitle("Number Plate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(tempPlateNumber) }
                        .disabled(tempPlateNumber.isEmpty)
                }
            }
        }
    }
}

struct SettingsSheet: View {
    @Binding var showingDeleteAccountAlert: Bool
    var body: some View {
        VStack(spacing: 24) {
            Text("Settings")
                .font(.title2)
                .bold()
                .padding(.top)
            Spacer()
            Button {
                showingDeleteAccountAlert = true
            } label: {
                Text("Delete Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @StateObject private var authVM = AuthenticationViewModel()
        init() {
            authVM.user = TestData.testUser
        }
        var body: some View {
            ProfileView()
                .environmentObject(authVM)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
