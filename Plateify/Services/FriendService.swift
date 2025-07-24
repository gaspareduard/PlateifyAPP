// FriendService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FriendService: ObservableObject {
    // MARK: - Published State
    @Published private(set) var friends: [Friend] = []
    @Published private(set) var pendingRequests: [Friend] = []
    @Published var error: Error?

    private let db = Firestore.firestore()
    private var friendsListener: ListenerRegistration?
    private var requestsListener: ListenerRegistration?

    init() {
    }

    // MARK: - Listening
    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Accepted friends
        friendsListener = db.collection("friends")
            .whereField("userId", isEqualTo: uid)
            .whereField("status", isEqualTo: FriendStatus.accepted.rawValue)
            .addSnapshotListener { [weak self] snap, err in
                if let err = err {
                    self?.error = err
                } else {
                    self?.friends = snap?.documents.compactMap {
                        try? $0.data(as: Friend.self)
                    } ?? []
                }
            }

        // Pending incoming requests
        requestsListener = db.collection("friends")
            .whereField("friendId", isEqualTo: uid)
            .whereField("status", isEqualTo: FriendStatus.pending.rawValue)
            .addSnapshotListener { [weak self] snap, err in
                if let err = err {
                    self?.error = err
                } else {
                    self?.pendingRequests = snap?.documents.compactMap {
                        try? $0.data(as: Friend.self)
                    } ?? []
                }
            }
    }

    func stopListening() {
        friendsListener?.remove()
        requestsListener?.remove()
    }

    // MARK: - Friend Actions
    func sendFriendRequest(to userId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // Check for existing outgoing request
        try await checkExistingOutgoingRequest(from: uid, to: userId)
        
        // Check for incoming request and auto-accept if exists
        if try await handleExistingIncomingRequest(from: userId, to: uid) {
            return // Request was auto-accepted, exit early
        }
        
        // Check if blocked
        try await checkIfBlocked(by: userId, user: uid)
        
        // Check if already friends
        try await checkExistingFriendship(between: uid, and: userId)
        
        let req = Friend(
            id: nil,
            userId: uid,
            friendId: userId,
            status: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        _ = try db.collection("friends").addDocument(from: req)
    }
    
    // MARK: - Helper Functions
    
    /// Checks if there's already an outgoing friend request
    private func checkExistingOutgoingRequest(from uid: String, to userId: String) async throws {
        let existingRequestQuery = try await db.collection("friends")
            .whereField("userId", isEqualTo: uid)
            .whereField("friendId", isEqualTo: userId)
            .whereField("status", isEqualTo: FriendStatus.pending.rawValue)
            .getDocuments()
        
        guard existingRequestQuery.documents.isEmpty else {
            print("DEBUG: Friend request already exists")
            throw NSError(domain: "FriendService", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "You already sent a friend request to this user"])
        }
    }
    
    /// Checks for and handles incoming friend requests
    /// Returns true if an incoming request was found and accepted
    private func handleExistingIncomingRequest(from userId: String, to uid: String) async throws -> Bool {
        let incomingRequestQuery = try await db.collection("friends")
            .whereField("userId", isEqualTo: userId)
            .whereField("friendId", isEqualTo: uid)
            .whereField("status", isEqualTo: FriendStatus.pending.rawValue)
            .getDocuments()
        
        if let incomingRequest = incomingRequestQuery.documents.first,
           let requestId = incomingRequest.documentID as String? {
            // Auto-accept the incoming request instead of creating a new one
            try await db.collection("friends").document(requestId).updateData([
                "status": FriendStatus.accepted.rawValue,
                "updatedAt": Timestamp(date: Date())
            ])
            print("DEBUG: Auto-accepted incoming friend request")
            return true
        }
        
        return false
    }
    
    /// Checks if the current user is blocked by the target user
    private func checkIfBlocked(by userId: String, user uid: String) async throws {
        let blockQuery = try await db.collection("friends")
            .whereField("userId", isEqualTo: userId)
            .whereField("friendId", isEqualTo: uid)
            .whereField("status", isEqualTo: FriendStatus.blocked.rawValue)
            .getDocuments()
        
        guard blockQuery.documents.isEmpty else {
            print("DEBUG: Cannot send request - you may be blocked by this user")
            throw NSError(domain: "FriendService", code: -3,
                          userInfo: [NSLocalizedDescriptionKey: "Cannot send friend request to this user"])
        }
    }
    
    /// Checks if users are already friends
    private func checkExistingFriendship(between uid: String, and userId: String) async throws {
        let existingFriendshipQuery = try await db.collection("friends")
            .whereField("userId", isEqualTo: uid)
            .whereField("friendId", isEqualTo: userId)
            .whereField("status", isEqualTo: FriendStatus.accepted.rawValue)
            .getDocuments()
        
        guard existingFriendshipQuery.documents.isEmpty else {
            print("DEBUG: Users are already friends")
            throw NSError(domain: "FriendService", code: -4,
                          userInfo: [NSLocalizedDescriptionKey: "You are already friends with this user"])
        }
    }

    func acceptFriendRequest(_ request: Friend) async throws {
        guard let docId = request.id else {
            throw NSError(domain: "FriendService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid request ID"])
        }
        try await db.collection("friends").document(docId).updateData([
            "status":    FriendStatus.accepted.rawValue,
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func rejectFriendRequest(_ request: Friend) async throws {
        guard let docId = request.id else {
            throw NSError(domain: "FriendService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid request ID"])
        }
        try await db.collection("friends").document(docId).delete()
    }
    
    func removeFriend(_ friend: Friend) async throws {
        guard let docId = friend.id else {
            throw NSError(domain: "FriendService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid friend ID"])
        }
        try await db.collection("friends").document(docId).delete()
    }

    func blockUser(_ userId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        let block = Friend(
            id: nil,
            userId: uid,
            friendId: userId,
            status: .blocked,
            createdAt: Date(),
            updatedAt: Date()
        )
        _ = try db.collection("friends").addDocument(from: block)
    }

    // MARK: - Search for New Friends
    func searchUsers(query: String) async throws -> [User] {
        let snap = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query)
            .whereField("username", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: User.self) }
    }
}
