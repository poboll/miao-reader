import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            PostListView()
                .tabItem { Label("文章", systemImage: "doc.text") }
            NoteListView()
                .tabItem { Label("手记", systemImage: "square.and.pencil") }
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
    }
}
