import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var theme: ThemeStore
    @State private var tab: String = "posts"

    var body: some View {
        TabView(selection: $tab) {
            PostListView()
                .tabItem { Label("文章", systemImage: "text.justify.left") }
                .tag("posts")
            NoteListView()
                .tabItem { Label("手记", systemImage: "square.and.pencil") }
                .tag("notes")
            ThoughtListView()
                .tabItem { Label("思考", systemImage: "brain") }
                .tag("thinking")
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
                .tag("settings")
        }
        .tint(theme.accent)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .onAppear {
            // 截图/验收专用：-mrTab notes 可直开某 tab（正常启动不受影响）
            if let t = UserDefaults.standard.string(forKey: "mrTab") { tab = t }
        }
    }
}
