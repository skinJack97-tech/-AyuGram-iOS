import SwiftUI
import TDLibKit

struct ContactsView: View {
    @State private var contacts: [User] = []
    @State private var searchQuery = ""
    private let client = TDLibClient.shared

    var filtered: [User] {
        guard !searchQuery.isEmpty else { return contacts }
        return contacts.filter {
            "\($0.firstName) \($0.lastName ?? "")".localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.id) { user in
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(.tint).frame(width: 44, height: 44)
                        Text("\(user.firstName.prefix(1))\((user.lastName ?? "").prefix(1))".uppercased())
                            .font(.headline).foregroundStyle(.white)
                    }
                    VStack(alignment: .leading) {
                        Text("\(user.firstName) \(user.lastName ?? "")")
                            .font(.headline)
                        if let username = user.usernames?.activeUsernames.first {
                            Text("@\(username)").foregroundStyle(.secondary).font(.caption)
                        }
                    }
                }
            }
            .searchable(text: $searchQuery, prompt: "Поиск контактов")
            .navigationTitle("Контакты")
        }
        .task {
            if let result: Users = try? await client.send(GetContacts()) {
                for id in result.userIds {
                    if let user: User = try? await client.send(GetUser(userId: id)) {
                        contacts.append(user)
                    }
                }
            }
        }
    }
}
