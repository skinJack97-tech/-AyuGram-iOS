import SwiftUI
import TDLibKit

struct ChatListView: View {
    @State private var vm = ChatListViewModel()
    @State private var selectedChat: Chat?
    @State private var showSettings = false
    @State private var showGhostToggle = false
    private let config = AyuConfig.shared

    var body: some View {
        NavigationSplitView {
            List(vm.filteredChats, id: \.id, selection: $selectedChat) { chat in
                ChatRowView(chat: chat)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .searchable(text: $vm.searchQuery, prompt: "Поиск")
            .navigationTitle("AyuGram")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        if config.showGhostToggleInDrawer {
                            GhostToggleButton()
                        }
                        Button {
                            // новый чат
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .refreshable {
                await vm.loadChats()
            }
            .overlay {
                if vm.isLoading && vm.chats.isEmpty {
                    ProgressView()
                }
            }
        } detail: {
            if let chat = selectedChat {
                ChatView(chat: chat)
            } else {
                ContentUnavailableView("Выберите чат", systemImage: "bubble.left.and.bubble.right")
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - Ghost toggle button

struct GhostToggleButton: View {
    private let config = AyuConfig.shared

    var body: some View {
        Button {
            config.toggleGhostMode()
        } label: {
            Image(systemName: config.isGhostModeActive ? "eye.slash.fill" : "eye.fill")
                .foregroundStyle(config.isGhostModeActive ? .purple : .primary)
        }
    }
}
