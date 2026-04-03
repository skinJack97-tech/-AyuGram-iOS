import Foundation
import TDLibKit

extension TDLibClient {
    func configure() async throws {
        let params = SetTdlibParameters(
            apiHash: Secrets.apiHash,
            apiId: Secrets.apiId,
            applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            databaseDirectory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/tdlib",
            databaseEncryptionKey: Data(),
            deviceModel: UIDevice.current.model,
            filesDirectory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/tdlib/files",
            systemLanguageCode: Locale.current.language.languageCode?.identifier ?? "en",
            systemVersion: UIDevice.current.systemVersion,
            useChatInfoDatabase: true,
            useFileDatabase: true,
            useMessageDatabase: true,
            useSecretChats: true,
            useTestDc: false
        )
        let _: Ok = try await send(params)
    }
}

// MARK: - Secrets (замени на реальные API ключи)
enum Secrets {
    static let apiId: Int = 2040
    static let apiHash: String = "b18441a1ff607e10a989891a5462e627"
}
