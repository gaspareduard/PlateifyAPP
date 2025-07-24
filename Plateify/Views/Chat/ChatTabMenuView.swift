import SwiftUI
import FirebaseAuth

struct ChatTabMenuView: View {
    @ObservedObject var viewModel: ChatListViewModel
    @ObservedObject var friendViewModel: FriendViewModel
    private let circleSize: CGFloat = 70
    
    // Helper computed properties for state management
    private var isLoading: Bool {
        if case .loading = viewModel.chatListState { return true }
        if case .loading = friendViewModel.state { return true }
        return false
    }
    
    private var errorMessage: String? {
        if case .error(let message) = viewModel.chatListState { return message }
        if case .error(let message) = friendViewModel.state { return message }
        return nil
    }
    
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    LoadingView()
                } else if let error = errorMessage {
                    ErrorViewWithAction(
                        message: error,
                        retryAction: { Task {
                            await friendViewModel.loadFriends()
                            viewModel.startListening()}})
                } else {
                    content }
            }.padding()
        }
    }
    
    private var content : some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 35){
                NewMatchesSection(friendViewModel: friendViewModel,
                                  chatViewModel: viewModel,
                                  circleSize: circleSize)
                MessagesSection(chatViewModel: viewModel,
                                circleSize: circleSize)}
        }
        .refreshable {
            await refreshData()
        }
    }
    
    private func refreshData() async {
        print("DEBUG: Refreshing chat tab data")
        await friendViewModel.loadFriends()
        viewModel.startListening()
    }
}

// MARK: - New Matches Section
private struct NewMatchesSection: View {
    @ObservedObject var friendViewModel: FriendViewModel
    @ObservedObject var chatViewModel: ChatListViewModel
    let circleSize: CGFloat
    
    private var matches: [FriendRequestDetail] {
        friendViewModel.getAcceptedFriendDetails()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Conexiuni")
                .font(.title2)
                .bold()
            
            if matches.isEmpty {
                EmptyStateView(
                    message: "Nu ai conexiuni momentan.",
                    systemImage: "person.2.slash"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .firstTextBaseline, spacing: 16) {
                        ForEach(matches) { match in
                            if let userSummary = match.userSummary {
                                NewMatchCard(
                                    user: userSummary, 
                                    circleSize: circleSize,
                                    chatViewModel: chatViewModel
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Messages Section
private struct MessagesSection: View {
    @ObservedObject var chatViewModel: ChatListViewModel
    let circleSize: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Mesaje")
                .font(.title2)
                .bold()
            
            if case .loaded(let chats) = chatViewModel.chatListState {
                if chats.isEmpty {
                    EmptyStateView(
                        message: "Nu ai conversații active momentan.",
                        systemImage: "message.slash"
                    )
                } else {
                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(Array(chats.enumerated()), id: \.element.id) { idx, chat in
                            NavigationLink(destination: ChatWithUserView(chat: chat, viewModel: chatViewModel)) {
                                MessageRow(
                                    chat: chat,
                                    circleSize: circleSize,
                                    chatViewModel: chatViewModel
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
}

private struct NewMatchCard: View {
    let user: UserSummary
    let circleSize: CGFloat
    let chatViewModel: ChatListViewModel
    
    var body: some View {
        NavigationLink(destination: ChatCreationView(user: user, chatViewModel: chatViewModel)) {
            VStack(spacing: 8) {
                if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                    AvatarView(url: url, size: circleSize)
                }
                
                Text("\(user.displayName)")
                    .frame(width: circleSize)
                    .font(.subheadline).bold().foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct NewMatchCardPlaceholder: View {
    let CircleSize: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: CircleSize, height: CircleSize)
                .clipShape(Circle())
                .foregroundColor(.gray.opacity(0.3))
            Text("Loading...")
                .font(.subheadline).bold()
                .foregroundColor(.secondary)
        }
    }
}

private struct MessageRow: View {
    let chat: Chat
    let circleSize: CGFloat
    @ObservedObject var chatViewModel: ChatListViewModel
    
    private var otherParticipant: UserSummary? {
        chatViewModel.getParticipantSummary(for: chat)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            if let userSummary = otherParticipant {
                if let urlString = userSummary.profileImageURL, let url = URL(string: urlString) {
                    AvatarView(url: url, size: circleSize)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(otherParticipant?.displayName ?? "Loading...")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Text(chat.lastMessage ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.bottom, 12)
        .contentShape(Rectangle())
    }
}

struct AvatarView: View {
    let url: URL?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):     img.resizable().scaledToFill()
                    case .failure:              Image(systemName: "person.fill").resizable().scaledToFit()
                    case .empty:                ProgressView()
                    @unknown default:           Image(systemName: "person.fill").resizable().scaledToFit()
                    }
                }
            } else {
                Image(systemName: "person.fill").resizable().scaledToFit()
                    .background(Circle().fill(Color.gray.opacity(0.3)))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

private struct SectionView<Content: View>: View {
    let title: String
    let emptyState: EmptyStateView
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title2).bold()
            content()
        }
    }
}

private struct EmptyStateView: View {
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 30))
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

