import SwiftUI
import MarkdownUI

struct NoteDetailView: View {
    let note: Note
    @StateObject private var speech = SpeechController.shared

    var body: some View {
        ZStack { PaperBackground() }
        .navigationTitle(note.title ?? "手记").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { speech.toggle(note.text ?? "") } label: {
                    Image(systemName: speech.speaking ? "stop.circle.fill" : "speaker.wave.2")
                }
                .tint(YuBai.accent)
            }
        }
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(note.title ?? "（无题）")
                    .font(YuBai.serif(24, .bold))
                    .foregroundStyle(YuBai.ink)
                    .padding(.top, 16)
                HStack(spacing: 10) {
                    if let m = note.mood, !m.isEmpty { TagView(text: "心情 · \(m)") }
                    if let w = note.weather, !w.isEmpty { TagView(text: "天气 · \(w)") }
                    Spacer()
                    Text(DateFormatter.display(note.public_at ?? note.created_at))
                        .font(.caption).foregroundStyle(YuBai.dim)
                }
                Markdown(note.text ?? "")
                    .markdownTheme(.yuBaiReading)
                    .markdownTextStyle { FontSize(16.5); ForegroundColor(YuBai.ink) }
                Text("— 完 —")
                    .font(YuBai.serif(13)).foregroundStyle(YuBai.dim)
                    .frame(maxWidth: .infinity).padding(.top, 24)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 60)
        }
    }

    private func removed() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(note.title ?? "（无题）")
                    .font(YuBai.serif(24, .bold))
                    .foregroundStyle(YuBai.ink)
                    .padding(.top, 16)
                HStack(spacing: 10) {
                    if let m = note.mood, !m.isEmpty { TagView(text: "心情 · \(m)") }
                    if let w = note.weather, !w.isEmpty { TagView(text: "天气 · \(w)") }
                    Spacer()
                    Text(DateFormatter.display(note.public_at ?? note.created_at))
                        .font(.caption).foregroundStyle(YuBai.dim)
                }
                Markdown(note.text ?? "")
                    .markdownTheme(.yuBaiReading)
                    .markdownTextStyle { FontSize(16.5); ForegroundColor(YuBai.ink) }
                Text("— 完 —")
                    .font(YuBai.serif(13)).foregroundStyle(YuBai.dim)
                    .frame(maxWidth: .infinity).padding(.top, 24)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 60)
        }
    }
}
