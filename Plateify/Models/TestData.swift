import Foundation
import FirebaseFirestore

@MainActor
struct TestData {
    // MARK: - User Data
    static let user = User(
        id: "preview-user-123",
        username: "johndoe",
        email: "john@example.com",
        firstName: "John",
        lastName: "Doe",
        plateNumbers: ["B827HJU", "TM65UUU"],
        bio: "Car enthusiast and road trip lover 🚗",
        profileImageURL: "https://randomuser.me/api/portraits/men/32.jpg",
        isOnline: true,
        lastSeen: Date(),
        privacySettings: PrivacySettings(
            showPlateInSearch: true,
            acceptDMsFromAnyone: true,
            showOnlineStatus: true
        ),
        createdAt: Date().addingTimeInterval(-86400 * 30),
        updatedAt: Date(),
        hasCompletedOnboarding: true,
        plateSearchCount: 15,
        sex: "male",
        allowNearbyDiscovery: true,
        allowPlateSuggestions: true,
        latitude: 44.4268,
        longitude: 26.1025,
        lastLocationUpdate: Date(),
        birthdate: Calendar.current.date(from: DateComponents(year: 1990, month: 6, day: 15)),
        preferredSex: "female",
        maxDiscoveryDistance: 50
        
    )
    
    // MARK: - Nearby Users
    static let nearbyUsers = [
        NearbyUser(
            id: "nearby-1",
            profileImageURL: "https://randomuser.me/api/portraits/women/68.jpg",
            plateNumbers: ["TM22FEF"],
            firstName: "Alice",
            age: 29,
            bio: "Spontaneous road trips & coffee addict",
            latitude: 44.4268,
            longitude: 26.1025
        ),
        NearbyUser(
            id: "nearby-2",
            profileImageURL: "https://randomuser.me/api/portraits/men/42.jpg",
            plateNumbers: ["TM34HHH"],
            firstName: "Bob",
            age: 32,
            bio: "Tech lead by day, cyclist by evening",
            latitude: 44.4397,
            longitude: 26.0963
        )
    ]
    
    // MARK: - Friends
    static let friends = [
        Friend(
            id: "friend-1",
            userId: "preview-user-123",
            friendId: "friend-1-id",
            status: .accepted,
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date()
        ),
        Friend(
            id: "friend-2",
            userId: "preview-user-123",
            friendId: "friend-2-id",
            status: .accepted,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            updatedAt: Date().addingTimeInterval(-3600)
        )
    ]
    
    // MARK: - Chats
    static let chats = [
        Chat(
            id: "chat-1",
            participants: ["preview-user-123", "friend-1-id"],
            lastMessage: "Hey, how's it going?",
            lastMessageTimestamp: Date(),
            lastMessageSenderId: "friend-1-id",
            unreadCount: ["preview-user-123": 2],
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date()
        ),
        Chat(
            id: "chat-2",
            participants: ["preview-user-123", "friend-2-id"],
            lastMessage: "See you tomorrow!",
            lastMessageTimestamp: Date().addingTimeInterval(-3600),
            lastMessageSenderId: "preview-user-123",
            unreadCount: [:],
            createdAt: Date().addingTimeInterval(-86400 * 2),
            updatedAt: Date().addingTimeInterval(-3600)
        )
    ]
    
    // MARK: - Search Results
    static let searchResults = [
        SearchResult(
            id: "search-1",
            username: "alicesmith",
            firstName: "Alice",
            lastName: "Smith",
            profileImageURL: "https://randomuser.me/api/portraits/women/68.jpg",
            plate: "TM98JKL"
        )
    ]
    
    // MARK: - Recent Searches
    static let recentSearches = [
        Search(
            id: "recent-1",
            userId: "preview-user-123",
            plateNumber: "HD65TYU",
            timestamp: Date().addingTimeInterval(-3600),
            resultFound: true,
            resultUserId: "friend-1-id"
        )
    ]
    
    // MARK: - User Summaries for Friends and Chat Participants
    static let userSummaries = [
        UserSummary(
            id: "friend-1-id",
            firstName: "Alice",
            lastName: "Smith",
            profileImageURL: "https://randomuser.me/api/portraits/women/68.jpg",
            plateNumbers: ["TM22FEF"],
            age: 29,
            bio: "Spontaneous road trips & coffee addict",
            sex: "female"
        ),
        UserSummary(
            id: "friend-2-id",
            firstName: "Bob",
            lastName: "Johnson",
            profileImageURL: "https://randomuser.me/api/portraits/men/42.jpg",
            plateNumbers: ["TM34HHH"],
            age: 32,
            bio: "Tech lead by day, cyclist by evening",
            sex: "male"
        )
    ]
    
    // MARK: - Mock Services
    static func mockUserService() -> UserService {
        let db = Firestore.firestore()
        let service = UserService(db: db)
        service.currentUser = user
        print("DEBUG: Mock UserService created with test data")
        return service
    }
    
    static func mockChatService() -> ChatService {
        let service = ChatService()
        print("DEBUG: Mock ChatService created")
        return service
    }
    
    static func mockFriendService() -> FriendService {
        let service = FriendService()
        print("DEBUG: Mock FriendService created")
        return service
    }
    
    static func mockNearbyService() -> NearbyUserService {
        let service = NearbyUserService()
        print("DEBUG: Mock NearbyUserService created")
        return service
    }
    
    static func mockSearchService() -> SearchService {
        let db = Firestore.firestore()
        let service = SearchService(db: db)
        print("DEBUG: Mock SearchService created")
        return service
    }
    
    static func mockSearchResults() -> [SearchResult] {
        return searchResults
    }
    
    // Keep the existing createMockServices for backward compatibility
    static func createMockServices() async -> (
        userService: UserService,
        friendService: FriendService,
        nearbyService: NearbyUserService,
        chatService: ChatService,
        searchService: SearchService,
        authVM: AuthenticationViewModel
    ) {
        let userService = mockUserService()
        let friendService = mockFriendService()
        let nearbyService = mockNearbyService()
        let chatService = mockChatService()
        let searchService = mockSearchService()
        let authVM = AuthenticationViewModel(previewUser: user, userService: userService)
        
        print("DEBUG: All mock services created")
        return (userService, friendService, nearbyService, chatService, searchService, authVM)
    }
}
