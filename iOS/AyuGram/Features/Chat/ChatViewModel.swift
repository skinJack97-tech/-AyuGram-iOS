import Foundation
import TDLibKit

@Observable
final class ChatViewModel {
    let chat: Chat
    var messages: [Message] = []
    var inputText = ""
    var isLoading = false
    var replyToMessage: Message?

    private let client = TDLibClient.shared
    private let ghost = GhostController.shared
    private let filter = AyuFilter.shared

    init(chat: Chat) {
        self.chat = chat
        observeUpdates()
        Task { await loadMessages() }
    }

    func loadMessages() async {
        isLoading = true
        do {
            let result: Messages = try await client.send(GetChatHistory(
                chatId: chat.id,
                fromMessageId: 0,
                limit: 50,
                offset: 0,
                onlyLocal: false
            ))
            messages = (result.messages ?? []).reversed()
            // Отмечаем прочитанным с учётом ghost mode
            if let last = messages.last {
                await ghost.markChatAsRead(chatId: chat.id, lastMessageId: last.id)
            }
        } catch {
            print("Messages error: \(error)")
        }
        isLoading = false
    }

    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let text = inputText
        inputText = ""

        do {
            var replyTo: InputMessageReplyTo? = nil
            if let reply = replyToMessage {
                replyTo = .inputMessageReplyToMessage(.init(
                    chatId: chat.id,
                    messageId: reply.id,
                    quote: nil
                ))
            }

            let _: Message = try await client.send(SendMessage(
                chatId: chat.id,
                inputMessageContent: .inputMessageText(.init(
                    clearDraft: true,
                    disableWebPagePreview: false,
                    text: FormattedText(entities: [], text: text)
                )),
                messageThreadId: 0,
                options: MessageSendOptions(
                    disableNotification: false,
                    fromBackground: false,
                    onlyPreview: false,
                    protectContent: false,
                    schedulingState: AyuConfig.shared.useScheduledMessages ? .messageSchedulingStateSendWhenOnline : nil,
                    sendingId: 0,
                    updateOrderOfInstalledStickerSets: false
                ),
                replyMarkup: nil,
                replyTo: replyTo
            ))
            replyToMessage = nil
        } catch {
            print("Send error: \(error)")
            inputText = text
        }
    }

    func deleteMessage(_ message: Message, forAll: Bool) async {
        let _: Ok? = try? await client.send(DeleteMessages(
            chatId: chat.id,
            messageIds: [message.id],
            revoke: forAll
        ))
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
        case .updateNewMessage(let u) where u.message.chatId == chat.id:
            let msg = u.message
            // Применяем regex-фильтр
            if case .messageText(let t) = msg.content, filter.shouldFilter(t.text.text) { return }
            messages.append(msg)
            await ghost.markChatAsRead(chatId: chat.id, lastMessageId: msg.id)

        case .updateMessageEdited(let u) where u.chatId == chat.id:
            if let idx = messages.firstIndex(where: { $0.id == u.messageId }) {
                // Перезагружаем конкретное сообщение
                if let updated: Message = try? await client.send(GetMessage(chatId: chat.id, messageId: u.messageId)) {
                    messages[idx] = updated
                }
            }

        case .updateDeleteMessages(let u) where u.chatId == chat.id && !u.fromCache:
            messages.removeAll { u.messageIds.contains($0.id) }

        default:
            break
        }
    }
}
