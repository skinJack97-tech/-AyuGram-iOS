/*
 * Порт AyuSyncController.java + AyuSyncWebSocketClient.java
 */

import Foundation

enum AyuSyncState {
    case disconnected
    case connecting
    case connected
    case error(String)
}

@Observable
final class AyuSyncController {
    static let shared = AyuSyncController()

    var state: AyuSyncState = .disconnected
    var lastSentDate: Date?
    var lastReceivedDate: Date?

    private var webSocketTask: URLSessionWebSocketTask?
    private let config = AyuConfig.shared

    private init() {}

    func connect() async {
        guard config.syncEnabled else { return }
        state = .connecting

        let scheme = config.useSecureConnection ? "wss" : "ws"
        guard let url = URL(string: "\(scheme)://\(config.syncServerURL)/ws") else {
            state = .error("Invalid server URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue(config.syncServerToken, forHTTPHeaderField: "Authorization")

        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        state = .connected

        await receiveLoop()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        state = .disconnected
    }

    func send(_ payload: Encodable) async {
        guard let data = try? JSONEncoder().encode(payload),
              let str = String(data: data, encoding: .utf8) else { return }
        try? await webSocketTask?.send(.string(str))
        lastSentDate = Date()
    }

    private func receiveLoop() async {
        while state == .connected {
            guard let task = webSocketTask else { break }
            do {
                let message = try await task.receive()
                lastReceivedDate = Date()
                handleMessage(message)
            } catch {
                state = .error(error.localizedDescription)
                break
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        // Обработка входящих sync-событий
        switch message {
        case .string(let str):
            NotificationCenter.default.post(name: .ayuSyncReceived, object: str)
        case .data(let data):
            NotificationCenter.default.post(name: .ayuSyncReceived, object: data)
        @unknown default:
            break
        }
    }
}

extension Notification.Name {
    static let ayuSyncReceived = Notification.Name("AyuSyncReceived")
}
