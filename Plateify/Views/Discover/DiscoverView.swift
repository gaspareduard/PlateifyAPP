// MARK: - HomeView.swift
import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var friendService: FriendService
    @EnvironmentObject private var nearbyService: NearbyUserService

    @StateObject private var viewModel = HomeViewModel()
    @State private var showFullScreenProfile = false

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

            case .loaded(let users):
                if let first = users.first {
                    VStack {
                        UserCard(user: first, showFullScreenProfile: $showFullScreenProfile)
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
            if case .loaded(let users) = viewModel.state,
               let first = users.first {
              UserProfileView(user: first)
            } else {
              // must always return a View
              EmptyView()
            }
          }
        }
        .task {
            viewModel.configure(
                nearbyService: nearbyService,
                friendService: friendService,
            )
            await viewModel.loadUsers()
        }
    }
}

// MARK: - UserCard, CircleButton, UserProfileView remain unchanged

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




// MARK: - Preview
#Preview{
    DiscoverView()
        .environmentObject(AuthenticationViewModel(previewUser: TestData.user))
        .environmentObject(FriendService())
        .environmentObject(NearbyUserService())
}

