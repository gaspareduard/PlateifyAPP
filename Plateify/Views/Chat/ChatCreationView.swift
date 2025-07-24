import SwiftUI

struct ChatCreationView: View {
    let user: UserSummary
    let chatViewModel: ChatListViewModel
    
    @State private var chat: Chat?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if let chat = chat {
                ChatWithUserView(chat: chat, viewModel: chatViewModel)
            } else if let error = errorMessage {
                ErrorViewWithAction(message: error) {
                    Task {
                        await checkForChat()
                    }
                }
            } else {
                LoadingView()
            }
        }
        .task {
            await checkForChat()
        }
    }
    
    private func checkForChat() async {
        isLoading = true
        errorMessage = nil
        
        // Check if chat already exists in the chat list
        if let existingChat = chatViewModel.chats.first(where: { chat in
            chat.participants.contains(user.id)
        }) {
            await MainActor.run {
                self.chat = existingChat
                print("DEBUG: Found existing chat with \(user.displayName)")
            }
        } else {
            // Create the chat using the ViewModel
            print("DEBUG: Creating chat with user: \(user.displayName)")
            await chatViewModel.createChat(with: user.id)
            
            // Use the currentChat property that gets set when chat is created
            if let createdChat = chatViewModel.currentChat {
                await MainActor.run {
                    self.chat = createdChat
                    print("DEBUG: Chat created successfully with \(user.displayName)")
                }
            } else {
                await MainActor.run {
                    self.errorMessage = "Failed to create chat"
                    print("DEBUG: Failed to create chat with \(user.displayName)")
                }
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}

#Preview {
    let mockUser = UserSummary(
        id: "preview-user",
        firstName: "Alice",
        lastName: "Smith",
        profileImageURL: "https://randomuser.me/api/portraits/women/68.jpg",
        plateNumbers: ["TM22FEF"],
        age: 29,
        bio: "Coffee lover",
        sex: "female"
    )
    
    let chatViewModel = ChatListViewModel(chatService: TestData.mockChatService())
    
    return ChatCreationView(
        user: mockUser,
        chatViewModel: chatViewModel
    )
} 
