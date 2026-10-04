import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @StateObject private var speech = SpeechController.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(note.title ?? "（无题）").font(.title2).bold().padding(.horizontal)
                HStack {
                    if let m = note.mood, !m.isEmpty { Text("心情 \(m)").font(.caption).foregroundStyle(.secondary) }
                    if let w = note.weather, !w.isEmpty { Text("天气 \(w)").font(.caption).foregroundStyle(.secondary) }
                    Spacer()
                    Text(DateFormatter.display(note.public_at ?? note.created_at)).font(.caption).foregroundStyle(.tertiary)
                }.padding(.horizontal)
                ArticleMarkdown(markdown: note.text ?? "")
                    .padding(.horizontal, 14)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { speech.toggle(note.text ?? "") } label: {
                    Image(systemName: speech.speaking ? "stop.circle" : "speaker.wave.2")
                }
            }
        }
    }
}
