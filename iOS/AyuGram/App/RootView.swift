import SwiftUI

struct RootView: View {
    @Environment(AuthViewModel.self) private var authVM

    var body: some View {
        switch authVM.state {
        case .loading:
            SplashView()
        case .unauthorized, .waitPhone, .waitCode, .waitPassword:
            AuthFlowView()
        case .authorized:
            MainTabView()
        }
    }
}
