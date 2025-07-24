import SwiftUI

struct SearchProfileResult: View {
    let searchedUser: UserSummary
    let chatVM: ChatListViewModel
    let friendVM: FriendViewModel
    

    
    var body: some View {
        VStack {
            
            ScrollView {
                
                VStack(spacing: 0) {
                    ProfileImage(searchedUser: searchedUser)
                    
                    
                    ProfileNameAndNumberPlate(searchedUser: searchedUser)
                        .padding(.horizontal)
                        .padding(.vertical,25)
                        
                    
                    AboutProfileAndStats(searchedUser: searchedUser)
                }
            }
            ActionButtons()
            Spacer(minLength: 35)
        }
    }
}

extension SearchProfileResult{
    
    struct ProfileImage: View {
        let searchedUser: UserSummary
        var body: some View {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: searchedUser.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: UIScreen.main.bounds.width, height: 400)
                .clipped()
                .shadow(radius: 10)
                .cornerRadius(10,corners: .bottomLeft)
                .cornerRadius(10,corners: .bottomRight)
                
            }
        }
    }
    
    struct ProfileNameAndNumberPlate: View {
        let searchedUser: UserSummary
        var body: some View {
            VStack(alignment: .leading,spacing: 5){
                HStack(alignment: .lastTextBaseline){
                    Text(searchedUser.firstName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    //years old need to implement field
                    Text("28")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.gray)
                    
                    Spacer()
                }
                
                NumberPlateDisplayView(plate: searchedUser.plateNumbers.first ?? "")
                    .padding(.bottom)
            }
        }
    }
    
    struct ActionButtons: View {
        var body: some View {
            HStack(spacing: 16) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                        Text("Mesaj")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                Button(action: {}) {
                    HStack {
                        Image(systemName: "person.badge.plus.fill")
                        Text("Conecteazā")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 4)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
    }
    
    
    struct AboutProfileAndStats: View {
        let searchedUser: UserSummary
        
        var body: some View {
            VStack() {
                
                if let bio = searchedUser.bio, !bio.isEmpty {
                    
                    VStack(alignment:.leading,spacing: 9){
                        HStack(){
                            Text("Despre")
                                .font(.headline)
                                .foregroundStyle(Color.gray)
                            Spacer()
                        }
                        
                        Text(bio)
                            .font(.body)
                        
                            .multilineTextAlignment(.leading)
                            .cornerRadius(16)
                            .shadow(color: Color(.systemGray4).opacity(0.15), radius: 6, x: 0, y: 2)
                        
                    }.padding(.horizontal)
                }
                
                
                
                
                
                
                /*
                 HStack(spacing: 20) {
                 ProfileStatCard(icon: "person.2.fill", value: "\(user.connections ?? 0)", label: "Connections", color: .blue)
                 ProfileStatCard(icon: "mappin.and.ellipse", value: "42", label: "Spots", color: .blue)
                 ProfileStatCard(icon: "star.fill", value: "12", label: "Reviews", color: .blue)
                 }
                 .padding(.top, 8)
                 .padding(.bottom, 24)
                 */
            }
        }
    }
    
}

private struct PreviewAsync<Content: View>: View {
    let content: () async -> Content
    @State private var view: Content?

    var body: some View {
        Group {
            if let view = view {
                view
            } else {
                ProgressView()
                    .task {
                        view = await content()
                    }
            }
        }
    }
}

struct SearchProfileResult_Previews: PreviewProvider {
    static var previews: some View {
        let userService   = TestData.mockUserService()
        let chatService   = TestData.mockChatService()
        let searchedUser  = TestData.mockSearchResults().first!
        let userSummary   = UserSummary(
            id: searchedUser.id,
            firstName: searchedUser.firstName!,
            lastName:  searchedUser.lastName!,
            profileImageURL: searchedUser.profileImageURL,
            plateNumbers: [searchedUser.plate],
            age: 28,
            bio: "Car enthusiast and road trip lover 🚗",
            sex: "female"
        )

        return SearchProfileResult(
            searchedUser: userSummary,
            chatVM:   ChatListViewModel(chatService: chatService),
            friendVM: FriendViewModel(friendService: FriendService(),
                                      userService: userService)
        )
    }
}
