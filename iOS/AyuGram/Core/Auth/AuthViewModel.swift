import Foundation
import TDLibKit

enum AuthState {
    case loading
    case unauthorized
    case waitPhone
    case waitCode
    case waitPassword
    case authorized
}

@Observable
final class AuthViewModel {
    var state: AuthState = .loading
    var phoneNumber = ""
    var code = ""
    var password = ""
    var errorMessage: String?
    var isLoading = false

    private let client = TDLibClient.shared

    init() {
        observeUpdates()
        Task { try? await client.configure() }
    }

    private func observeUpdates() {
        NotificationCenter.default.addObserver(
            forName: .tdUpdate,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let update = notification.object as? Update else { return }
            self?.handleAuthUpdate(update)
        }
    }

    private func handleAuthUpdate(_ update: Update) {
        switch update {
        case .updateAuthorizationState(let s):
            switch s.authorizationState {
            case .authorizationStateWaitTdlibParameters:
                state = .loading
            case .authorizationStateWaitPhoneNumber:
                state = .waitPhone
            case .authorizationStateWaitCode:
                state = .waitCode
            case .authorizationStateWaitPassword:
                state = .waitPassword
            case .authorizationStateReady:
                state = .authorized
            case .authorizationStateClosed, .authorizationStateClosing, .authorizationStateLoggingOut:
                state = .unauthorized
            default:
                break
            }
        default:
            break
        }
    }

    func sendPhone() async {
        isLoading = true
        errorMessage = nil
        do {
            let _: Ok = try await client.send(SetAuthenticationPhoneNumber(
                phoneNumber: phoneNumber,
                settings: PhoneNumberAuthenticationSettings(
                    allowFlashCall: false,
                    allowMissedCall: false,
                    allowSmsRetrieverApi: false,
                    authenticationTokens: [],
                    hasUnknownPhoneNumber: false,
                    isCurrentPhoneNumber: false
                )
            ))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func sendCode() async {
        isLoading = true
        errorMessage = nil
        do {
            let _: Ok = try await client.send(CheckAuthenticationCode(code: code))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func sendPassword() async {
        isLoading = true
        errorMessage = nil
        do {
            let _: Ok = try await client.send(CheckAuthenticationPassword(password: password))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() async {
        let _: Ok? = try? await client.send(LogOut())
    }
}
