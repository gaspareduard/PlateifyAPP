import Foundation
import FirebaseFirestore

struct Search: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var plateNumber: String
    @ServerTimestamp var timestamp: Date?
    var resultFound: Bool
    var resultUserId: String?
}

struct SearchResult: Identifiable {
  let id: String
  let username: String
  let firstName: String?
  let lastName: String?
  let profileImageURL: String?
  let plate: String
}
