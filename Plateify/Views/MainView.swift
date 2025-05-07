import SwiftUI

struct MainView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(1)
                    
                    ChatListView()
                        .tabItem {
                            Label("Chats", systemImage: "message.fill")
                        }
                        .tag(2)
                    
                    FriendsView()
                        .tabItem {
                            Label("Friends", systemImage: "person.2.fill")
                        }
                        .tag(3)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(4)
                }
            } else {
                NavigationStack {
                    SignInView()
                }
            }
        }
        .environmentObject(authViewModel)
    }
}

#Preview {
    MainView()
} 