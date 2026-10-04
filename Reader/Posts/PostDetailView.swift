import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var plainText = ""
    @State private var loaded = false
    @State private var detail: Post?
    private var body_markdown: String { (detail?.text ?? post.text) ?? "" }
    @StateObject private var speech = SpeechController.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(post.title).font(.title2).bold().padding(.horizontal)
                HStack {
                    if let c = post.category { Text(c.name).font(.caption).foregroundStyle(.tint) }
                    Spacer()
                    Text(DateFormatter.display(post.created_at)).font(.caption).foregroundStyle(.tertiary)
                }.padding(.horizontal)
                if loaded {
                    MarkdownPage(markdown: body_markdown, plainText: $plainText)
                        .frame(minHeight: 1200)
                } else {
                    ProgressView().frame(maxWidth: .infinity).padding(60)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if plainText.isEmpty { loaded = true }
                    speech.toggle(plainText)
                } label: {
                    Image(systemName: speech.speaking ? "stop.circle" : "speaker.wave.2")
                }
            }
        }
        .task {
            // 详情接口拿全文（列表的 text 可能截断）
            if let d: Post = try? await Api.get("posts/\(post.id)") { detail = d }
            loaded = true
        }
    }
}
