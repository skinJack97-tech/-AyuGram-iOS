import SwiftUI

struct RegexFiltersView: View {
    @State private var config = AyuConfig.shared
    @State private var newFilter = ""
    @State private var editingIndex: Int?
    @State private var editingText = ""

    var body: some View {
        @Bindable var config = config

        Form {
            Section {
                Toggle("Включить фильтры", isOn: $config.regexFiltersEnabled)
                if config.regexFiltersEnabled {
                    Toggle("Фильтровать в чатах", isOn: $config.regexFiltersInChats)
                    Toggle("Без учёта регистра", isOn: $config.regexFiltersCaseInsensitive)
                }
            }

            if config.regexFiltersEnabled {
                Section("Добавить фильтр") {
                    HStack {
                        TextField("Regex-паттерн", text: $newFilter)
                            .font(.system(.body, design: .monospaced))
                        Button("Добавить") {
                            guard !newFilter.isEmpty else { return }
                            config.addFilter(newFilter)
                            AyuFilter.shared.rebuildCache()
                            newFilter = ""
                        }
                        .disabled(newFilter.isEmpty)
                    }
                }

                Section("Активные фильтры (\(config.regexFilters.count))") {
                    ForEach(config.regexFilters.indices, id: \.self) { idx in
                        HStack {
                            Text(config.regexFilters[idx])
                                .font(.system(.body, design: .monospaced))
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { config.removeFilter(at: $0) }
                        AyuFilter.shared.rebuildCache()
                    }
                }
            }
        }
        .navigationTitle("Regex-фильтры")
        .navigationBarTitleDisplayMode(.inline)
    }
}
