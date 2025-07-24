import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authVM: AuthenticationViewModel
    @EnvironmentObject private var userSvc: UserService
    @EnvironmentObject private var friendSvc: FriendService
    @EnvironmentObject private var nearbySvc: NearbyUserService
    @EnvironmentObject private var chatSvc: ChatService
    @EnvironmentObject private var searchSvc: SearchService

    @StateObject private var chatVM: ChatListViewModel
    @StateObject private var searchVM: SearchViewModel
    @StateObject private var nearbyVM: HomeViewModel
    @StateObject private var friendVM: FriendViewModel

    @State private var selectedTab = 0
    
    init(chatService: ChatService,
         searchService: SearchService,
         userSvc: UserService,
         friendSvc: FriendService,
         nearbySvc: NearbyUserService){
        
        _chatVM = StateObject(wrappedValue: ChatListViewModel(
            chatService: chatService))
        
        _searchVM = StateObject(wrappedValue: SearchViewModel(
            searchService: searchService,
            friendService: friendSvc,
            chatService: chatService))
        
        _nearbyVM = StateObject(wrappedValue: HomeViewModel(
            nearbyService: nearbySvc,
            friendService: friendSvc))
        
        _friendVM = StateObject(wrappedValue: FriendViewModel(
            friendService: friendSvc,
            userService: userSvc))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoverView(viewModel: nearbyVM)
                .tabItem { Label("Home",    systemImage: "house.fill") }
                .tag(0)

            SearchView(viewModel: searchVM,
                       ChatVM: chatVM,
                       FriendVM: friendVM)
                .tabItem { Label("Search",  systemImage: "magnifyingglass") }
                .tag(1)

            ChatTabMenuView(viewModel: chatVM,
                            friendViewModel: friendVM)
                .tabItem { Label("Chats",   systemImage: "message.fill") }
                .tag(2)

            LikesView(viewModel: friendVM)
                .tabItem { Label("Friends", systemImage: "star.circle") }
                .tag(3)

            ProfileView(viewModel: authVM)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        // When the user changes (e.g. logs out), you can react here
        .onChange(of: authVM.user) { newUser in
            if newUser == nil {
                print("DEBUG: User logged out, maybe switch to SignInView")
            }
        }
        // Start all service listeners when view appears
        .task {
            print("DEBUG: Starting all service listeners in MainView")
            // Start friend service listener
            friendSvc.startListening()
            // Start chat service listener
            chatSvc.listenToChats()
            
            // Preload profile data
            await authVM.refreshProfile()
            await authVM.loadStats()
            print("DEBUG: Profile data refreshed on app start")
        }
        // Stop all service listeners when view disappears
        .onDisappear {
            print("DEBUG: Stopping all service listeners in MainView")
            friendSvc.stopListening()
            chatSvc.stopListening()
        }
    }
}

