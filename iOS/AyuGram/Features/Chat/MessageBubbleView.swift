import SwiftUI
import TDLibKit

struct MessageBubbleView: View {
    let message: Message
    let chatId: Int64
    private let config = AyuConfig.shared

    private var isOutgoing: Bool { message.isOutgoing }

    var body: some View {
        HStack {
            if isOutgoing { Spacer(minLength: 60) }

            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 4) {
                // Контент сообщения
                messageContent
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(bubbleBackground)
                    .clipShape(BubbleShape(isOutgoing: isOutgoing))

                // Метаданные
                HStack(spacing: 4) {
                    Text(formatTime(message.date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if isOutgoing {
                        messageStatusIcon
                    }
                }
                .padding(.horizontal, 4)
            }

            if !isOutgoing { Spacer(minLength: 60) }
        }
    }

    @ViewBuilder
    private var messageContent: some View {
        switch message.content {
        case .messageText(let t):
            VStack(alignment: .leading, spacing: 4) {
                Text(t.text.text)
                    .foregroundStyle(isOutgoing ? .white : .primary)
                if message.editDate > 0 {
                    Text(config.editedMarkText)
                        .font(.caption2)
                        .foregroundStyle(isOutgoing ? .white.opacity(0.7) : .secondary)
                }
            }
        case .messagePhoto:
            Label("Фото", systemImage: "photo")
                .foregroundStyle(isOutgoing ? .white : .primary)
        case .messageVideo:
            Label("Видео", systemImage: "video")
                .foregroundStyle(isOutgoing ? .white : .primary)
        case .messageVoiceNote:
            Label("Голосовое", systemImage: "waveform")
                .foregroundStyle(isOutgoing ? .white : .primary)
        case .messageSticker(let s):
            Text(s.sticker.emoji)
                .font(.system(size: 48))
        case .messageDocument(let d):
            Label(d.document.fileName, systemImage: "doc")
                .foregroundStyle(isOutgoing ? .white : .primary)
        default:
            Text("Сообщение")
                .foregroundStyle(isOutgoing ? .white : .primary)
        }
    }

    private var bubbleBackground: some ShapeStyle {
        if isOutgoing {
            return AnyShapeStyle(.tint)
        } else {
            return AnyShapeStyle(.regularMaterial)
        }
    }

    @ViewBuilder
    private var messageStatusIcon: some View {
        switch message.sendingState {
        case .messageSendingStatePending:
            Image(systemName: "clock")
                .font(.caption2)
                .foregroundStyle(.secondary)
        case .messageSendingStateFailed:
            Image(systemName: "exclamationmark.circle")
                .font(.caption2)
                .foregroundStyle(.red)
        default:
            Image(systemName: "checkmark")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func formatTime(_ timestamp: Int) -> String {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
            .formatted(.dateTime.hour().minute())
    }
}

// MARK: - Bubble shape

struct BubbleShape: Shape {
    let isOutgoing: Bool
    let radius: CGFloat = 18

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tailRadius: CGFloat = 4

        if isOutgoing {
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tailRadius))
            path.addArc(center: CGPoint(x: rect.maxX - tailRadius, y: rect.maxY - tailRadius), radius: tailRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        } else {
            path.move(to: CGPoint(x: rect.minX + tailRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tailRadius))
            path.addArc(center: CGPoint(x: rect.minX + tailRadius, y: rect.minY + tailRadius), radius: tailRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        }
        path.closeSubpath()
        return path
    }
}
