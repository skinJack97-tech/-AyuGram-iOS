/*
 * AyuGram for iOS
 * Copyright @Radolyn, 2023
 * iOS 26 / SwiftUI / Liquid Glass
 */

import SwiftUI
import TDLibKit

@main
struct AyuGramApp: App {
    @State private var tdClient = TDLibClient.shared
    @State private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(tdClient)
                .environment(authVM)
        }
    }
}
