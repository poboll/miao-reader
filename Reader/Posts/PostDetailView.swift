import SwiftUI
import MarkdownUI

struct PostDetailView: View {
    let item: PostItem
    @State private var detail: PostDetail?
    @State private var failed = false
    @StateObject private var speech = SpeechController.shared
    @EnvironmentObject private var theme: ThemeStore

    var body: some View {
        Group {
            if let d = detail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(d.title)
                            .font(YuBai.serif(26, .bold))
                            .foregroundStyle(YuBai.ink)
                            .padding(.top, 16)
                        HStack(spacing: 10) {
                            if let c = d.category {
                                Text(c.name).font(.caption2).fontWeight(.medium)
                                    .foregroundStyle(theme.accent)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Capsule().fill(theme.accent.opacity(0.1)))
                            }
                            Text(DateFormatter.display(d.created_at))
                                .font(.caption).foregroundStyle(YuBai.dim)
                        }
                        Markdown(d.text ?? "")
                            .markdownTheme(.yuBaiReading(accent: theme.accent))
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
            } else if failed {
                ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark")
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if speech.isActive, let d = detail { SpeechMiniBar(text: d.text ?? "") }
        }
        .background(PaperBackground())
        .navigationTitle(item.title).navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                speechMenu(text: detail?.text ?? "")
            }
        }
        .task {
            do {
                let (d, status): (PostDetail, Int) = try await Api.getWithStatus("posts/\(item.id)")
                detail = status == 200 ? d : nil
                failed = detail == nil
                // 截图/验收专用：-mrAutoSpeak 1 自动开始朗读（展示迷你条）
                if UserDefaults.standard.object(forKey: "mrAutoSpeak") != nil, let t = detail?.text, !t.isEmpty {
                    speech.start(t)
                }
            } catch { failed = true }
        }
        .onDisappear { speech.stop() }
    }

    @ViewBuilder
    private func speechMenu(text: String) -> some View {
        Menu {
            Button {
                speech.toggle(text)
            } label: {
                Label(speech.state == .idle ? "朗读全文" : (speech.state == .paused ? "继续朗读" : "暂停朗读"),
                      systemImage: speech.state == .idle ? "play.fill" : (speech.state == .paused ? "play.fill" : "pause.fill"))
            }
            .disabled(text.isEmpty)
            if speech.isActive {
                Button(role: .destructive) {
                    speech.stop()
                } label: {
                    Label("停止", systemImage: "stop.fill")
                }
            }
            Divider()
            Menu {
                ForEach(SpeechController.rates, id: \.self) { r in
                    Button {
                        speech.setRate(r)
                    } label: {
                        if r == speech.rate {
                            Text("\(speech.rateLabel) ✓")
                        } else {
                            Text(r == floor(r) ? "\(Int(r))×" : "\(r)×")
                        }
                    }
                }
            } label: {
                Label("语速 \(speech.rateLabel)", systemImage: "gauge.with.dots.needle.33percent")
            }
        } label: {
            Image(systemName: speech.isActive ? "speaker.wave.2.fill" : "speaker.wave.2")
        }
        .disabled(text.isEmpty)
        .tint(theme.accent)
    }
}
