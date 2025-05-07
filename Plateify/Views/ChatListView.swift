import SwiftUI

struct ChatListView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()
                
                if chatViewModel.isLoading {
                    ProgressView()
                } else if let error = chatViewModel.error {
                    ErrorView(error: error)
                } else {
                    List {
                        ForEach(filteredChats) { chat in
                            NavigationLink(destination: ChatView(chat: chat)) {
                                ChatRow(chat: chat)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* New chat action */ }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .onAppear {
            chatViewModel.listenToChats()
        }
        .onDisappear {
            chatViewModel.stopListening()
        }
    }
    
    private var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chatViewModel.chats
        }
        return chatViewModel.chats.filter { chat in
            // Add filtering logic based on chat participants
            true
        }
    }
}

struct ChatRow: View {
    let chat: Chat
    
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
                Text("Chat Title") // Replace with actual chat title
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
                Text(timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search chats...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
    ChatListView()
} 