/*
 * Порт AyuMessagesController.java
 * Хранит историю удалённых и отредактированных сообщений
 */

import Foundation
import TDLibKit
import SwiftData

@Observable
final class AyuMessagesController {
    static let shared = AyuMessagesController()
    private let config = AyuConfig.shared

    private init() {
        observeUpdates()
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
        case .updateDeleteMessages(let u):
            guard !u.fromCache, config.saveDeletedMessages else { return }
            await saveDeletedMessages(chatId: u.chatId, messageIds: u.messageIds)

        case .updateMessageEdited(let u):
            guard config.saveMessagesHistory else { return }
            await saveEditedMessage(chatId: u.chatId, messageId: u.messageId)

        default:
            break
        }
    }

    private func saveDeletedMessages(chatId: Int64, messageIds: [Int64]) async {
        // Сохраняем в AyuDatabase через SwiftData
        await AyuDatabase.shared.saveDeletedMessages(chatId: chatId, messageIds: messageIds)
    }

    private func saveEditedMessage(chatId: Int64, messageId: Int64) async {
        await AyuDatabase.shared.saveEditedMessage(chatId: chatId, messageId: messageId)
    }

    func getDeletedMessages(chatId: Int64) async -> [AyuDeletedMessage] {
        await AyuDatabase.shared.getDeletedMessages(chatId: chatId)
    }

    func getMessageHistory(chatId: Int64, messageId: Int64) async -> [AyuMessageRevision] {
        await AyuDatabase.shared.getMessageHistory(chatId: chatId, messageId: messageId)
    }
}
