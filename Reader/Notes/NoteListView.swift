import SwiftUI

struct NoteListView: View {
    @State private var notes: [Note] = []
    @State private var loading = true
    @State private var failed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    Text("手记")
                        .font(YuBai.serif(28, .bold))
                        .padding(.horizontal, 20).padding(.top, 8)
                    ForEach(notes) { note in
                        NavigationLink(value: note) { NoteCard(note: note) }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
            .background(PaperBackground())
            .navigationDestination(for: Note.self) { NoteDetailView(note: $0) }
            .task { await load() }
            .refreshable { await load() }
            .overlay {
                if loading && notes.isEmpty { ProgressView("正在翻阅手记…").frame(maxWidth: .infinity, maxHeight: .infinity).background(PaperBackground()) }
                else if failed && notes.isEmpty { ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark").background(PaperBackground()) }
            }
        }
        .tint(YuBai.accent)
    }
    private func load() async {
        failed = false; loading = notes.isEmpty
        do { notes = try await Api.get("notes", query: ["limit": "30", "orderBy": "created", "sortOrder": "-1"]) }
        catch { failed = true }
        loading = false
    }
}

struct NoteCard: View {
    let note: Note
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                if let m = note.mood, !m.isEmpty { TagView(text: m) }
                if let w = note.weather, !w.isEmpty { TagView(text: w) }
                Spacer()
                Text(DateFormatter.display(note.public_at ?? note.created_at))
                    .font(.caption2).foregroundStyle(YuBai.dim)
            }
            Text(note.title ?? "（无题）")
                .font(YuBai.serif(17, .semibold))
                .foregroundStyle(YuBai.ink)
                .lineLimit(1)
            if let t = note.text {
                Text(Plain.excerpt(from: t, limit: 72))
                    .font(.subheadline).foregroundStyle(YuBai.dim).lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(YuBai.card))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(YuBai.hairline.opacity(0.6), lineWidth: 1))
    }
}

struct TagView: View {
    let text: String
    var body: some View {
        Text(text).font(.caption2)
            .foregroundStyle(YuBai.accent)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(Capsule().stroke(YuBai.accent.opacity(0.4), lineWidth: 1))
    }
}
