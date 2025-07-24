import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var senderId: String
    var receiverId: String
    var content: String
    @ServerTimestamp var timestamp: Date?
    var isRead: Bool
    var type: MessageType

    enum MessageType: String, Codable {
        case text, image, plate
    }
    
    // Implement Equatable
    static func == (lhs: Message, rhs: Message) -> Bool {
        // Compare by id if available
        if let lhsId = lhs.id, let rhsId = rhs.id {
            return lhsId == rhsId
        }
        
        // Fallback comparison if ids are not available
        return lhs.senderId == rhs.senderId &&
               lhs.receiverId == rhs.receiverId &&
               lhs.content == rhs.content &&
               lhs.isRead == rhs.isRead &&
               lhs.type == rhs.type &&
               lhs.timestamp == rhs.timestamp
    }
}
