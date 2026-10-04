import SwiftUI

struct PostListView: View {
    @State private var posts: [PostItem] = []
    @State private var loading = true
    @State private var failed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    Text("文章")
                        .font(YuBai.serif(28, .bold))
                        .padding(.horizontal, 20).padding(.top, 8)
                    ForEach(posts) { post in
                        NavigationLink(value: post) { PostCard(post: post) }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
            .background(PaperBackground())
            .navigationDestination(for: PostItem.self) { PostDetailView(item: $0) }
            .task { await load() }
            .refreshable { await load() }
            .overlay {
                if loading && posts.isEmpty { ProgressView("正在向服务器飞奔…").frame(maxWidth: .infinity, maxHeight: .infinity).background(PaperBackground()) }
                else if failed && posts.isEmpty { ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark").background(PaperBackground()) }
            }
        }
        .tint(YuBai.accent)
    }
    private func load() async {
        failed = false; loading = posts.isEmpty
        do { posts = try await Api.get("posts", query: ["limit": "30", "orderBy": "created", "sortOrder": "-1"]) }
        catch { failed = true }
        loading = false
    }
}

struct PostCard: View {
    let post: PostItem
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 内容
            if let cover = post.images?.first, let url = URL(string: cover) {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(YuBai.hairline).aspectRatio(16/9, contentMode: .fit)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Text(post.title)
                .font(YuBai.serif(19, .semibold))
                .foregroundStyle(YuBai.ink)
                .lineLimit(2)
            if let s = post.summary, !s.isEmpty {
                Text(Plain.excerpt(from: s, limit: 64))
                    .font(.subheadline)
                    .foregroundStyle(YuBai.dim)
                    .lineLimit(2)
            }
            HStack {
                Text(post.category?.name ?? "未分类")
                    .font(.caption2).fontWeight(.medium)
                    .foregroundStyle(YuBai.accent)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(YuBai.accent.opacity(0.1)))
                Spacer()
                Text(DateFormatter.display(post.created_at))
                    .font(.caption2).foregroundStyle(YuBai.dim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(YuBai.card))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(YuBai.hairline.opacity(0.6), lineWidth: 1))
    }
}
