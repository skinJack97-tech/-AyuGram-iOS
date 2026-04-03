import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authVM

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    NavigationLink {
                        ProfileSettingsView()
                    } label: {
                        Label("Профиль", systemImage: "person.circle")
                    }
                }

                // AyuGram sections
                Section("Ghost Mode") {
                    NavigationLink {
                        GhostSettingsView()
                    } label: {
                        Label("Настройки Ghost", systemImage: "eye.slash")
                    }
                }

                Section("Сохранение сообщений") {
                    NavigationLink {
                        MessageSavingSettingsView()
                    } label: {
                        Label("Сохранение", systemImage: "tray.and.arrow.down")
                    }
                }

                Section("Фильтры") {
                    NavigationLink {
                        RegexFiltersView()
                    } label: {
                        Label("Regex-фильтры", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }

                Section("AyuSync") {
                    NavigationLink {
                        AyuSyncSettingsView()
                    } label: {
                        Label("Синхронизация", systemImage: "arrow.triangle.2.circlepath")
                    }
                }

                Section("Внешний вид") {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Label("Внешний вид", systemImage: "paintbrush")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task { await authVM.logout() }
                    } label: {
                        Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}
