import SwiftUI

struct PostDetailView: View {
    let item: PostItem
    @State private var detail: PostDetail?
    @State private var plainText = ""
    @State private var failed = false
    @StateObject private var speech = SpeechController.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.title).font(.title2).bold().padding(.horizontal)
                HStack {
                    if let c = item.category { Text(c.name).font(.caption).foregroundStyle(.tint) }
                    Spacer()
                    Text(DateFormatter.display(item.created_at)).font(.caption).foregroundStyle(.tertiary)
                }.padding(.horizontal)
                if let d = detail {
                    ArticleMarkdown(markdown: d.text ?? "")
                        .padding(.horizontal, 14)
                } else if failed {
                    ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark").padding(60)
                } else {
                    ProgressView().frame(maxWidth: .infinity).padding(80)
                }
            }
            .padding(.bottom, 60)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let d = detail { speech.toggle(d.text ?? "") }
                } label: {
                    Image(systemName: speech.speaking ? "stop.circle" : "speaker.wave.2")
                }
                .disabled(detail == nil)
            }
        }
        .task {
            do {
                let (d, status): (PostDetail, Int) = try await Api.getWithStatus("posts/\(item.id)")
                if status == 200 { detail = d } else { failed = true }
            } catch { failed = true }
        }
    }
}
