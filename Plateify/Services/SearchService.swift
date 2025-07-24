import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SearchService: ObservableObject {
    private let db: Firestore
    
    // Use Firebase Auth directly instead of AuthenticationViewModel
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    init(db: Firestore = .firestore()) {
        self.db = db
        print("DEBUG: SearchService initialized")
    }

    /// Search for a single user by plate number; increments their search count.
    func searchPlate(_ plate: String) async throws -> UserSummary? {
        guard let currentUserId = currentUserId else {
            throw NSError(
                domain: "SearchService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]
            )
        }

        // 1) Find the document
        let snapshot = try await db
            .collection("users")
            .whereField("plateNumbers", arrayContains: plate)
            .getDocuments()

        guard let doc = snapshot.documents.first else {
            print("DEBUG: No user found with plate: \(plate)")
            return nil
        }

        // 2) Log the search
        try await db.collection("searches").addDocument(data: [
            "userId": currentUserId,
            "plateNumber": plate,
            "timestamp": FieldValue.serverTimestamp(),
            "resultFound": true,
            "resultUserId": doc.documentID
        ])

        // 3) Map to UserSummary
        let data = doc.data()
        
        // Extract required fields
        guard let firstName = data["firstName"] as? String else {
            print("DEBUG: User document missing required firstName field")
            return nil
        }
        
        let lastName = data["lastName"] as? String ?? ""
        let profileImageURL = data["profileImageURL"] as? String
        let plateNumbers = data["plateNumbers"] as? [String] ?? []
        
        // Extract optional fields
        let age = data["age"] as? Int
        let bio = data["bio"] as? String
        let sex = data["sex"] as? String

        print("DEBUG: Found user with plate \(plate): \(firstName) \(lastName)")

        // 4) Create and return UserSummary
        return UserSummary(
            id: doc.documentID,
            firstName: firstName,
            lastName: lastName,
            profileImageURL: profileImageURL,
            plateNumbers: plateNumbers,
            age: age,
            bio: bio,
            sex: sex
        )
    }

    /// Search users by username prefix.
    func searchUsers(query: String) async throws -> [UserSummary] {
        print("DEBUG: Searching users with query: \(query)")
        let snapshot = try await db
            .collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query)
            .getDocuments()
            
        let summaries = snapshot.documents.compactMap { doc -> UserSummary? in
            let data = doc.data()
            
            // Extract required fields
            guard let firstName = data["firstName"] as? String else {
                print("DEBUG: User document missing required firstName field: \(doc.documentID)")
                return nil
            }
            
            // Map to UserSummary
            return UserSummary(
                id: doc.documentID,
                firstName: firstName,
                lastName: data["lastName"] as? String ?? "",
                profileImageURL: data["profileImageURL"] as? String,
                plateNumbers: data["plateNumbers"] as? [String] ?? [],
                age: data["age"] as? Int,
                bio: data["bio"] as? String,
                sex: data["sex"] as? String
            )
        }
        
        print("DEBUG: Found \(summaries.count) users matching query")
        return summaries
    }

    /// Fetch this user's recent search history (last 20).
    func fetchRecentSearches() async throws -> [Search] {
        guard let uid = currentUserId else {
            throw NSError(
                domain: "SearchService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]
            )
        }
        print("DEBUG: Fetching recent searches for user: \(uid)")
        let snapshot = try await db
            .collection("searches")
            .whereField("userId", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .limit(to: 20)
            .getDocuments()
        let searches = snapshot.documents.compactMap { try? $0.data(as: Search.self) }
        print("DEBUG: Found \(searches.count) recent searches")
        return searches
    }

    /// Delete all this user's search history.
    func clearSearchHistory() async throws {
        guard let uid = currentUserId else {
            throw NSError(
                domain: "SearchService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]
            )
        }
        print("DEBUG: Clearing search history for user: \(uid)")
        let snapshot = try await db
            .collection("searches")
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        
        for doc in snapshot.documents {
            try await db.collection("searches").document(doc.documentID).delete()
        }
        print("DEBUG: Deleted \(snapshot.documents.count) search history entries")
    }
}
