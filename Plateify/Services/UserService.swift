import Foundation
import FirebaseFirestore
import FirebaseStorage

class UserService: ObservableObject {
    // MARK: - Dependencies
    private let db: Firestore
    private let storage: Storage

    // MARK: - Published State
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Initializer
    init(
        db: Firestore = Firestore.firestore(),
        storage: Storage = Storage.storage()
    ) {
        self.db = db
        self.storage = storage
    }

    // MARK: - Create User
    func createUser(_ user: User) async throws {
        isLoading = true
        defer { isLoading = false }

        guard let id = user.id else {
            throw NSError(domain: "UserService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid user ID"])
        }
        try await db
            .collection("users")
            .document(id)
            .setData(from: user)
        currentUser = user
    }

    // MARK: - Update User
    func updateUser(_ user: User) async throws {
        isLoading = true
        defer { isLoading = false }

        guard let id = user.id else {
            throw NSError(domain: "UserService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid user ID"])
        }
        try await db
            .collection("users")
            .document(id)
            .setData(from: user, merge: true)
        currentUser = user
    }

    // MARK: - Fetch User
    @discardableResult
    func fetchUser(id: String) async throws -> User {
        isLoading = true
        defer { isLoading = false }

        let user: User = try await db
            .collection("users")
            .document(id)
            .getDocument(as: User.self)
        currentUser = user
        return user
    }

    // MARK: - Fetch User Summary
    @discardableResult
    func fetchUserSummary(id: String) async throws -> UserSummary {
        print("DEBUG: Fetching summary for user \(id)")
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch the user document
            let document = try await db
                .collection("users")
                .document(id)
                .getDocument()
            
            guard document.exists else {
                print("DEBUG: User document not found for ID: \(id)")
                throw NSError(domain: "UserService", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            guard let data = document.data() else {
                print("DEBUG: User document exists but has no data for ID: \(id)")
                throw NSError(domain: "UserService", code: -2,
                             userInfo: [NSLocalizedDescriptionKey: "User data is empty"])
            }
            
            // Extract only the fields needed for UserSummary
            guard let firstName = data["firstName"] as? String,
                  let lastName = data["lastName"] as? String,
                  let plateNumbers = data["plateNumbers"] as? [String],
                  let sex = data["sex"] as? String else {
                print("DEBUG: Missing required fields in user data for ID: \(id)")
                throw NSError(domain: "UserService", code: -3,
                             userInfo: [NSLocalizedDescriptionKey: "User data is incomplete"])
            }
            
            // Optional fields
            let profileImageURL = data["profileImageURL"] as? String
            let bio = data["bio"] as? String
            
            // Calculate age from birthdate if available
            var age: Int? = nil
            if let birthdateTimestamp = data["birthdate"] as? Timestamp {
                let birthdate = birthdateTimestamp.dateValue()
                age = Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year
            }
            
            // Create and return the UserSummary
            let summary = UserSummary(
                id: id,
                firstName: firstName,
                lastName: lastName,
                profileImageURL: profileImageURL,
                plateNumbers: plateNumbers,
                age: age,
                bio: bio,
                sex: sex
            )
            
            print("DEBUG: Successfully fetched user summary for ID: \(id)")
            return summary
            
        } catch {
            print("DEBUG: Error fetching user summary: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Fetch Multiple User Summaries
    func fetchUserSummaries(ids: [String]) async throws -> [String: UserSummary] {
        print("DEBUG: Fetching summaries for \(ids.count) users")
        isLoading = true
        defer { isLoading = false }
        
        var summaries: [String: UserSummary] = [:]
        
        // Process in batches to avoid overloading Firestore
        let batchSize = 10
        for i in stride(from: 0, to: ids.count, by: batchSize) {
            let end = min(i + batchSize, ids.count)
            let batchIds = Array(ids[i..<end])
            
            print("DEBUG: Processing batch \(i/batchSize + 1) with \(batchIds.count) users")
            
            // Create async tasks for each ID in the batch
            try await withThrowingTaskGroup(of: (String, UserSummary).self) { group in
                for id in batchIds {
                    group.addTask {
                        let summary = try await self.fetchUserSummary(id: id)
                        return (id, summary)
                    }
                }
                
                // Collect results
                for try await (id, summary) in group {
                    summaries[id] = summary
                }
            }
        }
        
        print("DEBUG: Successfully fetched \(summaries.count) user summaries")
        return summaries
    }

    // MARK: - Profile Image Upload
    func uploadProfileImage(
        _ imageData: Data,
        userId: String
    ) async throws -> URL {
        isLoading = true
        defer { isLoading = false }

        // Validate
        guard !imageData.isEmpty else {
            throw NSError(domain: "UserService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Image data is empty"])
        }
        let maxSize = 5 * 1024 * 1024
        guard imageData.count <= maxSize else {
            throw NSError(domain: "UserService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Image size exceeds 5MB"])
        }

        // Upload
        let timestamp = Int(Date().timeIntervalSince1970)
        let path = "profile_images/\(userId)_\(timestamp).jpg"
        let ref = storage.reference().child(path)
        let metadata = StorageMetadata(); metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url
    }

    // MARK: - Search Users
    func searchUsers(query: String) async throws -> [User] {
        isLoading = true
        defer { isLoading = false }

        let snapshot = try await db
            .collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query)
            .whereField("username", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments()

        return try snapshot.documents.map { doc in
            try doc.data(as: User.self)
        }
    }

    // MARK: - Update Online Status
    func updateOnlineStatus(isOnline: Bool) async throws {
        guard let id = currentUser?.id else { return }

        try await db
            .collection("users")
            .document(id)
            .updateData([
                "isOnline": isOnline,
                "lastSeen": FieldValue.serverTimestamp()
            ])
        currentUser?.isOnline = isOnline
    }
}

@MainActor
extension UserService {
  // Deletes the current user's Firestore document and (optionally) the Auth account.
  func deleteCurrentUserDocument(id: String) async throws {
    try await db.collection("users").document(id).delete()
  }

  // Fetches friend/chat/search count for a given user.
  func fetchStats(for userId: String) async throws -> (friends: Int, chats: Int, searches: Int) {
    let friendsSnap = try await db.collection("friends")
      .whereField("userId", isEqualTo: userId)
      .whereField("status", isEqualTo: FriendStatus.accepted.rawValue)
      .getDocuments()
    let chatsSnap = try await db.collection("chats")
      .whereField("participants", arrayContains: userId)
      .getDocuments()
    let searchesSnap = try await db.collection("searches")
      .whereField("userId", isEqualTo: userId)
      .getDocuments()
    return (friendsSnap.count, chatsSnap.count, searchesSnap.count)
  }
}
