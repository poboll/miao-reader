import SwiftUI

struct PostListView: View {
    @State private var posts: [Post] = []
    @State private var loading = true
    @State private var failed = false

    var body: some View {
        NavigationStack {
            Group {
                if loading { ProgressView("正在向服务器飞奔…") }
                else if failed { ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark") }
                else {
                    List {
                        ForEach(posts) { post in
                            NavigationLink(value: post) { PostRow(post: post) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("文章")
            .navigationDestination(for: Post.self) { PostDetailView(post: $0) }
            .task { await load() }
            .refreshable { await load() }
        }
    }
    private func load() async {
        failed = false; loading = posts.isEmpty
        do { posts = try await Api.get("posts", query: ["limit": "30", "orderBy": "created", "sortOrder": "-1"]) }
        catch { failed = true }
        loading = false
    }
}

struct PostRow: View {
    let post: Post
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(post.title).font(.headline).lineLimit(2)
            if let s = post.summary, !s.isEmpty {
                Text(s).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
            }
            HStack {
                if let c = post.category { Text(c.name).font(.caption).foregroundStyle(.tint) }
                Spacer()
                Text(DateFormatter.display(post.created_at)).font(.caption2).foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
