import SwiftUI
import TDLibKit

struct ProfileSettingsView: View {
    @State private var me: User?
    private let client = TDLibClient.shared

    var body: some View {
        Form {
            if let user = me {
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.tint)
                                .frame(width: 64, height: 64)
                            Text(initials(user))
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading) {
                            Text("\(user.firstName) \(user.lastName ?? "")")
                                .font(.headline)
                            if let username = user.usernames?.activeUsernames.first {
                                Text("@\(username)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Аккаунт") {
                    if let phone = user.phoneNumber {
                        LabeledContent("Телефон", value: "+\(phone)")
                    }
                    LabeledContent("ID", value: "\(user.id)")
                }

                Section("Premium") {
                    HStack {
                        Label("Telegram Premium", systemImage: "star.fill")
                        Spacer()
                        Text(user.isPremium ? "Активен" : "Неактивен")
                            .foregroundStyle(user.isPremium ? .yellow : .secondary)
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            me = try? await client.send(GetMe())
        }
    }

    private func initials(_ user: User) -> String {
        let f = user.firstName.prefix(1)
        let l = (user.lastName ?? "").prefix(1)
        return "\(f)\(l)".uppercased()
    }
}
