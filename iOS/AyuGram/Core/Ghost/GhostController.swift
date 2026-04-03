/*
 * Ghost mode — порт AyuGhostUtils.java
 * Управляет отправкой read receipts, online-статуса, прогресса загрузки
 */

import Foundation
import TDLibKit

final class GhostController {
    static let shared = GhostController()
    private let client = TDLibClient.shared
    private let config = AyuConfig.shared

    private init() {}

    // Вызывается перед отправкой read receipt
    func shouldSendReadReceipt() -> Bool {
        config.sendReadPackets
    }

    // Вызывается перед обновлением online-статуса
    func shouldSendOnlineStatus() -> Bool {
        config.sendOnlinePackets
    }

    // Устанавливает online/offline статус через TDLib
    func setOnlineStatus(_ online: Bool) async {
        guard config.sendOnlinePackets || (!online && config.sendOfflinePacketAfterOnline) else { return }
        let _: Ok? = try? await client.send(SetOption(
            name: "online",
            value: .optionValueBoolean(.init(value: online))
        ))
    }

    // Отмечает чат прочитанным (с учётом ghost mode)
    func markChatAsRead(chatId: Int64, lastMessageId: Int64) async {
        guard config.sendReadPackets else { return }
        let _: Ok? = try? await client.send(ViewMessages(
            chatId: chatId,
            forceRead: false,
            messageIds: [lastMessageId],
            source: nil
        ))
    }
}
