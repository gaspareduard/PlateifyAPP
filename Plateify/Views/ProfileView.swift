import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    ProfileHeader(user: authViewModel.user)
                    
                    // Stats section
                    StatsSection()
                    
                    // Action buttons
                    ActionButtons(
                        onEditProfile: { showingEditProfile = true },
                        onSettings: { showingSettings = true }
                    )
                    
                    // Recent activity
                    RecentActivitySection()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(user: authViewModel.user)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct ProfileHeader: View {
    let user: User?
    
    var body: some View {
        VStack {
            // Profile image
            AsyncImage(url: URL(string: user?.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            
            // User info
            VStack(spacing: 4) {
                Text(user?.displayName ?? "Loading...")
                    .font(.title2)
                    .bold()
                
                if let plateNumber = user?.plateNumber {
                    Text(plateNumber)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                if let bio = user?.bio {
                    Text(bio)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
        }
    }
}

struct StatsSection: View {
    var body: some View {
        HStack(spacing: 40) {
            StatItem(title: "Friends", value: "0")
            StatItem(title: "Chats", value: "0")
            StatItem(title: "Searches", value: "0")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ActionButtons: View {
    let onEditProfile: () -> Void
    let onSettings: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onEditProfile) {
                Label("Edit Profile", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(action: onSettings) {
                Label("Settings", systemImage: "gear")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct RecentActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Activity")
                .font(.headline)
            
            ForEach(0..<3) { _ in
                ActivityRow()
            }
        }
    }
}

struct ActivityRow: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "message.fill")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading) {
                Text("New Message")
                    .font(.subheadline)
                    .bold()
                Text("From John Doe")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("2h ago")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
} 