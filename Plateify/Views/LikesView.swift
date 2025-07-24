import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel: FriendViewModel
    
    init(viewModel: FriendViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        
                        Button("Retry") {
                            viewModel.loadFriends()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                case .loaded(let friends, let pendingRequests):
                    friendsContent(friends: friends, pendingRequests: pendingRequests)
                
                case .searching(let results):
                    searchResultsContent(results: results)
                }
            }
            .navigationTitle("Friends")
            .searchable(text: $viewModel.searchText, prompt: "Search for users")
            .onChange(of: viewModel.searchText) { _ in
                viewModel.performSearch()
            }
            .onAppear {
                viewModel.startListening()
            }
            .onDisappear {
                viewModel.stopListening()
            }
        }
    }
    
    // MARK: - Content Views
    
    private func friendsContent(friends: [Friend], pendingRequests: [Friend]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Friend Requests Section
                if !pendingRequests.isEmpty {
                    Text("Friend Requests")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(pendingRequests) { request in
                        FriendRequestCard(request: request) { action in
                            Task {
                                if action == "accept" {
                                    await viewModel.acceptFriendRequest(request)
                                } else if action == "decline" {
                                    await viewModel.rejectFriendRequest(request)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Friends Section
                if !friends.isEmpty {
                    Text("Friends")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, pendingRequests.isEmpty ? 0 : 16)
                    
                    ForEach(friends) { friend in
                        FriendCard(friend: friend) {
                            // Handle friend tap - could navigate to profile or chat
                            print("DEBUG: Friend tapped: \(friend.displayName ?? "Unknown")")
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Empty State
                if friends.isEmpty && pendingRequests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Friends Yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("When people send you friend requests or you connect with others, they'll appear here.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func searchResultsContent(results: [User]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if results.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Results Found")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Try a different search term or check the spelling.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    Text("Search Results")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(results, id: \.id) { user in
                        UserSearchCard(user: user) {
                            Task {
                                if let userId = user.id {
                                    await viewModel.sendFriendRequest(to: userId)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Friend Request Card
struct FriendRequestCard: View {
    let request: Friend
    let onAction: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let imageURL = request.profileImageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(request.displayName ?? "Unknown User")
                    .font(.headline)
                
                if let plate = request.plateNumber {
                    Text(plate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button {
                    onAction("accept")
                } label: {
                    Text("Accept")
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button {
                    onAction("decline")
                } label: {
                    Text("Decline")
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Friend Card
struct FriendCard: View {
    let friend: Friend
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile Image
                if let imageURL = friend.profileImageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.displayName ?? "Unknown User")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let plate = friend.plateNumber {
                        Text(plate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Online Indicator
                if friend.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - User Search Card
struct UserSearchCard: View {
    let user: User
    let onAddFriend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let imageURL = user.profileImageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Add Friend Button
            Button(action: onAddFriend) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Preview
struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        let friendService = FriendService()
        let viewModel = FriendViewModel(friendService: friendService)
        
        // For preview purposes, manually set the state
        let friends = [TestData.friend]
        
        let pendingFriend = Friend(
            id: "pending1",
            userId: "sender1",
            friendId: "testuser",
            status: .pending,
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Diana Popescu",
            profileImageURL: "https://randomuser.me/api/portraits/women/68.jpg",
            plateNumber: "B 234 XYZ",
            isOnline: true
        )
        
        // Set the state for preview
        if let vm = viewModel as? FriendViewModel {
            vm.state = .loaded(friends: friends, pendingRequests: [pendingFriend])
        }
        
        return FriendsView(viewModel: viewModel)
    }
}

