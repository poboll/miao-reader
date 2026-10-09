import SwiftUI

@main
struct MiaoReaderApp: App {
    @StateObject private var theme = ThemeStore.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(theme)
                .task { await theme.loadFromBlog() }
        }
    }
}
