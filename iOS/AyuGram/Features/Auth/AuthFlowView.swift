import SwiftUI

struct AuthFlowView: View {
    @Environment(AuthViewModel.self) private var vm

    var body: some View {
        NavigationStack {
            switch vm.state {
            case .waitPhone, .unauthorized, .loading:
                PhoneInputView()
            case .waitCode:
                CodeInputView()
            case .waitPassword:
                PasswordInputView()
            default:
                PhoneInputView()
            }
        }
    }
}
