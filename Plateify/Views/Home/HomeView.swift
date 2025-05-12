import SwiftUI

struct HomeView: View {
    struct NearbyUser: Identifiable {
        let id = UUID()
        let name: String
        let age: Int
        let bio: String
        let profileImageURL: String
        let plate: String
    }
    
    @State private var showFullScreenProfile = false
    
    let users: [NearbyUser] = [
        NearbyUser(name: "Alexandra", age: 24, bio: "Car enthusiast 🚗 | Coffee lover ☕️ | Weekend explorer 🌍", profileImageURL: "https://randomuser.me/api/portraits/men/32.jpg", plate: "B 999 PLT"),
        NearbyUser(name: "Robert", age: 27, bio: "Always up for a new adventure!", profileImageURL: "https://randomuser.me/api/portraits/men/32.jpg", plate: "B 123 XYZ")
    ]
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            if currentIndex < users.count {
                VStack {
                    
                    UserCard(user: users[currentIndex], showFullScreenProfile: $showFullScreenProfile)
                    
                    HStack(spacing: 45) {
                        CircleButton(icon: "xmark", color: .red, label: nil)
                        CircleButton(icon: "heart.fill", color: .green, label: nil)
                    }.padding()
                    
                    
                }
            }
        }.fullScreenCover(isPresented: $showFullScreenProfile){
            
            Text("Full Screen Profile")
        }
    }
}

struct UserCard: View {
    var cardWidth: CGFloat{ UIScreen.main.bounds.width-20
    }
    var cardHeight: CGFloat{ UIScreen.main.bounds.height/1.45
    }
    
    let user: HomeView.NearbyUser
    @State private var showBio = false
    @Binding var showFullScreenProfile : Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: user.profileImageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }.frame(width: cardWidth, height: cardHeight)
                
                
                VStack(alignment: .leading,spacing: 5) {
                    
                    NumberPlateDisplayView(plate: user.plate)
                    
                    HStack(){
                        Text(user.name)
                            .font(.title)
                            .fontWeight(.heavy)
                        
                        Text("\(user.age)")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            showFullScreenProfile.toggle()
                        } label: {
                            Image(systemName:"arrow.up.circle")
                                .fontWeight(.bold)
                                .imageScale(.large)
                        }
                    }.foregroundStyle(Color.white)
                    
                }.padding()
                .background(LinearGradient(colors: [.clear,.black], startPoint: .top, endPoint: .bottom))
            }.frame(width: cardWidth, height: cardHeight)
                .cornerRadius(10)
        }
    }
}


struct CircleButton: View {
    let icon: String
    let color: Color
    let label: String?

    var body: some View {
        VStack(spacing: 8) {
            if let label = label {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundColor(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color, lineWidth: 2)
                    )
                    .opacity(0.9)
            }

            Button(action: {}) {
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
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 
