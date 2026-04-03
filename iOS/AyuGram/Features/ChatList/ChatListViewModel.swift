import Foundation
import TDLibKit

@Observable
final class ChatListViewModel {
    var chats: [Chat] = []
    var isLoading = false
    var searchQuery = ""

    private let client = TDLibClient.shared

    var filteredChats: [Chat] {
        guard !searchQuery.isEmpty else { return chats }
        return chats.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    init() {
        observeUpdates()
        Task { await loadChats() }
    }

    func loadChats() async {
        isLoading = true
        do {
            let result: Chats = try await client.send(GetChats(
                chatList: .chatListMain,
                limit: 100
            ))
            var loaded: [Chat] = []
            for id in result.chatIds {
                if let chat: Chat = try? await client.send(GetChat(chatId: id)) {
                    loaded.append(chat)
                }
            }
            chats = loaded
        } catch {
            print("ChatList error: \(error)")
        }
        isLoading = false
    }

    private func observeUpdates() {
        NotificationCenter.default.addObserver(
            forName: .tdUpdate,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let update = notification.object as? Update else { return }
            Task { await self?.handleUpdate(update) }
        }
    }

    private func handleUpdate(_ update: Update) async {
        switch update {
        case .updateNewMessage, .updateChatLastMessage, .updateChatOrder:
            await loadChats()
        case .updateChatTitle(let u):
            if let idx = chats.firstIndex(where: { $0.id == u.chatId }) {
                chats[idx] = Chat(
                    accentColorId: chats[idx].accentColorId,
                    actionBar: chats[idx].actionBar,
                    availableReactions: chats[idx].availableReactions,
                    backgroundCustomEmojiId: chats[idx].backgroundCustomEmojiId,
                    blockList: chats[idx].blockList,
                    businessBotManageUrl: chats[idx].businessBotManageUrl,
                    canBeDeletedForAllUsers: chats[idx].canBeDeletedForAllUsers,
                    canBeDeletedOnlyForSelf: chats[idx].canBeDeletedOnlyForSelf,
                    canBeReported: chats[idx].canBeReported,
                    clientData: chats[idx].clientData,
                    defaultDisableNotification: chats[idx].defaultDisableNotification,
                    draftMessage: chats[idx].draftMessage,
                    emojiStatus: chats[idx].emojiStatus,
                    hasProtectedContent: chats[idx].hasProtectedContent,
                    hasScheduledMessages: chats[idx].hasScheduledMessages,
                    id: u.chatId,
                    isMarkedAsUnread: chats[idx].isMarkedAsUnread,
                    isTranslatable: chats[idx].isTranslatable,
                    lastMessage: chats[idx].lastMessage,
                    lastReadInboxMessageId: chats[idx].lastReadInboxMessageId,
                    lastReadOutboxMessageId: chats[idx].lastReadOutboxMessageId,
                    messageAutoDeleteTime: chats[idx].messageAutoDeleteTime,
                    messageSenderId: chats[idx].messageSenderId,
                    notificationSettings: chats[idx].notificationSettings,
                    pendingJoinRequests: chats[idx].pendingJoinRequests,
                    permissions: chats[idx].permissions,
                    photo: chats[idx].photo,
                    positions: chats[idx].positions,
                    profileAccentColorId: chats[idx].profileAccentColorId,
                    profileBackgroundCustomEmojiId: chats[idx].profileBackgroundCustomEmojiId,
                    replyMarkupMessageId: chats[idx].replyMarkupMessageId,
                    themeName: chats[idx].themeName,
                    title: u.title,
                    type: chats[idx].type,
                    unreadCount: chats[idx].unreadCount,
                    unreadMentionCount: chats[idx].unreadMentionCount,
                    unreadReactionCount: chats[idx].unreadReactionCount,
                    videoChat: chats[idx].videoChat,
                    viewAsTopics: chats[idx].viewAsTopics
                )
            }
        default:
            break
        }
    }
}
