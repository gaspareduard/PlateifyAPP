import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Text("Chats")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        // Create new chat
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search chats...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Chat List
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.chats.filter {
                            searchText.isEmpty || $0.lastMessage?.localizedCaseInsensitiveContains(searchText) ?? false
                        }) { chat in
                            NavigationLink(destination: ChatView(chat: chat)) {
                                ChatRow(chat: chat)
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.listenToChats()
            }
            .onDisappear {
                viewModel.stopListening()
            }
        }
    }
}

struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack {
            // Use a placeholder image for now since we can't convert the ID to a URL
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                // Get the current user ID and use it to get the other participant's ID
                let currentUserId = UserDefaults.standard.string(forKey: "userId") ?? ""
                let otherUserId = chat.otherParticipantId(currentUserId: currentUserId) ?? "Unknown User"
                
                Text(otherUserId)
                    .font(.headline)
                
                if let lastMessage = chat.lastMessage {
                    Text(lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let timestamp = chat.lastMessageTimestamp {
                Text(timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ChatListView()
} 
