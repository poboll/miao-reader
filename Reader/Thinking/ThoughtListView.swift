import SwiftUI
import MarkdownUI

struct ThoughtListView: View {
    @State private var thoughts: [Thought] = []
    @State private var loading = true
    @State private var failed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    Text("思考")
                        .font(YuBai.serif(28, .bold))
                        .padding(.horizontal, 20).padding(.top, 8)
                    ForEach(thoughts) { t in
                        VStack(alignment: .leading, spacing: 8) {
                            Markdown(Plain.text(from: t.content ?? ""))
                                .markdownTextStyle {
                                    FontSize(14.5)
                                    ForegroundColor(YuBai.ink)
                                }
                            Text(DateFormatter.display(t.created_at))
                                .font(.caption2).foregroundStyle(YuBai.dim)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14).fill(YuBai.card))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(YuBai.hairline.opacity(0.6), lineWidth: 1))
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
            .background(PaperBackground())
            .task { await load() }
            .refreshable { await load() }
            .overlay {
                if loading && thoughts.isEmpty { ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(PaperBackground()) }
                else if failed && thoughts.isEmpty { ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark").background(PaperBackground()) }
            }
        }
        .tint(YuBai.accent)
    }
    private func load() async {
        failed = false; loading = thoughts.isEmpty
        do { thoughts = try await Api.get("recently", query: ["limit": "30"]) }
        catch { failed = true }
        loading = false
    }
}
