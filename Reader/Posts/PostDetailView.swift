import SwiftUI
import MarkdownUI

struct PostDetailView: View {
    let item: PostItem
    @State private var detail: PostDetail?
    @State private var failed = false
    @StateObject private var speech = SpeechController.shared

    var body: some View {
        ZStack { PaperBackground() }
        .navigationTitle(item.title).navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let d = detail { speech.toggle(d.text ?? "") }
                } label: {
                    Image(systemName: speech.speaking ? "stop.circle.fill" : "speaker.wave.2")
                }
                .disabled(detail == nil)
                .tint(YuBai.accent)
            }
        }
        .overlay {
            if failed { ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark") }
            else if detail == nil { ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity) }
            else if let d = detail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(d.title)
                            .font(YuBai.serif(26, .bold))
                            .foregroundStyle(YuBai.ink)
                            .padding(.top, 16)
                        HStack(spacing: 10) {
                            if let c = d.category {
                                Text(c.name).font(.caption2).fontWeight(.medium)
                                    .foregroundStyle(YuBai.accent)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Capsule().fill(YuBai.accent.opacity(0.1)))
                            }
                            Text(DateFormatter.display(d.created_at))
                                .font(.caption).foregroundStyle(YuBai.dim)
                        }
                        Markdown(d.text ?? "")
                            .markdownTheme(.yuBaiReading)
                            .markdownTextStyle {
                                FontSize(17)
                                ForegroundColor(YuBai.ink)
                            }
                        Text("完")
                            .font(YuBai.serif(13)).foregroundStyle(YuBai.dim)
                            .frame(maxWidth: .infinity).padding(.top, 26)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
            }
        }
        .task {
            do {
                let (d, status): (PostDetail, Int) = try await Api.getWithStatus("posts/\(item.id)")
                detail = status == 200 ? d : nil
                failed = detail == nil
            } catch { failed = true }
        }
    }
}
