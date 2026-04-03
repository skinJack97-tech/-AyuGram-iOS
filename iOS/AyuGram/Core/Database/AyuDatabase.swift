/*
 * Порт AyuDatabase.java — SwiftData вместо Room
 */

import Foundation
import SwiftData

// MARK: - Models

@Model
final class AyuDeletedMessage {
    var chatId: Int64
    var messageId: Int64
    var text: String
    var senderId: Int64
    var date: Date
    var mediaType: Int

    init(chatId: Int64, messageId: Int64, text: String, senderId: Int64, date: Date, mediaType: Int = 0) {
        self.chatId = chatId
        self.messageId = messageId
        self.text = text
        self.senderId = senderId
        self.date = date
        self.mediaType = mediaType
    }
}

@Model
final class AyuMessageRevision {
    var chatId: Int64
    var messageId: Int64
    var text: String
    var editDate: Date
    var revisionIndex: Int

    init(chatId: Int64, messageId: Int64, text: String, editDate: Date, revisionIndex: Int) {
        self.chatId = chatId
        self.messageId = messageId
        self.text = text
        self.editDate = editDate
        self.revisionIndex = revisionIndex
    }
}

// MARK: - Database actor

@ModelActor
actor AyuDatabase {
    static let shared: AyuDatabase = {
        let schema = Schema([AyuDeletedMessage.self, AyuMessageRevision.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: schema, configurations: config)
        return AyuDatabase(modelContainer: container)
    }()

    func saveDeletedMessages(chatId: Int64, messageIds: [Int64]) {
        for msgId in messageIds {
            let msg = AyuDeletedMessage(
                chatId: chatId,
                messageId: msgId,
                text: "",
                senderId: 0,
                date: Date()
            )
            modelContext.insert(msg)
        }
        try? modelContext.save()
    }

    func saveEditedMessage(chatId: Int64, messageId: Int64) {
        let existing = (try? modelContext.fetch(
            FetchDescriptor<AyuMessageRevision>(
                predicate: #Predicate { $0.chatId == chatId && $0.messageId == messageId }
            )
        ))?.count ?? 0

        let revision = AyuMessageRevision(
            chatId: chatId,
            messageId: messageId,
            text: "",
            editDate: Date(),
            revisionIndex: existing
        )
        modelContext.insert(revision)
        try? modelContext.save()
    }

    func getDeletedMessages(chatId: Int64) -> [AyuDeletedMessage] {
        (try? modelContext.fetch(
            FetchDescriptor<AyuDeletedMessage>(
                predicate: #Predicate { $0.chatId == chatId },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
        )) ?? []
    }

    func getMessageHistory(chatId: Int64, messageId: Int64) -> [AyuMessageRevision] {
        (try? modelContext.fetch(
            FetchDescriptor<AyuMessageRevision>(
                predicate: #Predicate { $0.chatId == chatId && $0.messageId == messageId },
                sortBy: [SortDescriptor(\.revisionIndex)]
            )
        )) ?? []
    }
}
