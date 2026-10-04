import SwiftUI

struct NoteListView: View {
    @State private var notes: [Note] = []
    @State private var loading = true
    @State private var failed = false

    var body: some View {
        NavigationStack {
            Group {
                if loading { ProgressView("正在翻阅手记…") }
                else if failed { ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark") }
                else {
                    List {
                        ForEach(notes) { note in
                            NavigationLink(value: note) { NoteRow(note: note) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("手记")
            .navigationDestination(for: Note.self) { NoteDetailView(note: $0) }
            .task { await load() }
            .refreshable { await load() }
        }
    }
    private func load() async {
        failed = false; loading = notes.isEmpty
        do { notes = try await Api.get("notes", query: ["limit": "30", "orderBy": "created", "sortOrder": "-1"]) }
        catch { failed = true }
        loading = false
    }
}

struct NoteRow: View {
    let note: Note
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if let m = note.mood, !m.isEmpty { Text(m).font(.caption) }
                if let w = note.weather, !w.isEmpty { Text(w).font(.caption) }
            }
            Text(note.title ?? "（无题）").font(.headline).lineLimit(1)
            if let t = note.text {
                Text(t.replacingOccurrences(of: "\n", with: " ")).font(.subheadline)
                    .foregroundStyle(.secondary).lineLimit(2)
            }
            Text(DateFormatter.display(note.public_at ?? note.created_at))
                .font(.caption2).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
