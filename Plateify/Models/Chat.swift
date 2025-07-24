import Foundation
import FirebaseFirestore

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String] // exactly two UIDs
    var lastMessage: String?
    @ServerTimestamp var lastMessageTimestamp: Date?
    var lastMessageSenderId: String?
    var unreadCount: [String: Int]  // e.g. ["userA":0,"userB":3]
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    
    func otherParticipantId(currentUserId: String) -> String? {
        participants.first { $0 != currentUserId }
    }
}
