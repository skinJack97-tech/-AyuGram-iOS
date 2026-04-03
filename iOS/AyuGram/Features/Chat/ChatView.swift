import SwiftUI
import TDLibKit

struct ChatView: View {
    let chat: Chat
    @State private var vm: ChatViewModel
    @State private var showMessageHistory = false
    @State private var selectedMessage: Message?

    init(chat: Chat) {
        self.chat = chat
        _vm = State(initialValue: ChatViewModel(chat: chat))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(vm.messages, id: \.id) { message in
                            MessageBubbleView(message: message, chatId: chat.id)
                                .id(message.id)
                                .contextMenu {
                                    messageContextMenu(message)
                                }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
                .onChange(of: vm.messages.count) {
                    if let last = vm.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // Reply preview
            if let reply = vm.replyToMessage {
                ReplyPreviewView(message: reply) {
                    vm.replyToMessage = nil
                }
            }

            // Input bar
            ChatInputBar(vm: vm)
        }
        .navigationTitle(chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(chat.title).font(.headline)
                    Text("в сети").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .sheet(isPresented: $showMessageHistory) {
            if let msg = selectedMessage {
                MessageHistoryView(chatId: chat.id, messageId: msg.id)
            }
        }
    }

    @ViewBuilder
    private func messageContextMenu(_ message: Message) -> some View {
        Button("Ответить") {
            vm.replyToMessage = message
        }
        Button("История изменений") {
            selectedMessage = message
            showMessageHistory = true
        }
        Divider()
        Button("Удалить для меня", role: .destructive) {
            Task { await vm.deleteMessage(message, forAll: false) }
        }
        Button("Удалить для всех", role: .destructive) {
            Task { await vm.deleteMessage(message, forAll: true) }
        }
    }
}

// MARK: - Input bar

struct ChatInputBar: View {
    @Bindable var vm: ChatViewModel

    var body: some View {
        HStack(spacing: 8) {
            Button {
                // attach media
            } label: {
                Image(systemName: "paperclip")
                    .font(.title3)
            }

            TextField("Сообщение", text: $vm.inputText, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glassEffect(.regular.tint(.clear))

            Button {
                Task { await vm.sendMessage() }
            } label: {
                Image(systemName: vm.inputText.isEmpty ? "mic.fill" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(vm.inputText.isEmpty ? .secondary : .tint)
            }
            .disabled(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }
}

// MARK: - Reply preview

struct ReplyPreviewView: View {
    let message: Message
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Rectangle()
                .fill(.tint)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Ответ")
                    .font(.caption.bold())
                    .foregroundStyle(.tint)
                Text(messagePreview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var messagePreview: String {
        switch message.content {
        case .messageText(let t): return t.text.text
        case .messagePhoto: return "Фото"
        case .messageVideo: return "Видео"
        default: return "Сообщение"
        }
    }
}
