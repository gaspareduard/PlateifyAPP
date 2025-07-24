import SwiftUI
import FirebaseAuth

struct ChatWithUserView: View {
    let chat: Chat
    @ObservedObject var viewModel: ChatListViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    private var currentUserId: String? { Auth.auth().currentUser?.uid }
    private var otherUserId: String? { chat.participants.first { $0 != currentUserId } }
    private var otherUser: UserSummary? { viewModel.getParticipantSummary(for: chat) }
    private var messages: [Message] { viewModel.messages }
    
    var body: some View {
        VStack(spacing: 0) {
            MessageList(messages: messages, currentUserId: currentUserId ?? "")
            MessageInputBar(messageText: $messageText, isInputFocused: _isInputFocused, onSend: sendMessage)
        }
        .chatToolbar(
            displayName: otherUser?.displayName ?? "",
            profileImageURL: otherUser?.profileImageURL
        )
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.listenToMessages(for: chat)
            Task { await viewModel.markChatAsRead(chat) }
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        Task {
            await viewModel.sendMessage(text, in: chat)
            messageText = ""
        }
    }
}

private struct MessageList: View {
    let messages: [Message]
    let currentUserId: String
    var body: some View {
        ScrollViewReader { _ in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message, isFromCurrentUser: message.senderId == currentUserId)
                            .id(message.id)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
}

private struct MessageInputBar: View {
    @Binding var messageText: String
    @FocusState var isInputFocused: Bool
    var onSend: () -> Void
    var body: some View {
        HStack(alignment: .bottom) {
            TextField("Message", text: $messageText, axis: .vertical)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .focused($isInputFocused)
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5)),
            alignment: .top
        )
    }
}

private struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                Text(message.content)
                    .padding(10)
                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                if let timestamp = message.timestamp {
                    Text(formatTime(timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            if !isFromCurrentUser { Spacer() }
        }
    }
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct ChatToolbar: ToolbarContent {
    let displayName: String
    let profileImageURL: String?
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(displayName)
                .font(.headline)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            if let url = profileImageURL, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    default:
                        Image(systemName: "person.fill").resizable()
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 36, height: 30)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 30)
                    .clipShape(Circle())
            }
        }
    }
}

private extension View {
    func chatToolbar(displayName: String, profileImageURL: String?) -> some View {
        self.toolbar { ChatToolbar(displayName: displayName, profileImageURL: profileImageURL) }
    }
}


