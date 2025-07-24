import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var showingEditProfile = false
    @State private var showingEditNumberPlates = false
    
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width * 0.95
    }
    private var cardHeight: CGFloat {
        UIScreen.main.bounds.height * 0.55
    }
    
    var circleSize: CGFloat = 150
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack( spacing: 20) {
                    
                    VStack(spacing: 10){
                        UserProfileImage
                    }
                    
                    HStack(alignment: .firstTextBaseline){
                            // Settings Button
                            IconButtonWithLabel(systemImage: "gearshape.fill", label: "Setari") {
                                //TODO: Handle action for setari button
                            }
                            
                            IconButtonWithLabel(systemImage: "pencil", label: "Editeaza profilul") {
                                showingEditProfile = true
                            }
                            
                            IconButtonWithLabel(systemImage: "car.2", label: "Vehicule" ) {
                                showingEditNumberPlates = true
                            }
                            
                            
                            
                            
                        }
                        .padding(.top, 8)
                        
                    
                    
                    Spacer()
                }
                .refreshable {
                    // pull-to-refresh:
                    await viewModel.refreshProfile()
                    await viewModel.loadStats()
                }
            }.padding(.horizontal)
            .overlay {
                // simple loading indicator
                if viewModel.isLoading {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView().scaleEffect(1.5)
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingEditNumberPlates){
                EditNumberPlatesView(authVM: viewModel)
            }
            
        }.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    //TODO: Something
                }label: {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
    }
    
    
    
    private struct IconButtonWithLabel: View {
        let systemImage: String
        let label: String
        let action: () -> Void
        let size: CGFloat = 70
        let iconSize: CGFloat = 32
        let spacing: CGFloat = 15

        var body: some View {
            VStack(spacing: spacing) {
                Button(action: action) {
                    Image(systemName: systemImage)
                        .font(.system(size: iconSize))
                        .foregroundColor(.gray)
                        .frame(width: size, height: size)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.08))
                        )
                }
                .frame(maxWidth: .infinity)

                Text(label)
                    .font(.headline)
                    .bold()
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var UserProfileImage : some View {
        ZStack(alignment: .bottom) {
            if let urlString = viewModel.profileImageURL,
               let imageURL = URL(string: urlString) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(50)
                    }
                }
                .frame(width: cardWidth,
                       height: cardHeight)
                .clipped()
                .background(Color(.systemGray5))
                .cornerRadius(10)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(50)
                    .frame(width: cardWidth,
                           height: cardHeight)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
            
        
            VStack(alignment:.leading, spacing: 9){
               
                HStack(){
                    Text("\(viewModel.user!.firstName), \(viewModel.user!.age)")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                }
                
                HStack(alignment: .center){
                    NumberPlateDisplayView(plate: viewModel.user!.plateNumbers.first ?? "")
                    
                    Spacer()
                    
                }
                
            }.padding(8)
            .background(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
            
            
            
        }.cornerRadius(10)
    }
}

// A tiny stat cell
struct StatView: View {
    let value: Int
    let title: String
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.title)
                .bold()
            
            Text(title)
                .font(.caption)
                
        }
        .frame(maxWidth: .infinity)
        
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview user
        let previewUser = TestData.user
        
        // Create AuthVM with preview user
        let authVM = AuthenticationViewModel(previewUser: previewUser)
        
        // Return the view with AuthVM
        return ProfileView(viewModel: authVM)
            .preferredColorScheme(.light)
    }
}
