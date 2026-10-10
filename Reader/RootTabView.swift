import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var theme: ThemeStore
    @State private var tab: String = "posts"

    var body: some View {
        TabView(selection: $tab) {
            PostListView()
                .tabItem { Label("文章", systemImage: "text.justify.left") }
                .tag("posts")
            NoteListView()
                .tabItem { Label("手记", systemImage: "square.and.pencil") }
                .tag("notes")
            ThoughtListView()
                .tabItem { Label("思考", systemImage: "brain") }
                .tag("thinking")
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
                .tag("settings")
        }
        .tint(theme.accent)
        .toolbarBackground(.thickMaterial, for: .tabBar)
        .onAppear {
            // 截图/验收专用：-mrTab notes 可直开某 tab（正常启动不受影响）
            if let t = UserDefaults.standard.string(forKey: "mrTab") { tab = t }
        }
    }
}


// MARK: - 全局搜索（零依赖，调博客后端 /search；对标 Yohaku search 风格）

struct SearchHit: Decodable, Identifiable {
    let id: String
    let title: String?
    let slug: String?
    let text: String?
    let summary: String?
    let type: String?
    let created_at: String?
    let nid: Int?
    let category: Category?
}

struct SearchPage: Decodable { let data: [SearchHit] }

struct SearchView: View {
    @EnvironmentObject private var theme: ThemeStore
    @State private var query = ""
    @State private var hits: [SearchHit] = []
    @State private var loading = false
    @State private var searched = false
    @FocusState private var focused: Bool

    private var posts: [SearchHit] { hits.filter { $0.type == "post" } }
    private var notes: [SearchHit] { hits.filter { $0.type == "note" } }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("搜索")
                        .font(YuBai.serif(28, .bold))
                        .foregroundStyle(YuBai.ink)
                    Text("S E A R C H")
                        .font(.caption2.weight(.semibold))
                        .tracking(1)
                        .foregroundStyle(theme.accent.opacity(0.85))
                }
                .padding(.horizontal, 20).padding(.top, 8)

                if !searched && !loading {
                    emptyHint
                }

                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                }

                if searched && !loading && hits.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(YuBai.dim)
                        Text("没有找到与「\(query)」相关的内容")
                            .font(.subheadline)
                            .foregroundStyle(YuBai.dim)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }

                if !posts.isEmpty {
                    section(title: "文章") {
                        ForEach(posts) { hit in
                            NavigationLink(value: makePostItem(hit)) {
                                SearchHitRow(hit: hit, accent: theme.accent)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                        }
                    }
                }

                if !notes.isEmpty {
                    section(title: "手记") {
                        ForEach(notes) { hit in
                            NavigationLink(value: makeNote(hit)) {
                                SearchHitRow(hit: hit, accent: theme.accent)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                        }
                    }
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
        .safeAreaInset(edge: .top, spacing: 0) { searchBar }
        .navigationDestination(for: PostItem.self) { PostDetailView(item: $0) }
        .navigationDestination(for: Note.self) { NoteDetailView(note: $0) }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { Color.clear }
        }
        .task(id: query) {
            let keyword = query.trimmingCharacters(in: .whitespaces)
            guard keyword.count >= 2 else {
                hits = []; searched = false; loading = false
                return
            }
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await search(keyword)
        }
        .onAppear {
            // 截图/验收专用：-mrQuery 关键词 预填并搜索
            if let preset = UserDefaults.standard.string(forKey: "mrQuery") {
                UserDefaults.standard.removeObject(forKey: "mrQuery")
                query = preset
            }
            focused = true
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.accent)
            TextField("搜索文章、手记与思考", text: $query)
                .focused($focused)
                .submitLabel(.search)
                .foregroundStyle(YuBai.ink)
                .font(.system(.body, design: .serif))
            if !query.isEmpty {
                Button {
                    query = ""
                    hits = []; searched = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(YuBai.dim)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(YuBai.card)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(theme.accent.opacity(focused ? 0.55 : 0.18), lineWidth: 1))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private var emptyHint: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("试试搜点什么")
                .font(YuBai.serif(15))
                .foregroundStyle(YuBai.dim)
            HStack(spacing: 8) {
                ForEach(["博客", "E6", "时间"], id: \.self) { word in
                    Button(word) {
                        query = word
                    }
                    .font(.caption)
                    .foregroundStyle(theme.accent)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().stroke(theme.accent.opacity(0.35), lineWidth: 1))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.caption.weight(.semibold))
                .tracking(3)
                .foregroundStyle(YuBai.dim)
                .padding(.horizontal, 20)
            content()
        }
    }

    private func search(_ keyword: String) async {
        loading = true
        defer { loading = false }
        do {
            let page: SearchPage = try await Api.get("search", query: ["keyword": keyword, "limit": "40"])
            hits = page.data.filter { $0.type == "post" || $0.type == "note" }
            searched = true
        } catch {
            hits = []
            searched = true
        }
    }

    private func makePostItem(_ hit: SearchHit) -> PostItem {
        PostItem(id: hit.id, title: hit.title ?? "(无题)", slug: hit.slug,
                 summary: hit.summary, images: nil, category: hit.category,
                 created_at: hit.created_at)
    }

    private func makeNote(_ hit: SearchHit) -> Note {
        Note(id: hit.id, nid: hit.nid ?? 0, title: hit.title, text: hit.text,
             mood: nil, weather: nil, created_at: hit.created_at, public_at: hit.created_at)
    }
}

struct SearchHitRow: View {
    let hit: SearchHit
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Circle().fill(accent).frame(width: 5, height: 5)
                Text(DateFormatter.display(hit.created_at))
                    .font(.caption2).foregroundStyle(YuBai.dim)
                if let c = hit.category?.name {
                    Text(c).font(.caption2).foregroundStyle(accent.opacity(0.85))
                }
                Spacer()
            }
            Text(hit.title ?? "（无题）")
                .font(YuBai.serif(16, .semibold))
                .foregroundStyle(YuBai.ink)
                .lineLimit(2)
            if let snippet = snippetText {
                Text(snippet)
                    .font(.subheadline)
                    .foregroundStyle(YuBai.dim)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }

    private var snippetText: String? {
        if let s = hit.summary, !s.isEmpty { return s }
        if let t = hit.text, !t.isEmpty { return Plain.excerpt(from: t, limit: 52) }
        return nil
    }
}
