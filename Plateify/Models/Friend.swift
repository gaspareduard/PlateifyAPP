import Foundation
import FirebaseFirestore

struct Friend: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var friendId: String
    var status: FriendStatus
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    
    
    var isPending: Bool { status == .pending }
    var isaccepted: Bool { status == .accepted }
}

enum FriendStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case blocked
}


