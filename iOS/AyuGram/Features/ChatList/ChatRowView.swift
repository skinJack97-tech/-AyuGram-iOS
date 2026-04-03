import SwiftUI
import TDLibKit

struct ChatRowView: View {
    let chat: Chat
    private let config = AyuConfig.shared

    var body: some View {
        HStack(spacing: 12) {
            ChatAvatarView(chat: chat)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(chat.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    if let msg = chat.lastMessage {
                        Text(formatDate(msg.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text(lastMessagePreview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.tint, in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var lastMessagePreview: String {
        guard let msg = chat.lastMessage else { return "" }
        switch msg.content {
        case .messageText(let t):
            return t.text.text
        case .messagePhoto:
            return "📷 Фото"
        case .messageVideo:
            return "🎥 Видео"
        case .messageVoiceNote:
            return "🎤 Голосовое"
        case .messageDocument:
            return "📎 Файл"
        case .messageSticker(let s):
            return "\(s.sticker.emoji) Стикер"
        case .messageAnimation:
            return "GIF"
        default:
            return "Сообщение"
        }
    }

    private func formatDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.formatted(.dateTime.hour().minute())
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            return date.formatted(.dateTime.day().month())
        }
    }
}

struct ChatAvatarView: View {
    let chat: Chat

    var body: some View {
        ZStack {
            Circle()
                .fill(avatarColor)
                .frame(width: 52, height: 52)
            Text(initials)
                .font(.title3.bold())
                .foregroundStyle(.white)
        }
    }

    private var initials: String {
        let words = chat.title.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        }
        return String(chat.title.prefix(2)).uppercased()
    }

    private var avatarColor: Color {
        let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .teal, .indigo]
        let index = abs(chat.id.hashValue) % colors.count
        return colors[index]
    }
}
