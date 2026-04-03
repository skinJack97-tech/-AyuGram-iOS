import Foundation
import TDLibKit

@Observable
final class TDLibClient {
    static let shared = TDLibClient()

    private let api: TdApi
    private var updateHandler: Task<Void, Never>?

    private init() {
        api = TdApi(client: TdClientImpl(completionQueue: .main))
        startUpdateLoop()
    }

    var tdApi: TdApi { api }

    private func startUpdateLoop() {
        updateHandler = Task {
            for await update in api.client.updates {
                await handleUpdate(update)
            }
        }
    }

    private func handleUpdate(_ update: Update) async {
        NotificationCenter.default.post(
            name: .tdUpdate,
            object: update
        )
    }

    func send<T: Codable>(_ query: TdQuery) async throws -> T {
        try await api.execute(query: query)
    }
}

extension Notification.Name {
    static let tdUpdate = Notification.Name("TDLibUpdate")
}
