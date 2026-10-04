import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            PostListView()
                .tabItem { Label("文章", systemImage: "text.justify.left") }
            NoteListView()
                .tabItem { Label("手记", systemImage: "square.and.pencil") }
            ThoughtListView()
                .tabItem { Label("思考", systemImage: "brain") }
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
        .tint(YuBai.accent)
    }
}
