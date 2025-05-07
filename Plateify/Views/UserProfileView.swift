import SwiftUI

struct UserProfileView: View {
    let user: User
    @StateObject private var friendViewModel = FriendViewModel()
    @State private var showingActionSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 12) {
                    AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    Text(user.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.plateNumber ?? "")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if let bio = user.bio {
                        Text(bio)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        Text("Add Friend")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Start chat
                    }) {
                        Text("Message")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Add Friend"),
                message: Text("Would you like to send a friend request to \(user.displayName)?"),
                buttons: [
                    .default(Text("Send Request")) {
                        Task {
                            await friendViewModel.sendFriendRequest(to: user.id)
                        }
                    },
                    .cancel()
                ]
            )
        }
    }
} 
