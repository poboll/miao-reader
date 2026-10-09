import SwiftUI
import MarkdownUI

struct NoteDetailView: View {
    let note: Note
    @StateObject private var speech = SpeechController.shared
    @EnvironmentObject private var theme: ThemeStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(note.title ?? "（无题）")
                    .font(YuBai.serif(24, .bold))
                    .foregroundStyle(YuBai.ink)
                    .padding(.top, 16)
                HStack(spacing: 10) {
                    if let m = note.mood, !m.isEmpty { TagView(text: "心情 · \(m)", accent: theme.accent) }
                    if let w = note.weather, !w.isEmpty { TagView(text: "天气 · \(w)", accent: theme.accent) }
                    Spacer()
                    Text(DateFormatter.display(note.public_at ?? note.created_at))
                        .font(.caption).foregroundStyle(YuBai.dim)
                }
                Markdown(note.text ?? "")
                    .markdownTheme(.yuBaiReading(accent: theme.accent))
                    .markdownTextStyle { FontSize(16.5); ForegroundColor(YuBai.ink) }
                Text("— 完 —")
                    .font(YuBai.serif(13)).foregroundStyle(YuBai.dim)
                    .frame(maxWidth: .infinity).padding(.top, 24)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 60)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if speech.isActive { SpeechMiniBar(text: note.text ?? "") }
        }
        .background(PaperBackground())
        .navigationTitle(note.title ?? "手记").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                speechMenu(text: note.text ?? "")
            }
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
        .tint(theme.accent)
    }
}
