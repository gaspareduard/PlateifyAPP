import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore

@MainActor
class ChatListViewModel: ObservableObject {
    // MARK: - View States
    enum ChatListViewState {
        case loading
        case loaded(chats: [Chat])
        case error(String)
    }
    
    enum ChatViewState {
        case loading
        case loaded(messages: [Message])
        case error(String)
    }
    
    // MARK: - Published Properties
    @Published var chatListState: ChatListViewState = .loading
    @Published var chatViewState: ChatViewState = .loading
    @Published var currentChat: Chat?
    @Published var messageText: String = ""
    @Published var hasChats: Bool = false // True if there is at least one chat
    @Published var chatParticipants: [String: UserSummary] = [:] // Stores chat participant summaries
    
    // MARK: - Dependencies
    private let chatService: ChatService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(chatService: ChatService) {
        self.chatService = chatService
        setupSubscriptions()
        print("DEBUG: ChatListViewModel initialized with injected ChatService")
    }
    
    private func setupSubscriptions() {
        // Subscribe to changes in chat list
        chatService.$chats
            .receive(on: RunLoop.main)
            .sink { [weak self] chats in
                guard let self = self else { return }
                print("DEBUG: Chat list updated - \(chats.count) chats")
                self.chatListState = .loaded(chats: chats)
                self.hasChats = !chats.isEmpty
                self.fetchChatParticipants(for: chats)
            }
            .store(in: &cancellables)
        
        // Subscribe to changes in message list
        chatService.$messages
            .receive(on: RunLoop.main)
            .sink { [weak self] messages in
                guard let self = self else { return }
                print("DEBUG: Message list updated - \(messages.count) messages")
                self.chatViewState = .loaded(messages: messages)
            }
            .store(in: &cancellables)
        
        // Subscribe to errors
        chatService.$chatsError
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let error = error {
                    print("DEBUG: Chat list error: \(error.localizedDescription)")
                    self?.chatListState = .error(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
            
        chatService.$messagesError
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let error = error {
                    print("DEBUG: Chat view error: \(error.localizedDescription)")
                    self?.chatViewState = .error(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
            
        // Subscribe to loading states
        chatService.$isChatsLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.chatListState = .loading
                }
            }
            .store(in: &cancellables)
            
        chatService.$isMessagesLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.chatViewState = .loading
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Profile Management
    private func fetchChatParticipants(for chats: [Chat]) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("DEBUG: No current user ID available for fetching chat participants")
            return
        }
        
        // Get unique participant IDs (excluding current user)
        let participantIds = Set(chats.compactMap { chat in
            chat.participants.first { $0 != currentUserId }
        })
        
        // Filter out already fetched participants
        let missingParticipantIds = participantIds.subtracting(chatParticipants.keys)
        
        print("DEBUG: Fetching summaries for \(missingParticipantIds.count) chat participants")
        
        // Fetch each missing participant's summary
        for participantId in missingParticipantIds {
            Task {
                await fetchUserSummary(userId: participantId)
            }
        }
    }
    
    private func fetchUserSummary(userId: String) async {
        do {
            let db = Firestore.firestore()
            let document = try await db.collection("users").document(userId).getDocument()
            
            guard let data = document.data() else {
                print("DEBUG: No data found for user \(userId)")
                return
            }
            
            // Extract required fields for UserSummary
            let firstName = data["firstName"] as? String ?? ""
            let lastName = data["lastName"] as? String ?? ""
            let profileImageURL = data["profileImageURL"] as? String
            let plateNumbers = data["plateNumbers"] as? [String] ?? []
            let bio = data["bio"] as? String
            let sex = data["sex"] as? String
            
            // Create UserSummary
            let userSummary = UserSummary(
                id: userId,
                firstName: firstName,
                lastName: lastName,
                profileImageURL: profileImageURL,
                plateNumbers: plateNumbers,
                age: nil,
                bio: bio,
                sex: sex
            )
            
            // Update on main thread
            await MainActor.run {
                self.chatParticipants[userId] = userSummary
                print("DEBUG: Fetched user summary for \(userId): \(userSummary.displayName)")
            }
        } catch {
            print("DEBUG: Failed to fetch user summary for \(userId): \(error.localizedDescription)")
        }
    }
    
    // Helper method to get participant summary for a chat
    func getParticipantSummary(for chat: Chat) -> UserSummary? {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let participantId = chat.participants.first(where: { $0 != currentUserId }) else {
            return nil
        }
        return chatParticipants[participantId]
    }
    
    // MARK: - Lifecycle
    func startListening() {
        print("DEBUG: Starting chat service listeners")
        chatService.listenToChats()
    }
    
    func stopListening() {
        print("DEBUG: Stopping chat service listeners")
        chatService.stopListening()
    }
    
    // MARK: - Chat Operations
    func createChat(with userId: String) async {
        self.chatListState = .loading
        
        do {
            let chat = try await chatService.createChat(with: userId)
            print("DEBUG: Created chat with user: \(userId)")
            self.currentChat = chat
        } catch {
            print("DEBUG: Failed to create chat: \(error.localizedDescription)")
            self.chatListState = .error(error.localizedDescription)
        }
    }
    
    func sendMessage(_ content: String, in chat: Chat) async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.chatViewState = .error("User not logged in")
            return
        }
        
        let receiverId = chat.otherParticipantId(currentUserId: currentUserId) ?? ""
        
        let message = Message(
            id: UUID().uuidString,
            senderId: currentUserId,
            receiverId: receiverId,
            content: content,
            timestamp: Date(),
            isRead: false,
            type: .text
        )
        
        do {
            try await chatService.sendMessage(message, in: chat)
            print("DEBUG: Sent message in chat: \(chat.id ?? "unknown")")
        } catch {
            print("DEBUG: Failed to send message: \(error.localizedDescription)")
            self.chatViewState = .error(error.localizedDescription)
        }
    }
    
    func listenToMessages(for chat: Chat) {
        self.currentChat = chat
        self.chatViewState = .loading
        
        guard let chatId = chat.id else {
            self.chatViewState = .error("Invalid chat ID")
            return
        }
        
        print("DEBUG: Listening to messages for chat: \(chatId)")
        chatService.listenToMessages(in: chatId)
    }
    
    func markChatAsRead(_ chat: Chat) async {
        do {
            try await chatService.markChatAsRead(chat)
            print("DEBUG: Marked chat as read: \(chat.id ?? "unknown")")
        } catch {
            print("DEBUG: Failed to mark chat as read: \(error.localizedDescription)")
            self.chatListState = .error(error.localizedDescription)
        }
    }
    
    func deleteChat(_ chat: Chat) async {
        self.chatListState = .loading
        
        do {
            try await chatService.deleteChat(chat)
            print("DEBUG: Deleted chat: \(chat.id ?? "unknown")")
            
            if currentChat?.id == chat.id {
                currentChat = nil
            }
        } catch {
            print("DEBUG: Failed to delete chat: \(error.localizedDescription)")
            self.chatListState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods
    var chats: [Chat] {
        if case .loaded(let chats) = chatListState {
            return chats
        }
        return []
    }
    
    var messages: [Message] {
        if case .loaded(let messages) = chatViewState {
            return messages
        }
        return []
    }
    
    var isChatListLoading: Bool {
        if case .loading = chatListState {
            return true
        }
        return false
    }
    
    var isChatViewLoading: Bool {
        if case .loading = chatViewState {
            return true
        }
        return false
    }
    
    var chatListErrorMessage: String? {
        if case .error(let message) = chatListState {
            return message
        }
        return nil
    }
    
    var chatViewErrorMessage: String? {
        if case .error(let message) = chatViewState {
            return message
        }
        return nil
    }
} 
