//
//  PlateifyApp.swift
//  Plateify
//
//  Created by Eduard Gaspar on 28.03.2025.
//

import SwiftUI
import FirebaseCore

@main
struct PlateifyApp: App {
    @StateObject private var authVM    = AuthenticationViewModel()
    @StateObject private var userSvc   = UserService()
    @StateObject private var friendSvc = FriendService()
    @StateObject private var nearbySvc = NearbyUserService()
    @StateObject private var chatSvc   = ChatService()
    @StateObject private var searchSvc = SearchService()
    
    
    init() {
        FirebaseApp.configure()
        setupAppearance()
        print("DEBUG: PlateifyApp initialized with services")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let user = authVM.user, !user.hasCompletedOnboarding {
                    OnboardingCarouselView(vm: OnboardingViewModel(
                        authVM: authVM,
                        userService: userSvc))
                    
                } else if authVM.isAuthenticated {
                    MainView(chatService:  chatSvc,
                             searchService: searchSvc,
                             userSvc:       userSvc,
                             friendSvc:     friendSvc,
                             nearbySvc:     nearbySvc)
                    
                } else {
                    SignInView()}
                
            }.environmentObject(authVM)
                .environmentObject(userSvc)
                .environmentObject(friendSvc)
                .environmentObject(nearbySvc)
                .environmentObject(chatSvc)
                .environmentObject(searchSvc)
                .preferredColorScheme(.light)
        }
    }
    
    private func setupAppearance() {
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Customize tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
