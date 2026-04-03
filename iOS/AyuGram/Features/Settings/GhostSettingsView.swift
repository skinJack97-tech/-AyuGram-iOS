import SwiftUI

struct GhostSettingsView: View {
    @State private var config = AyuConfig.shared

    var body: some View {
        @Bindable var config = config

        Form {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Ghost Mode")
                            .font(.headline)
                        Text(config.isGhostModeActive ? "Активен" : "Неактивен")
                            .font(.caption)
                            .foregroundStyle(config.isGhostModeActive ? .purple : .secondary)
                    }
                    Spacer()
                    Button {
                        config.toggleGhostMode()
                    } label: {
                        Image(systemName: config.isGhostModeActive ? "eye.slash.fill" : "eye.fill")
                            .font(.title2)
                            .foregroundStyle(config.isGhostModeActive ? .purple : .tint)
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                Text("Ghost Mode скрывает ваш онлайн-статус, прочтение сообщений и прогресс загрузки")
            }

            Section("Детальные настройки") {
                Toggle("Отправлять прочтение", isOn: $config.sendReadPackets)
                Toggle("Отправлять онлайн-статус", isOn: $config.sendOnlinePackets)
                Toggle("Отправлять прогресс загрузки", isOn: $config.sendUploadProgress)
                Toggle("Уходить в оффлайн после онлайна", isOn: $config.sendOfflinePacketAfterOnline)
            }

            Section("Поведение") {
                Toggle("Отмечать прочитанным после отправки", isOn: $config.markReadAfterSend)
                Toggle("Использовать отложенные сообщения", isOn: $config.useScheduledMessages)
            }

            Section("Интерфейс") {
                Toggle("Кнопка Ghost в боковом меню", isOn: $config.showGhostToggleInDrawer)
                Toggle("Кнопка выхода в боковом меню", isOn: $config.showKillButtonInDrawer)
            }
        }
        .navigationTitle("Ghost Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}
