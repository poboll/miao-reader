import SwiftUI

/// 手记列表：最新一篇主题色大卡 + 按月分组时间线（对标 Yohaku 的 note-latest hero + timeline）
struct NoteListView: View {
    @State private var notes: [Note] = []
    @State private var loading = true
    @State private var failed = false
    @EnvironmentObject private var theme: ThemeStore

    private var monthGroups: [(month: String, notes: [Note])] {
        var order: [String] = []
        var buckets: [String: [Note]] = [:]
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        for n in notes.dropFirst() {
            let date = n.public_at ?? n.created_at
            let key = date.flatMap { DateFormatter.api.date(from: $0) }.map { f.string(from: $0) } ?? "更早"
            if buckets[key] == nil { order.append(key) }
            buckets[key, default: []].append(n)
        }
        return order.map { ($0, buckets[$0]!) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("手记")
                            .font(YuBai.serif(28, .bold))
                            .foregroundStyle(YuBai.ink)
                        Text("L E T T E R S")
                            .font(.caption2.weight(.semibold))
                            .tracking(1)
                            .foregroundStyle(theme.accent.opacity(0.85))
                    }
                    .padding(.horizontal, 20).padding(.top, 8)

                    if let latest = notes.first {
                        NavigationLink(value: latest) { NoteHeroCard(note: latest, accent: theme.accent) }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                    }

                    ForEach(monthGroups, id: \.month) { group in
                        VStack(alignment: .leading, spacing: 14) {
                            Text(group.month)
                                .font(.caption.weight(.semibold))
                                .tracking(3)
                                .foregroundStyle(YuBai.dim)
                                .padding(.horizontal, 20)
                            ForEach(group.notes) { note in
                                NavigationLink(value: note) { NoteTimelineRow(note: note, accent: theme.accent) }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(.bottom, 110)
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
        .tint(theme.accent)
    }
    private func load() async {
        failed = false; loading = notes.isEmpty
        do { notes = try await Api.get("notes", query: ["limit": "30", "orderBy": "created", "sortOrder": "-1"]) }
        catch { failed = true }
        loading = false
    }
}

/// 最新手记：主题色纸面大卡 + 心情/天气徽标（学 Yohaku 的 text hero——无封面也不空）
struct NoteHeroCard: View {
    let note: Note
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("最近")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(accent.opacity(0.12)))
                Spacer()
                if let m = note.mood, !m.isEmpty { TagView(text: m, accent: accent) }
                if let w = note.weather, !w.isEmpty { TagView(text: w, accent: accent) }
            }
            Text(note.title ?? Plain.excerpt(from: note.text ?? "", limit: 40))
                .font(YuBai.serif(20, .bold))
                .foregroundStyle(YuBai.ink)
                .lineLimit(2)
            if let t = note.text {
                Text(Plain.excerpt(from: t, limit: 140))
                    .font(YuBai.serif(15))
                    .foregroundStyle(YuBai.dim)
                    .lineLimit(4)
                    .mask(alignment: .bottom) {
                        LinearGradient(stops: [
                            .init(color: .black, location: 0.65),
                            .init(color: .clear, location: 1),
                        ], startPoint: .top, endPoint: .bottom)
                    }
            }
            Text(DateFormatter.display(note.public_at ?? note.created_at))
                .font(.caption)
                .foregroundStyle(YuBai.dim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(accent.opacity(0.07))
                LinearGradient(colors: [accent.opacity(0.10), .clear], startPoint: .topLeading, endPoint: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(accent.opacity(0.25), lineWidth: 1))
    }
}

/// 手记时间线行
struct NoteTimelineRow: View {
    let note: Note
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Circle().fill(accent).frame(width: 5, height: 5)
                Text(DateFormatter.display(note.public_at ?? note.created_at))
                    .font(.caption2).foregroundStyle(YuBai.dim)
                if let m = note.mood, !m.isEmpty {
                    Text(m).font(.caption2).foregroundStyle(accent.opacity(0.8))
                }
                Spacer()
            }
            Text(note.title ?? "（无题）")
                .font(YuBai.serif(16, .semibold))
                .foregroundStyle(YuBai.ink)
                .lineLimit(1)
            if let t = note.text {
                Text(Plain.excerpt(from: t, limit: 60))
                    .font(.subheadline).foregroundStyle(YuBai.dim).lineLimit(2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

struct TagView: View {
    let text: String
    var accent: Color = YuBai.accent
    var body: some View {
        Text(text).font(.caption2)
            .foregroundStyle(accent)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(Capsule().stroke(accent.opacity(0.4), lineWidth: 1))
    }
}
