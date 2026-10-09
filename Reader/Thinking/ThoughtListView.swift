import SwiftUI
import MarkdownUI

/// 思考流：左侧 accent 时间轴（圆点 + 连线）+ 卡片内容，对标 Yohaku thinking timeline
struct ThoughtListView: View {
    @State private var thoughts: [Thought] = []
    @State private var loading = true
    @State private var failed = false
    @EnvironmentObject private var theme: ThemeStore

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("思考")
                            .font(YuBai.serif(28, .bold))
                            .foregroundStyle(YuBai.ink)
                        Text("T H O U G H T S")
                            .font(.caption2.weight(.semibold))
                            .tracking(1)
                            .foregroundStyle(theme.accent.opacity(0.85))
                    }
                    .padding(.horizontal, 20).padding(.top, 8)
                    .padding(.bottom, 12)

                    ForEach(Array(thoughts.enumerated()), id: \.element.id) { idx, t in
                        HStack(alignment: .top, spacing: 12) {
                            // 时间轴列：圆点 + 连线
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(theme.accent)
                                    .frame(width: 7, height: 7)
                                    .padding(.top, 10)
                                if idx < thoughts.count - 1 {
                                    Rectangle()
                                        .fill(YuBai.hairline)
                                        .frame(width: 1.5)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 14)

                            VStack(alignment: .leading, spacing: 8) {
                                Markdown(Plain.text(from: t.content ?? ""))
                                    .markdownTextStyle {
                                        FontSize(14.5)
                                        ForegroundColor(YuBai.ink)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(YuBai.card))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(YuBai.hairline.opacity(0.6), lineWidth: 1))
                                Text(DateFormatter.display(t.created_at))
                                    .font(.caption2)
                                    .foregroundStyle(YuBai.dim)
                                    .padding(.leading, 4)
                                    .padding(.bottom, 14)
                            }
                        }
                        .padding(.horizontal, 16)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.bottom, 110)
            }

            .overlay(alignment: .bottom) {
                LinearGradient(colors: [.clear, YuBai.paper.opacity(0.88), YuBai.paper],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 140)
                    .allowsHitTesting(false)
                    .ignoresSafeArea(edges: .bottom)
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
        .tint(theme.accent)
    }
    private func load() async {
        failed = false; loading = thoughts.isEmpty
        do { thoughts = try await Api.get("recently", query: ["limit": "30"]) }
        catch { failed = true }
        loading = false
    }
}
