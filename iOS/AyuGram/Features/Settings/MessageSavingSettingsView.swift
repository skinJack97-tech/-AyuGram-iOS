import SwiftUI

struct MessageSavingSettingsView: View {
    @State private var config = AyuConfig.shared

    var body: some View {
        @Bindable var config = config

        Form {
            Section("История сообщений") {
                Toggle("Сохранять удалённые сообщения", isOn: $config.saveDeletedMessages)
                Toggle("Сохранять историю изменений", isOn: $config.saveMessagesHistory)
            }

            Section("Медиа") {
                Toggle("Сохранять медиа", isOn: $config.saveMedia)

                if config.saveMedia {
                    Toggle("В личных чатах", isOn: $config.saveMediaInPrivateChats)
                        .padding(.leading)
                    Toggle("В публичных каналах", isOn: $config.saveMediaInPublicChannels)
                        .padding(.leading)
                    Toggle("В приватных каналах", isOn: $config.saveMediaInPrivateChannels)
                        .padding(.leading)
                    Toggle("В публичных группах", isOn: $config.saveMediaInPublicGroups)
                        .padding(.leading)
                    Toggle("В приватных группах", isOn: $config.saveMediaInPrivateGroups)
                        .padding(.leading)
                    Toggle("Для ботов", isOn: $config.saveForBots)
                        .padding(.leading)
                }
            }

            Section("Дополнительно") {
                Toggle("Сохранять форматирование", isOn: $config.saveFormatting)
                Toggle("Сохранять реакции", isOn: $config.saveReactions)
            }

            Section("Метки") {
                HStack {
                    Text("Метка удалённого")
                    Spacer()
                    TextField("🧹", text: $config.deletedMarkText)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Метка изменённого")
                    Spacer()
                    TextField("Edited", text: $config.editedMarkText)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
            }
        }
        .navigationTitle("Сохранение сообщений")
        .navigationBarTitleDisplayMode(.inline)
    }
}
