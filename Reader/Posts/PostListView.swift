import SwiftUI

/// 文章列表：最新一篇大卡（有封面用图，无封面用主题色文字大卡）+ 按月分组时间线
/// 结构对标 Innei 的 Yohaku App 首页（hero + grouped timeline rows）
struct PostListView: View {
    @State private var posts: [PostItem] = []
    @State private var loading = true
    @State private var failed = false
    @State private var autoPush = false
    @EnvironmentObject private var theme: ThemeStore

    private var monthGroups: [(month: String, posts: [PostItem])] {
        var order: [String] = []
        var buckets: [String: [PostItem]] = [:]
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        for p in posts.dropFirst() {
            let key = p.created_at.flatMap { DateFormatter.api.date(from: $0) }.map { f.string(from: $0) } ?? "更早"
            if buckets[key] == nil { order.append(key) }
            buckets[key, default: []].append(p)
        }
        return order.map { ($0, buckets[$0]!) }
    }

    /// mx-space 列表置顶排最前：hero 不是全列表最新时说明被置顶
    private var heroBadge: String {
        guard posts.count > 1,
              let heroDate = posts[0].created_at.flatMap({ DateFormatter.api.date(from: $0) }),
              let nextDate = posts[1].created_at.flatMap({ DateFormatter.api.date(from: $0) })
        else { return "最新" }
        return heroDate < nextDate ? "置顶" : "最新"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("文章")
                            .font(YuBai.serif(28, .bold))
                            .foregroundStyle(YuBai.ink)
                        Text("W R I T I N G")
                            .font(.caption2.weight(.semibold))
                            .tracking(1)
                            .foregroundStyle(theme.accent.opacity(0.85))
                    }
                    .padding(.horizontal, 20).padding(.top, 8)
                        .font(YuBai.serif(28, .bold))
                        .foregroundStyle(YuBai.ink)
                        .padding(.horizontal, 20).padding(.top, 8)

                    if let latest = posts.first {
                        NavigationLink(value: latest) { PostHeroCard(post: latest, accent: theme.accent, badge: heroBadge) }
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
                            ForEach(group.posts) { post in
                                NavigationLink(value: post) { PostTimelineRow(post: post, accent: theme.accent) }
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
            .navigationDestination(for: PostItem.self) { PostDetailView(item: $0) }
            .navigationDestination(isPresented: $autoPush) {
                if let first = posts.first { PostDetailView(item: first) }
            }
            .task {
                await load()
                // 截图/验收专用：-mrOpenFirst 1 自动进第一篇
                if UserDefaults.standard.object(forKey: "mrOpenFirst") != nil { autoPush = true }
            }
            .refreshable { await load() }
            .overlay {
                if loading && posts.isEmpty { ProgressView("正在向服务器飞奔…").frame(maxWidth: .infinity, maxHeight: .infinity).background(PaperBackground()) }
                else if failed && posts.isEmpty { ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark").background(PaperBackground()) }
            }
        }
        .tint(theme.accent)
    }
    private func load() async {
        failed = false; loading = posts.isEmpty
        do { posts = try await Api.get("posts", query: ["limit": "30", "orderBy": "created", "sortOrder": "-1"]) }
        catch { failed = true }
        loading = false
    }
}

/// 最新一篇：大卡。有封面 → 图 + 底部渐变压字；无封面 → 主题色纸面 + 大号衬线标题（永不为空）
struct PostHeroCard: View {
    let post: PostItem
    let accent: Color
    var badge: String = "最新"

    var body: some View {
        if let cover = post.images?.first, let url = URL(string: cover) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(accent.opacity(0.15))
                }
                .frame(height: 230)
                .frame(maxWidth: .infinity)
                .clipped()

                LinearGradient(colors: [.black.opacity(0.72), .black.opacity(0.28), .clear], startPoint: .bottom, endPoint: .center)
                    .frame(height: 150)

                VStack(alignment: .leading, spacing: 6) {
                    Text(badge)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(.white.opacity(0.18)))
                    Text(post.title)
                        .font(YuBai.serif(21, .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(DateFormatter.display(post.created_at))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(16)
            }
            .frame(height: 230)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(YuBai.hairline.opacity(0.6), lineWidth: 1))
        } else {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(badge)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(accent)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(accent.opacity(0.12)))
                    Spacer()
                    Text(post.category?.name ?? "")
                        .font(.caption2)
                        .foregroundStyle(YuBai.dim)
                }
                Text(post.title)
                    .font(YuBai.serif(23, .bold))
                    .foregroundStyle(YuBai.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                if let s = post.summary, !s.isEmpty {
                    Text(Plain.excerpt(from: s, limit: 96))
                        .font(YuBai.serif(15))
                        .foregroundStyle(YuBai.dim)
                        .lineLimit(3)
                        .mask(alignment: .bottom) {
                            LinearGradient(stops: [
                                .init(color: .black, location: 0.7),
                                .init(color: .clear, location: 1),
                            ], startPoint: .top, endPoint: .bottom)
                        }
                }
                Text(DateFormatter.display(post.created_at))
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
}

/// 时间线行：日历式左列 + 标题（学 Yohaku 的 grouped rows）
struct PostTimelineRow: View {
    let post: PostItem
    let accent: Color

    private var day: String {
        guard let d = post.created_at.flatMap({ DateFormatter.api.date(from: $0) }) else { return "·" }
        let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: d)
    }
    private var weekday: String {
        guard let d = post.created_at.flatMap({ DateFormatter.api.date(from: $0) }) else { return "" }
        let f = DateFormatter(); f.locale = Locale(identifier: "zh_CN"); f.dateFormat = "EEE"; return f.string(from: d)
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 0) {
                Text(day)
                    .font(YuBai.serif(20, .bold))
                    .foregroundStyle(YuBai.ink)
                Text(weekday)
                    .font(.caption2)
                    .foregroundStyle(YuBai.dim)
            }
            .frame(width: 40)

            Rectangle().fill(accent.opacity(0.55)).frame(width: 2.5, height: 34)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(YuBai.serif(16.5, .semibold))
                    .foregroundStyle(YuBai.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if let c = post.category?.name {
                    Text(c).font(.caption2).foregroundStyle(accent)
                }
                if let sum = post.summary, !sum.isEmpty {
                    Text(Plain.excerpt(from: sum, limit: 44))
                        .font(.subheadline)
                        .foregroundStyle(YuBai.dim)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
