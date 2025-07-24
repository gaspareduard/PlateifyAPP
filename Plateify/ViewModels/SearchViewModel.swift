import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    // MARK: — Published state for the View
    @Published var searchResults: [UserSummary] = []
    @Published var recentSearches: [Search] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: — Dependencies
    private let searchService: SearchService
    private let friendService: FriendService
    private let chatService: ChatService

    // MARK: — Init with required services
    init(
        searchService: SearchService,
        friendService: FriendService,
        chatService: ChatService
    ) {
        self.searchService = searchService
        self.friendService = friendService
        self.chatService = chatService
        print("DEBUG: SearchViewModel initialized with services")
    }

    // MARK: — Helper to wrap loading + error handling
    private func perform(_ operation: () async throws -> Void) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await operation()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("DEBUG: Operation failed with error: \(error.localizedDescription)")
        }
    }

    // MARK: — Search APIs

    func searchPlate(_ plate: String) async {
        guard !plate.isEmpty else {
            searchResults = []
            return
        }
        
        await perform {
            if let result = try await searchService.searchPlate(plate) {
                searchResults = [result]
                print("DEBUG: Found user with plate \(plate): \(result.displayName)")
            } else {
                searchResults = []
                print("DEBUG: No user found with plate \(plate)")
            }
        }
    }

    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        await perform {
            // Now directly using UserSummary from the service
            searchResults = try await searchService.searchUsers(query: query)
            print("DEBUG: Found \(searchResults.count) users matching query: \(query)")
        }
    }

    func fetchRecentSearches() async {
        await perform {
            recentSearches = try await searchService.fetchRecentSearches()
            print("DEBUG: Fetched \(recentSearches.count) recent searches")
        }
    }

    func clearSearchHistory() async {
        await perform {
            try await searchService.clearSearchHistory()
            recentSearches = []
            print("DEBUG: Search history cleared")
        }
    }

    // MARK: — Actions on a found user

    func sendFriendRequest(to userId: String) async {
        await perform {
            try await friendService.sendFriendRequest(to: userId)
            print("DEBUG: Friend request sent to user: \(userId)")
        }
    }

    func startChat(with userId: String) async {
        await perform {
            let chat = try await chatService.createChat(with: userId)
            print("DEBUG: Chat created with user: \(userId), chatId: \(chat.id ?? "nil")")
        }
    }
}
