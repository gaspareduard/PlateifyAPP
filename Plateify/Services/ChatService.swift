import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatService: ObservableObject {
    // MARK: - Dependencies
    private let db: Firestore
    
    // MARK: - Published State
    @Published private(set) var chats: [Chat] = []
    @Published private(set) var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isChatsLoading = false
    @Published var chatsError: Error?
    @Published var isMessagesLoading = false
    @Published var messagesError: Error?
    
    // MARK: - Private State
    private var chatListener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    // MARK: - Initializer
    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    
    // MARK: - Chat Operations
    
    func createChat(with userId: String) async throws -> Chat {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ChatService", code: -1, 
                          userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        isLoading = true
        isChatsLoading = true
        defer {
            isLoading = false
            isChatsLoading = false
        }
        
        // Check if chat already exists between these users
        let existingChat = try await checkExistingChat(between: currentUserId, and: userId)
        if let existingChat = existingChat {
            print("DEBUG: Chat already exists between users")
            return existingChat
        }
        
        let chatId = UUID().uuidString
        let chat = Chat(
            id: chatId,
            participants: [currentUserId, userId],
            lastMessage: nil,
            lastMessageTimestamp: nil,
            lastMessageSenderId: nil,
            unreadCount: [currentUserId: 0, userId: 0],
            createdAt: nil,
            updatedAt: nil
        )
        
        do {
            try await db.collection("chats")
                .document(chatId)
                .setData(from: chat)
            print("DEBUG: Created new chat with ID: \(chatId)")
            return chat
        } catch {
            print("DEBUG: Failed to create chat: \(error.localizedDescription)")
            self.chatsError = error
            throw error
        }
    }
    
    func sendMessage(_ message: Message, in chat: Chat) async throws {
        guard let chatId = chat.id else {
            throw NSError(domain: "ChatService", code: -1, 
                          userInfo: [NSLocalizedDescriptionKey: "Invalid chat ID"])
        }
        
        // Ensure message has an ID
        var messageToSend = message
        if messageToSend.id == nil {
            messageToSend.id = UUID().uuidString
        }
        messageToSend.timestamp = nil
        
        isLoading = true
        isMessagesLoading = true
        defer {
            isLoading = false
            isMessagesLoading = false
        }
        
        // Get receiver ID to update unread count
        let receiverId = chat.otherParticipantId(currentUserId: messageToSend.senderId) ?? ""
        
        do {
            // 1. Save message (Firestore will set timestamp)
            try await db.collection("chats").document(chatId)
                .collection("messages").document(messageToSend.id!)
                .setData(from: messageToSend)
            
            // 2. Update chat's last message and unread counts using server timestamps
            var unreadCount = chat.unreadCount
            unreadCount[receiverId] = (unreadCount[receiverId] ?? 0) + 1
            try await db.collection("chats").document(chatId)
                .updateData([
                    "lastMessage": messageToSend.content,
                    "lastMessageTimestamp": FieldValue.serverTimestamp(),
                    "lastMessageSenderId": messageToSend.senderId,
                    "updatedAt": FieldValue.serverTimestamp(),
                    "unreadCount": unreadCount
                ])
            
            print("DEBUG: Sent message in chat \(chatId)")
        } catch {
            print("DEBUG: Failed to send message: \(error.localizedDescription)")
            self.messagesError = error
            throw error
        }
    }
    
    // MARK: - Listeners
    
    func listenToChats() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { 
            print("DEBUG: Cannot listen to chats - user not authenticated")
            return 
        }
        
        isChatsLoading = true
        
        chatListener = db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isChatsLoading = false
                
                if let error = error {
                    self.chatsError = error
                    print("DEBUG: Error listening to chats: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("DEBUG: No chat documents found")
                    return
                }
                
                self.chats = documents.compactMap { document in
                    do {
                        return try document.data(as: Chat.self)
                    } catch {
                        print("DEBUG: Error decoding chat: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
    }
    
    func listenToMessages(in chatId: String) {
        guard Auth.auth().currentUser != nil else {
            print("DEBUG: Cannot listen to messages - user not authenticated")
            return
        }
        
        // Remove existing listener if any
        messageListeners[chatId]?.remove()
        
        isMessagesLoading = true
        
        messageListeners[chatId] = db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isMessagesLoading = false
                
                if let error = error {
                    self.messagesError = error
                    print("DEBUG: Error listening to messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("DEBUG: No message documents found")
                    return
                }
                
                self.messages = documents.compactMap { document in
                    do {
                        return try document.data(as: Message.self)
                    } catch {
                        print("DEBUG: Error decoding message: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
    }
    
    func stopListening() {
        chatListener?.remove()
        chatListener = nil
        
        messageListeners.values.forEach { $0.remove() }
        messageListeners.removeAll()
        
        print("DEBUG: Stopped all chat listeners")
    }
    
    func markChatAsRead(_ chat: Chat) async throws {
        guard let chatId = chat.id else {
            throw NSError(domain: "ChatService", code: -1, 
                          userInfo: [NSLocalizedDescriptionKey: "Invalid chat ID"])
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ChatService", code: -1, 
                          userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        isLoading = true
        isMessagesLoading = true
        defer {
            isLoading = false
            isMessagesLoading = false
        }
        
        var updatedChat = chat
        var unreadCount = chat.unreadCount
        unreadCount[currentUserId] = 0
        updatedChat.unreadCount = unreadCount
        
        do {
            try await db.collection("chats").document(chatId)
                .updateData(["unreadCount": unreadCount])
            
            print("DEBUG: Marked chat \(chatId) as read for user \(currentUserId)")
        } catch {
            print("DEBUG: Failed to mark chat as read: \(error.localizedDescription)")
            self.messagesError = error
            throw error
        }
    }
    
    func deleteChat(_ chat: Chat) async throws {
        guard let chatId = chat.id else {
            throw NSError(domain: "ChatService", code: -1, 
                          userInfo: [NSLocalizedDescriptionKey: "Invalid chat ID"])
        }
        
        isLoading = true
        isChatsLoading = true
        defer {
            isLoading = false
            isChatsLoading = false
        }
        
        do {
            // 1. Delete all messages in the chat
            let messages = try await db.collection("chats").document(chatId)
                .collection("messages").getDocuments()
            
            for message in messages.documents {
                try await message.reference.delete()
            }
            
            // 2. Delete the chat document
            try await db.collection("chats").document(chatId).delete()
            
            print("DEBUG: Deleted chat with ID: \(chatId)")
        } catch {
            print("DEBUG: Failed to delete chat: \(error.localizedDescription)")
            self.chatsError = error
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkExistingChat(between userId1: String, and userId2: String) async throws -> Chat? {
        // Query for chats containing both users
        let snapshot = try await db.collection("chats")
            .whereField("participants", arrayContains: userId1)
            .getDocuments()
        
        // Find a chat where the other participant is userId2
        for document in snapshot.documents {
            let chat = try document.data(as: Chat.self)
            if chat.participants.contains(userId2) {
                return chat
            }
        }
        
        return nil
    }
} 
