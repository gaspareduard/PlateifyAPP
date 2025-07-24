    import SwiftUI
    import CoreLocation

    struct DiscoverView: View {
        
        @ObservedObject var viewModel: HomeViewModel
        
        @State private var showFullScreenProfile = false
        
        @State private var topCardOffset: CGFloat = 0
        private var cardWidth:  CGFloat { UIScreen.main.bounds.width - 20 }

        
        var body: some View {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                switch viewModel.state {
                case .loading:
                    ProgressView()
                    
                case .error(let message):
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(message)
                            .multilineTextAlignment(.center)
                        .padding()}
                    
                case .loaded:
                    if let first = viewModel.nearbyUsers.first {
                        VStack {
                            ZStack {
                                if viewModel.nearbyUsers.count > 1 {
                                    let next = viewModel.nearbyUsers[1]
                                    UserCard(user: next, showFullScreenProfile: $showFullScreenProfile)
                                        .scaleEffect(0.9 + min(abs(topCardOffset)/(cardWidth),1) * 0.1)
                                }

                                SwipeableUserCard(
                                    user: first,
                                    showFullScreenProfile: $showFullScreenProfile,
                                    onSkip: { viewModel.skipUser() },
                                    onLike: { await viewModel.likeUser() },
                                    offset: $topCardOffset
                                )
                            }
                            HStack(spacing: 45) {
                                CircleButton(icon: "xmark", color: .red) {
                                    viewModel.skipUser()
                                }
                                CircleButton(icon: "heart.fill", color: .green) {
                                    Task { await viewModel.likeUser() }
                                }
                            }
                            .padding()
                        }
                    } else {
                        VStack {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Nu sunt utilizatori în apropiere")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showFullScreenProfile) {
                Group {
                    if let first = viewModel.nearbyUsers.first {
                        DiscoverDetailedView(user: first)
                    } else {
                        EmptyView()
                    }
                }
            }
            .task {
                await viewModel.loadUsers()
            }
            
        }
    }


    struct SwipeableUserCard: View {
        let user: NearbyUser
        @Binding var showFullScreenProfile: Bool
        let onSkip: () -> Void
        let onLike: @Sendable () async -> Void
        
        @Binding var offset: CGFloat
        @State private var rotation: Double = 0
        @State private var isSwiped = false
        
        private var cardWidth:  CGFloat { UIScreen.main.bounds.width - 20 }
        private var cardHeight: CGFloat { UIScreen.main.bounds.height / 1.45 }

        
        var body: some View {
            ZStack {
                // your existing card content
                UserCard(user: user, showFullScreenProfile: $showFullScreenProfile)
                
                if offset > 0 {
                    LikeLabel()
                        .font(.title)
                        .padding(8)
                        .rotationEffect(.degrees(-20))
                        .offset(
                            x: -cardWidth * 0.22,
                            y: -cardHeight * 0.37
                        )
                        .opacity(min(offset / 100.0, 1.0))
                }
                else if offset < 0 {
                    SkipLabel()
                        .font(.title)
                        .padding(8)
                        .rotationEffect(.degrees(20))
                        .offset(
                            x: cardWidth * 0.22,
                            y: -cardHeight * 0.37
                        )
                        .opacity(min(-offset / 100.0, 1.0))
                }
            }
            .offset(x: offset)
            .rotationEffect(.degrees(rotation))
            .zIndex(offset != 0 ? 1 : 0)
            .highPriorityGesture(
                DragGesture()
                    .onChanged { g in
                        guard !isSwiped, abs(g.translation.width) > abs(g.translation.height) else { return }
                        offset = g.translation.width
                        rotation = Double(offset / cardWidth) * 15
                    }
                    .onEnded { g in
                        let dx = g.translation.width
                        guard abs(dx) > abs(g.translation.height) else {
                            reset()
                            return
                        }
                        if dx < -100 {
                            // skip
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                                offset = -2 * cardWidth; rotation = -20; isSwiped = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) { onSkip() }
                        } else if dx > 100 {
                            // like
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                                offset = 2 * cardWidth; rotation = 20; isSwiped = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                                Task { await onLike() }
                            }
                        } else {
                            reset()
                        }
                    }
                
            )
            .animation(nil, value: offset)
            .animation(nil, value: rotation)
            .onChange(of: user.id) { _ in
              // turn off animation for this reset
              let tx = Transaction(animation: nil)
              withTransaction(tx) {
                offset = 0
                rotation = 0
                isSwiped = false
              }
            }
        }

        private func reset() { offset = 0; rotation = 0; isSwiped = false }
    }

    struct UserCard: View {
        var cardWidth: CGFloat { UIScreen.main.bounds.width - 20 }
        var cardHeight: CGFloat { UIScreen.main.bounds.height / 1.45 }
        
        let user: NearbyUser
        @Binding var showFullScreenProfile: Bool
        
        var body: some View {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    if let imageURL = user.profileImageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color(.systemGray5)
                        }
                        .frame(width: cardWidth, height: cardHeight)
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(50)
                            .frame(width: cardWidth, height: cardHeight)
                            .background(Color(.systemGray5))
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        if let plate = user.plateNumbers.first {
                            NumberPlateDisplayView(plate: plate)
                        }
                        
                        HStack {
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.heavy)
                            
                            if let age = user.age {
                                Text("\(age)")
                                    .font(.title)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            Button {
                                showFullScreenProfile.toggle()
                            } label: {
                                Image(systemName: "arrow.up.circle")
                                    .fontWeight(.bold)
                                    .imageScale(.large)
                            }
                        }
                        .foregroundStyle(Color.white)
                        
                    }
                    .padding()
                    .background(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
                }
                .frame(width: cardWidth, height: cardHeight)
                .cornerRadius(10)
            }
        }
    }

    struct CircleButton: View {
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            VStack(spacing: 8) {
                Button(action: action) {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 64, height: 64)
                            .shadow(color: color.opacity(0.2), radius: 6, x: 0, y: 4)
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    struct DiscoverView_Previews: PreviewProvider {
        static var previews: some View {
            // Create a mock version of NearbyUserService that will work in preview
            class PreviewNearbyService: NearbyUserService {
                override func fetchNearbyUsers(excluding friends: [Friend], pendingRequests: [Friend], location: CLLocation?) async throws -> [NearbyUser] {
                    // Return mock data instead of making a real API call
                    return [
                        NearbyUser(
                            id: "1",
                            profileImageURL: "https://randomuser.me/api/portraits/women/43.jpg",
                            plateNumbers: ["B 123 XYZ"],
                            firstName: "Ana",
                            age: 28,
                            bio: "Love traveling and meeting new people",
                            latitude: 44.4268,
                            longitude: 26.1025
                        ),
                        NearbyUser(
                            id: "2",
                            profileImageURL: "https://randomuser.me/api/portraits/men/32.jpg",
                            plateNumbers: ["CJ 456 ABC"],
                            firstName: "Mihai",
                            age: 34,
                            bio: "Car enthusiast and coffee lover",
                            latitude: 44.4270,
                            longitude: 26.1028
                        ),
                        NearbyUser(
                            id: "3",
                            profileImageURL: "https://randomuser.me/api/portraits/women/22.jpg",
                            plateNumbers: ["TM 789 DEF"],
                            firstName: "Elena",
                            age: 26,
                            bio: "Adventure seeker and nature lover",
                            latitude: 44.4265,
                            longitude: 26.1020
                        ),
                        NearbyUser(
                            id: "4",
                            profileImageURL: "https://randomuser.me/api/portraits/men/71.jpg",
                            plateNumbers: ["CT 321 GHI"],
                            firstName: "Alex",
                            age: 31,
                            bio: "Photographer and road trip enthusiast",
                            latitude: 44.4275,
                            longitude: 26.1030
                        ),
                        NearbyUser(
                            id: "5",
                            profileImageURL: "https://randomuser.me/api/portraits/women/52.jpg",
                            plateNumbers: ["PH 654 JKL"],
                            firstName: "Maria",
                            age: 29,
                            bio: "Music lover and foodie",
                            latitude: 44.4260,
                            longitude: 26.1018
                        )
                    ]
                }
            }
            
            // Use the mock service in the preview
            let mockNearbyService = PreviewNearbyService()
            let vm = HomeViewModel(
                nearbyService: mockNearbyService,
                friendService: FriendService()
            )
            
            // Let the .task { await viewModel.loadUsers() } call work with our mock
            return DiscoverView(viewModel: vm)
        }
    }
