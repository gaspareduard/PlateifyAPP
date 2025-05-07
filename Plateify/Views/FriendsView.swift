import SwiftUI

struct FriendsView: View {
    @StateObject private var friendViewModel = FriendViewModel()
    @State private var searchText = ""
    @State private var showingAddFriend = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()
                
                if friendViewModel.isLoading {
                    ProgressView()
                } else if let error = friendViewModel.error {
                    ErrorView(error: error)
                } else {
                    List {
                        // Friend requests section
                        if !friendViewModel.pendingRequests.isEmpty {
                            Section(header: Text("Friend Requests")) {
                                ForEach(friendViewModel.pendingRequests) { request in
                                    FriendRequestRow(request: request) { accepted in
                                        Task {
                                            if accepted {
                                                try await friendViewModel.acceptFriendRequest(request)
                                            } else {
                                                try await friendViewModel.rejectFriendRequest(request)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Friends section
                        Section(header: Text("Friends")) {
                            ForEach(filteredFriends) { friend in
                                NavigationLink(destination: UserProfileView(userId: friend.friendId)) {
                                    FriendRow(friend: friend)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFriend = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView()
            }
        }
        .onAppear {
            friendViewModel.listenToFriends()
            friendViewModel.listenToFriendRequests()
        }
        .onDisappear {
            friendViewModel.stopListening()
        }
    }
    
    private var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friendViewModel.friends
        }
        return friendViewModel.friends.filter { friend in
            // Add filtering logic based on friend's name
            true
        }
    }
}

struct FriendRow: View {
    let friend: Friend
    
    var body: some View {
        HStack {
            // Profile image
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading) {
                Text("Friend Name") // Replace with actual friend name
                    .font(.headline)
                Text("Online") // Replace with actual status
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct FriendRequestRow: View {
    let request: Friend
    let onAction: (Bool) -> Void
    
    var body: some View {
        HStack {
            // Profile image
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading) {
                Text("Request Name") // Replace with actual name
                    .font(.headline)
                Text("Wants to be your friend")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack {
                Button(action: { onAction(true) }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Button(action: { onAction(false) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, onSubmit: performSearch)
                    .padding()
                
                if searchViewModel.isLoading {
                    ProgressView()
                } else if let error = searchViewModel.error {
                    ErrorView(error: error)
                } else {
                    List(searchViewModel.searchResults) { user in
                        UserRow(user: user)
                    }
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func performSearch() {
        Task {
            await searchViewModel.searchUsers(query: searchText)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search users...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit(onSubmit)
            
            Button(action: onSubmit) {
                Text("Search")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    FriendsView()
} 
