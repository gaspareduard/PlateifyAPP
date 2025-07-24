import Foundation
import Combine
import SwiftUI

// MARK: - FriendRequestDetail
struct FriendRequestDetail: Identifiable {
    let id: String // Same as the Friend.id
    let friend: Friend
    let userSummary: UserSummary?
    
    var friendId: String { friend.friendId }
    var status: FriendStatus { friend.status }
    var createdAt: Date? { friend.createdAt }
}

@MainActor
class FriendViewModel: ObservableObject {
    // MARK: - View State
    enum ViewState {
        case loading
        case loaded(friends: [Friend], pendingRequests: [Friend])
        case error(String)
    }
    
    // MARK: - Published Properties
    @Published var state: ViewState = .loading
    @Published var searchText: String = ""
    @Published private(set) var hasMatches: Bool = false // True if there is at least one friend or pending request
    @Published var acceptedFriends: [Friend] = [] // Only accepted friends
    @Published var searchResults: [User] = [] // For user search results
    @Published var friendSummaries: [String: UserSummary] = [:] // Cache for user details
    @Published var acceptedFriendDetails: [FriendRequestDetail] = [] // Details for accepted friends
    @Published var pendingFriendDetails: [FriendRequestDetail] = [] // Details for pending requests
    
    // MARK: - Dependencies
    private let friendService: FriendService
    private let userService: UserService
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(friendService: FriendService, userService: UserService) {
        self.friendService = friendService
        self.userService = userService
        setupSubscriptions()
        print("DEBUG: FriendViewModel initialized with FriendService and UserService")
    }
    
    private func setupSubscriptions() {
        // Combine both friends and pending requests into a single state
        friendService.$friends
            .combineLatest(friendService.$pendingRequests, friendService.$error)
            .sink { [weak self] friends, pendingRequests, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("DEBUG: FriendService error: \(error.localizedDescription)")
                    self.state = .error(error.localizedDescription)
                    self.hasMatches = false
                    self.acceptedFriends = []
                    self.acceptedFriendDetails = []
                    self.pendingFriendDetails = []
                    return
                }
                
                self.state = .loaded(friends: friends, pendingRequests: pendingRequests)
                self.acceptedFriends = friends.filter { $0.status == .accepted }
                
                // Update hasMatches based on both accepted friends and pending requests
                self.hasMatches = !friends.isEmpty || !pendingRequests.isEmpty
                print("DEBUG: Updated matches state - Has matches: \(self.hasMatches) (Friends: \(friends.count), Pending: \(pendingRequests.count))")
                
                // Load user details for all friends and pending requests
                Task {
                    await self.updateFriendDetails(friends: friends, pendingRequests: pendingRequests)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Friend Details Management
    private func updateFriendDetails(friends: [Friend], pendingRequests: [Friend]) async {
        print("DEBUG: Updating friend details for \(friends.count + pendingRequests.count) requests")
        
        // Get unique user IDs from both friends and pending requests
        let allUserIds = Set(friends.map { $0.friendId } + pendingRequests.map { $0.userId })
        
        do {
            // Fetch summaries for all unique user IDs
            let summaries = try await userService.fetchUserSummaries(ids: Array(allUserIds))
            
            // Update accepted friend details
            let acceptedDetails = friends.compactMap { friend -> FriendRequestDetail? in
                guard let id = friend.id else {
                    print("DEBUG: Friend missing ID, skipping")
                    return nil
                }
                
                return FriendRequestDetail(
                    id: id,
                    friend: friend,
                    userSummary: summaries[friend.friendId]
                )
            }
            
            // Update pending friend details
            let pendingDetails = pendingRequests.compactMap { request -> FriendRequestDetail? in
                guard let id = request.id else {
                    print("DEBUG: Pending request missing ID, skipping")
                    return nil
                }
                
                return FriendRequestDetail(
                    id: id,
                    friend: request,
                    userSummary: summaries[request.userId]
                )
            }
            
            // Update published properties
            acceptedFriendDetails = acceptedDetails
            pendingFriendDetails = pendingDetails
            print("DEBUG: Updated \(acceptedDetails.count) accepted and \(pendingDetails.count) pending friend details")
            
        } catch {
            print("DEBUG: Failed to update friend details: \(error.localizedDescription)")
            state = .error("Failed to update friend details: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Access Methods
    func userSummary(for friendId: String) -> UserSummary? {
        friendSummaries[friendId]
    }
    
    func getSummariesForFriends(_ friends: [Friend]) -> [(Friend, UserSummary?)] {
        return friends.map { friend in
            (friend, friendSummaries[friend.friendId])
        }
    }
    
    // MARK: - Friend Request Detail Access
    func getAcceptedFriendDetails() -> [FriendRequestDetail] {
        return acceptedFriendDetails
    }
    
    func getPendingRequestDetails() -> [FriendRequestDetail] {
        return pendingFriendDetails
    }
    
    func getFriendRequestDetail(for friendId: String) -> FriendRequestDetail? {
        return acceptedFriendDetails.first { $0.friendId == friendId } ??
               pendingFriendDetails.first { $0.friendId == friendId }
    }
    
    // MARK: - Lifecycle
    func startListening() {
        print("DEBUG: Starting friend service listeners")
        friendService.startListening()
    }
    
    func stopListening() {
        print("DEBUG: Stopping friend service listeners")
        friendService.stopListening()
        searchTask?.cancel()
    }
    
    // MARK: - Data Loading
    func loadFriends() {
        print("DEBUG: Loading friends data")
        // Always set to loading state when explicitly loading friends
        // This provides immediate UI feedback
        state = .loading
        // Actual data will be loaded via the friendService listeners
    }
    
    func refreshFriends() async {
        print("DEBUG: Refreshing friends data")
        state = .loading
        
        // Clear current data
        acceptedFriends = []
        acceptedFriendDetails = []
        pendingFriendDetails = []
        friendSummaries = [:]
        
        // Force refresh by stopping and restarting listeners
        friendService.stopListening()
        friendService.startListening()
        
        // Wait a moment for the listeners to pick up fresh data
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        print("DEBUG: Friends refresh completed")
    }
    
    // MARK: - Friend Operations
    func sendFriendRequest(to userId: String) async {
        do {
            print("DEBUG: Sending friend request to user: \(userId)")
            try await friendService.sendFriendRequest(to: userId)
            // State will update automatically via subscriptions
        } catch {
            print("DEBUG: Failed to send friend request: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }
    
    func acceptFriendRequest(_ request: Friend) async {
        guard let requestId = request.id else {
            print("DEBUG: Invalid request ID for friend request acceptance")
            state = .error("Invalid request ID")
            return
        }
        
        do {
            print("DEBUG: Accepting friend request: \(requestId)")
            try await friendService.acceptFriendRequest(request)
            // State will update automatically via subscriptions
        } catch {
            print("DEBUG: Failed to accept friend request: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }
    
    func rejectFriendRequest(_ request: Friend) async {
        guard let requestId = request.id else {
            print("DEBUG: Invalid request ID for friend request rejection")
            state = .error("Invalid request ID")
            return
        }
        
        do {
            print("DEBUG: Rejecting friend request: \(requestId)")
            try await friendService.rejectFriendRequest(request)
            // State will update automatically via subscriptions
        } catch {
            print("DEBUG: Failed to reject friend request: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }
    
    func removeFriend(_ friend: Friend) async {
        guard let friendId = friend.id else {
            print("DEBUG: Invalid friend ID for removal")
            state = .error("Invalid friend ID")
            return
        }
        
        do {
            print("DEBUG: Removing friend: \(friendId)")
            try await friendService.removeFriend(friend)
            // State will update automatically via subscriptions
        } catch {
            print("DEBUG: Failed to remove friend: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }
    
    func blockUser(_ userId: String) async {
        do {
            print("DEBUG: Blocking user: \(userId)")
            try await friendService.blockUser(userId)
            // State will update automatically via subscriptions
        } catch {
            print("DEBUG: Failed to block user: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Search
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask?.cancel()
        searchTask = Task {
            do {
                print("DEBUG: Searching users with query: \(query)")
                let results = try await friendService.searchUsers(query: query)
                if !Task.isCancelled {
                    searchResults = results
                    print("DEBUG: Found \(results.count) users matching query")
                }
            } catch {
                print("DEBUG: Search failed: \(error.localizedDescription)")
                if !Task.isCancelled {
                    state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    var friends: [Friend] {
        if case .loaded(let friends, _) = state {
            return friends
        }
        return []
    }
    
    var pendingRequests: [Friend] {
        if case .loaded(_, let requests) = state {
            return requests
        }
        return []
    }
    
    var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = state {
            return message
        }
        return nil
    }
}
