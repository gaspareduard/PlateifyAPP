import Foundation
import CoreLocation
import FirebaseFirestore

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var username: String
    var email: String
    var firstName: String
    var lastName: String
    var plateNumbers: [String]
    var bio: String?
    var profileImageURL: String?
    var isOnline: Bool
    @ServerTimestamp var lastSeen: Date?
    var privacySettings: PrivacySettings
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    var hasCompletedOnboarding: Bool
    var plateSearchCount: Int
    var sex: String
    var allowNearbyDiscovery: Bool
    var allowPlateSuggestions: Bool
    var latitude: Double?
    var longitude: Double?
    @ServerTimestamp var lastLocationUpdate: Date?
    var birthdate: Date?
    var preferredSex: String?
    var maxDiscoveryDistance: Int?
    
    var fullName: String { "\(firstName) \(lastName)" }
    var displayName: String { firstName }
    
    var age: Int? {
        guard let bd = birthdate else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: bd, to: now)
        return components.year
    }
    
    // Implement Equatable
    static func == (lhs: User, rhs: User) -> Bool {
        // Compare by ID if available, otherwise by email which should be unique
        if let lhsId = lhs.id, let rhsId = rhs.id {
            return lhsId == rhsId
        }
        return lhs.email == rhs.email
    }
}

struct PrivacySettings: Codable, Equatable {
    var showPlateInSearch: Bool
    var acceptDMsFromAnyone: Bool
    var showOnlineStatus: Bool
}
  


