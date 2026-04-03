import SwiftUI
import TDLibKit

struct CallsView: View {
    @State private var calls: [Message] = []
    private let client = TDLibClient.shared

    var body: some View {
        NavigationStack {
            Group {
                if calls.isEmpty {
                    ContentUnavailableView(
                        "Нет звонков",
                        systemImage: "phone.slash",
                        description: Text("История звонков пуста")
                    )
                } else {
                    List(calls, id: \.id) { call in
                        if case .messageCall(let c) = call.content {
                            HStack {
                                Image(systemName: callIcon(c))
                                    .foregroundStyle(callColor(c))
                                VStack(alignment: .leading) {
                                    Text(callTitle(c))
                                    Text(formatDuration(c.duration))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(Date(timeIntervalSince1970: TimeInterval(call.date))
                                    .formatted(.dateTime.day().month()))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Звонки")
        }
        .task {
            // Загружаем историю звонков через поиск
            if let result: Messages = try? await client.send(SearchCallMessages(
                fromMessageId: 0,
                limit: 50,
                onlyMissed: false
            )) {
                calls = result.messages ?? []
            }
        }
    }

    private func callIcon(_ call: MessageCall) -> String {
        switch call.discardReason {
        case .callDiscardReasonMissed: return "phone.arrow.down.left"
        case .callDiscardReasonDeclined: return "phone.down"
        default: return call.isVideo ? "video" : "phone"
        }
    }

    private func callColor(_ call: MessageCall) -> Color {
        switch call.discardReason {
        case .callDiscardReasonMissed: return .red
        case .callDiscardReasonDeclined: return .orange
        default: return .green
        }
    }

    private func callTitle(_ call: MessageCall) -> String {
        call.isVideo ? "Видеозвонок" : "Звонок"
    }

    private func formatDuration(_ seconds: Int) -> String {
        guard seconds > 0 else { return "Не состоялся" }
        let m = seconds / 60, s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
