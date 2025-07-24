import SwiftUI

@MainActor
struct LikesView: View {
    @ObservedObject var viewModel: FriendViewModel
    @State private var isShowingError = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            print("DEBUG: LikesView showing loading state")
                        }
                    
                case .error(let message):
                    errorView(message: message)
                        .onAppear {
                            print("DEBUG: LikesView showing error state: \(message)")
                            isShowingError = true
                        }
                    
                case .loaded(_, _):
                    if !viewModel.pendingFriendDetails.isEmpty {
                        pendingRequestsContent(pendingDetails: viewModel.pendingFriendDetails)
                            .onAppear {
                                print("DEBUG: LikesView showing \(viewModel.pendingFriendDetails.count) pending requests")
                            }
                    } else {
                        NoLikesView
                            .onAppear {
                                print("DEBUG: LikesView showing empty state")
                            }
                    }
                }
            }
        }
        .alert("Error", isPresented: $isShowingError) {
            Button("Retry") {
                Task {
                    print("DEBUG: Retrying friend loading")
                    viewModel.loadFriends()
                }
            }
            Button("OK", role: .cancel) {
                isShowingError = false
            }
        } message: {
            if case .error(let message) = viewModel.state {
                Text(message)
            }
        }
    }
    
    // MARK: - Content Views
    private func errorView(message: String) -> some View {
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
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func pendingRequestsContent(pendingDetails: [FriendRequestDetail]) -> some View {
        VStack(spacing: 16) {
            // Header info
            HStack {
                Text("\(pendingDetails.count) Likes")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Grid of pending requests
            ScrollView(.vertical) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]) {
                    ForEach(pendingDetails) { detail in
                        PendingRequestCard(
                            request: detail.friend,
                            userSummary: detail.userSummary
                        ) { action in
                            handleFriendAction(detail: detail, action: action)
                        }
                    }
                }.padding(.horizontal, 6)
            }.ignoresSafeArea(.all, edges: .bottom)
            
            Spacer()
        }.ignoresSafeArea(.all, edges: .bottom)
    }
    
    private func handleFriendAction(detail: FriendRequestDetail, action: String) {
        Task {
            print("DEBUG: Handling friend action: \(action) for user: \(detail.friendId)")
            do {
                if action == "accept" {
                    await viewModel.acceptFriendRequest(detail.friend)
                } else if action == "decline" {
                    await viewModel.rejectFriendRequest(detail.friend)
                }
            } catch {
                print("DEBUG: Failed to handle friend action: \(error.localizedDescription)")
                isShowingError = true
            }
        }
    }
    
    private var NoLikesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Likes Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("When people like your profile, they'll appear here.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Pending Request Card
@MainActor
struct PendingRequestCard: View {
    let request: Friend
    let userSummary: UserSummary?
    let onAction: (String) -> Void
    
    @State private var offset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var isSwiped = false
    
    var body: some View {
        ZStack {
            // Profile Image Background
            profileImage
                .blur(radius: 0.5)
                .brightness(-0.1)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.1), Color.black.opacity(0.5)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(12)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                Text(userSummary?.firstName ?? "Loading...")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .padding(.leading, 3)
                    .padding(.bottom, 3)
                
                if let plate = userSummary?.plateNumbers.first {
                    NumberPlateDisplayView(plate: plate)
                        .padding(.leading, 3)
                        .padding(.bottom, 3)
                }
            }
            .frame(width: .infinity)
            .background {
                LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .bottom, endPoint: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(width: cardWidth, height: cardHeight)
        .offset(x: offset)
        .rotationEffect(.degrees(rotation))
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture()
                .onChanged { g in
                    handleDragChanged(g)
                }
                .onEnded { g in
                    handleDragEnded(g)
                }
        )
    }
    
    private func handleDragChanged(_ g: DragGesture.Value) {
        let dx = g.translation.width
        let dy = g.translation.height
        guard !isSwiped, abs(dx) > abs(dy) else { return }
        offset = dx
        rotation = Double(dx / cardWidth) * 15
    }
    
    private func handleDragEnded(_ g: DragGesture.Value) {
        let dx = g.translation.width
        let dy = g.translation.height
        guard abs(dx) > abs(dy) else {
            withAnimation(.spring()) {
                offset = 0; rotation = 0
            }
            return
        }
        
        if dx > 100 {
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                offset = 2 * cardWidth; rotation = 20; isSwiped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("DEBUG: Card swiped right - accepting request")
                onAction("accept")
            }
        } else if dx < -100 {
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                offset = -2 * cardWidth; rotation = -20; isSwiped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("DEBUG: Card swiped left - declining request")
                onAction("decline")
            }
        } else {
            withAnimation(.spring()) {
                offset = 0; rotation = 0
            }
        }
    }
    
    var cardWidth: CGFloat {
        UIScreen.main.bounds.width / 2.1
    }
    
    var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 3
    }
    
    private var profileImage: some View {
        Group {
            if let imageURL = userSummary?.profileImageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: cardHeight)
                    case .failure:
                        fallbackImage
                    case .empty:
                        Color.gray.opacity(0.3)
                    @unknown default:
                        fallbackImage
                    }
                }
            } else {
                fallbackImage
            }
        }.cornerRadius(10, corners: .allCorners)
    }
    
    private var fallbackImage: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .padding(40)
            .foregroundColor(.white)
            .background(Color.gray.opacity(0.7))
    }
}

    	

