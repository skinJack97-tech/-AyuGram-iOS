import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("colorScheme") private var colorSchemeRaw = 0
    @AppStorage("accentColor") private var accentColorRaw = "blue"

    private let accentColors: [(String, Color)] = [
        ("blue", .blue), ("purple", .purple), ("pink", .pink),
        ("orange", .orange), ("green", .green), ("teal", .teal), ("indigo", .indigo)
    ]

    var body: some View {
        Form {
            Section("Тема") {
                Picker("Цветовая схема", selection: $colorSchemeRaw) {
                    Text("Системная").tag(0)
                    Text("Светлая").tag(1)
                    Text("Тёмная").tag(2)
                }
                .pickerStyle(.segmented)
            }

            Section("Акцентный цвет") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(accentColors, id: \.0) { name, color in
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)
                            .overlay {
                                if accentColorRaw == name {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.white)
                                        .font(.caption.bold())
                                }
                            }
                            .onTapGesture { accentColorRaw = name }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Liquid Glass") {
                Text("iOS 26 автоматически применяет Liquid Glass к элементам интерфейса")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Внешний вид")
        .navigationBarTitleDisplayMode(.inline)
    }
}
