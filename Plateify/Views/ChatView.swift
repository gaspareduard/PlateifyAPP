import SwiftUI

struct ChatView: View {
    let chat: Chat
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        Text("No messages yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.listenToMessages(chatId: chat.id)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        Task {
            await viewModel.sendMessage(messageText, in: chat)
            messageText = ""
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.senderId == UserDefaults.standard.string(forKey: "userId") {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.senderId == UserDefaults.standard.string(forKey: "userId") ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.senderId == UserDefaults.standard.string(forKey: "userId") ? .white : .primary)
                .cornerRadius(20)
            
            if message.senderId != UserDefaults.standard.string(forKey: "userId") {
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView(chat: Chat(
        id: "preview",
        participants: ["user1", "user2"],
        lastMessage: "Hello",
        lastMessageTimestamp: Date(),
        lastMessageSenderId: "user1",
        unreadCount: [:],
        createdAt: Date(),
        updatedAt: Date()
    ))
} 