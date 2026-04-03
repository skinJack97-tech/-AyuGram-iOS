/*
 * Порт AyuMessageHistory.java — просмотр истории изменений сообщения
 */

import SwiftUI

struct MessageHistoryView: View {
    let chatId: Int64
    let messageId: Int64

    @State private var revisions: [AyuMessageRevision] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if revisions.isEmpty {
                    ContentUnavailableView(
                        "Нет истории",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("История изменений этого сообщения не сохранена")
                    )
                } else {
                    List(revisions.indices, id: \.self) { idx in
                        let rev = revisions[idx]
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Версия \(idx + 1)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.tint)
                                Spacer()
                                Text(rev.editDate.formatted(.dateTime.day().month().hour().minute()))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(rev.text.isEmpty ? "(пусто)" : rev.text)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("История сообщения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .task {
            revisions = await AyuDatabase.shared.getMessageHistory(chatId: chatId, messageId: messageId)
        }
    }
}
