import SwiftUI

struct AyuSyncSettingsView: View {
    @State private var config = AyuConfig.shared
    @State private var syncController = AyuSyncController.shared

    var body: some View {
        @Bindable var config = config

        Form {
            Section {
                Toggle("Включить AyuSync", isOn: $config.syncEnabled)
            } footer: {
                Text("AyuSync синхронизирует историю удалённых и изменённых сообщений между устройствами")
            }

            if config.syncEnabled {
                Section("Сервер") {
                    HStack {
                        Text("URL")
                        Spacer()
                        TextField(AyuConstants.defaultSyncServer, text: $config.syncServerURL)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    HStack {
                        Text("Токен")
                        Spacer()
                        SecureField("Токен доступа", text: $config.syncServerToken)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Защищённое соединение (WSS)", isOn: $config.useSecureConnection)
                }

                Section("Статус") {
                    HStack {
                        Text("Состояние")
                        Spacer()
                        syncStateView
                    }
                    if let lastSent = syncController.lastSentDate {
                        HStack {
                            Text("Последняя отправка")
                            Spacer()
                            Text(lastSent.formatted(.relative(presentation: .named)))
                                .foregroundStyle(.secondary)
                        }
                    }
                    if let lastReceived = syncController.lastReceivedDate {
                        HStack {
                            Text("Последнее получение")
                            Spacer()
                            Text(lastReceived.formatted(.relative(presentation: .named)))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Button("Подключиться") {
                        Task { await syncController.connect() }
                    }
                    Button("Отключиться", role: .destructive) {
                        syncController.disconnect()
                    }
                }
            }
        }
        .navigationTitle("AyuSync")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var syncStateView: some View {
        switch syncController.state {
        case .disconnected:
            Label("Отключён", systemImage: "circle").foregroundStyle(.secondary)
        case .connecting:
            Label("Подключение...", systemImage: "circle.dotted").foregroundStyle(.orange)
        case .connected:
            Label("Подключён", systemImage: "circle.fill").foregroundStyle(.green)
        case .error(let msg):
            Label(msg, systemImage: "exclamationmark.circle").foregroundStyle(.red)
        }
    }
}
