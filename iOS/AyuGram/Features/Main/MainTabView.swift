import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Чаты", systemImage: "bubble.left.and.bubble.right.fill", value: 0) {
                ChatListView()
            }
            Tab("Контакты", systemImage: "person.2.fill", value: 1) {
                ContactsView()
            }
            Tab("Звонки", systemImage: "phone.fill", value: 2) {
                CallsView()
            }
            Tab("Настройки", systemImage: "gearshape.fill", value: 3) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
