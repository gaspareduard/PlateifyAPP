import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

@MainActor
class NearbyUserService: ObservableObject {
    private let db: Firestore

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    
    /// Fetches and returns nearby users, excluding the current user, friends, and pending requests,
    /// and sorted by distance if a location is provided.
    func fetchNearbyUsers(
        excluding friends: [Friend],
        pendingRequests: [Friend],
        location: CLLocation?
    ) async throws -> [NearbyUser] {
        guard let currentId = currentUserId else {
            throw NSError(
                domain: "NearbyUserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }
        
        // 1. Load all users
        let snapshot = try await db.collection("users").getDocuments()
        let allUsers: [NearbyUser] = try snapshot.documents.compactMap { doc in
            var user = try doc.data(as: NearbyUser.self)
            user.id = doc.documentID
            return user
        }
        
        // 2. Exclude self, friends, and pending requests
        let excludedIDs = Set(
            friends.map { $0.friendId } +
            pendingRequests.map { $0.friendId } +
            [currentId]
        )
        var candidates = allUsers.filter { user in
            if let id = user.id {
                return !excludedIDs.contains(id)
            }
            return false
        }
        
        // 3. Sort by distance if location available
        if let loc = location {
            candidates.sort { u1, u2 in
                (u1.distance(from: loc) ?? Int.max) < (u2.distance(from: loc) ?? Int.max)
            }
        }
        
        return candidates
    }
    
    /// Updates the current user's location in Firestore.
    func updateUserLocation(_ location: CLLocation) async throws {
        guard let uid = currentUserId else {
            throw NSError(
                domain: "NearbyUserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }
        try await db.collection("users").document(uid).updateData([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "lastLocationUpdate": FieldValue.serverTimestamp()
        ])
    }
}
