import Foundation

struct UserSummary: Identifiable, Codable, Equatable {
    let id: String                       // Firestore document ID
    let firstName: String
    let lastName: String                 // rename for consistency
    let profileImageURL: String?         // avatar
    let plateNumbers: [String]           // one or more plates
    let age: Int?                        // optional, if you calculate/store it
    let bio: String?                     // optional user bio
    let sex: String?                     // “Male”/“Female”/etc.

    // MARK: – Computed helpers

    /// Display name: prefer full name, fallback to user ID
    var displayName: String {
        if !firstName.isEmpty || !lastName.isEmpty {
            return "\(firstName)".trimmingCharacters(in: .whitespaces)
        } else {
            return id }
    }
    
    /// Primary plate for quick display
    var primaryPlate: String? {
        plateNumbers.first
    }
}
