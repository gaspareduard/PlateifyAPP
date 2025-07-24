import SwiftUI
import FirebaseAuth

// MARK: - Reusable Components


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

// MARK: - Main View
struct ChatMainView: View {
    @ObservedObject var viewModel: ChatListViewModel
    @ObservedObject var friendViewModel: FriendViewModel

    private var newMatchWidth: CGFloat { UIScreen.main.bounds.width * 0.28 }
    private var newMatchHeight: CGFloat { UIScreen.main.bounds.height * 0.17 }
    
    var body: some View {
        Group {
            // Check for errors in either view model
            if case .error(let message) = viewModel.chatListState {
                ErrorViewWithAction(message: message) {
                    print("DEBUG: Retrying chat list loading")
                    viewModel.startListening()
                }
            } else if case .error(let message) = friendViewModel.state {
                ErrorViewWithAction(message: message) {
                    Task {
                        print("DEBUG: Retrying friends loading")
                        await friendViewModel.loadFriends()
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 35) {
                        NewMatchesSection(
                            friendViewModel: friendViewModel,
                            width: newMatchWidth,
                            height: newMatchHeight
                        )
                        
                        MessagesSection(chatViewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - New Matches Section
private struct NewMatchesSection: View {
    @ObservedObject var friendViewModel: FriendViewModel
    let width: CGFloat
    let height: CGFloat
    
    private var matches: [FriendRequestDetail] {
        friendViewModel.getAcceptedFriendDetails()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Conexiuni").font(.title2).bold()
            
            switch friendViewModel.state {
            case .loading:
                LoadingView()
                    .onAppear { print("DEBUG: Loading matches section") }
                
            case .loaded:
                if matches.isEmpty {
                    EmptyStateView(
                        message: "Nu ai conexiuni momentan.",
                        systemImage: "person.2.slash"
                    )
                    .onAppear { print("DEBUG: No matches to display") }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            ForEach(matches) { match in
                                if let userSummary = match.userSummary {
                                    NewMatchCard(user: userSummary, width: width, height: height)
                                } else {
                                    NewMatchCardPlaceholder(width: width, height: height)
                                }
                            }
                        }
                    }
                    .onAppear { print("DEBUG: Displaying \(matches.count) matches") }
                }
                
            case .error:
                // Error is handled by parent view
                EmptyView()
            }
        }
    }
}

// MARK: - Messages Section
private struct MessagesSection: View {
    @ObservedObject var chatViewModel: ChatListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Mesaje").font(.title2).bold()
            
            switch chatViewModel.chatListState {
            case .loading:
                LoadingView()
                    .onAppear { print("DEBUG: Loading messages section") }
                
            case .loaded(let chats):
                if chats.isEmpty {
                    EmptyStateView(
                        message: "Nu ai conversații active momentan.",
                        systemImage: "message.slash"
                    )
                    .onAppear { print("DEBUG: No messages to display") }
                } else {
                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(Array(chats.enumerated()), id: \.element.id) { idx, chat in
                            MessageRow(chat: chat, isLast: idx == chats.count - 1)
                        }
                    }
                    .onAppear { print("DEBUG: Displaying \(chats.count) messages") }
                }
                
            case .error:
                // Error is handled by parent view
                EmptyView()
            }
        }
    }
}

private struct NewMatchCard: View {
    let user: UserSummary
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                        default:
                            Image(systemName: "person.fill").resizable()
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                }
            }
            Text("\(user.firstName) \(user.lastName)")
                .font(.subheadline).bold().foregroundColor(.primary)
        }
    }
}

private struct NewMatchCardPlaceholder: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
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
    let isLast: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                    )
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(chat.id == "chat-1" ? "Sachia" : "Shain").font(.headline)
                    }
                    Text(chat.lastMessage ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 12)
            if !isLast { Divider().padding(.leading, 88) }
        }
    }
}


