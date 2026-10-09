import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 站长名片
                    VStack(spacing: 10) {
                        AsyncImage(url: URL(string: "https://pic.imgdb.cn/item/653e1b74c458853aef64d366.webp")) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(YuBai.hairline)
                        }
                        .frame(width: 76, height: 76)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(YuBai.hairline, lineWidth: 1))

                        VStack(spacing: 2) {
                            Text("喵内").font(YuBai.serif(19, .bold)).foregroundStyle(YuBai.ink)
                            Text("修篱种花，小盏清茶。").font(.caption).foregroundStyle(YuBai.dim)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .background(RoundedRectangle(cornerRadius: 18).fill(YuBai.card))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(YuBai.hairline, lineWidth: 1))

                    // 主题色（动态同步自博客）
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Image(systemName: "paintpalette")
                                .frame(width: 20)
                                .foregroundStyle(theme.accent)
                            Text("主题色").foregroundStyle(YuBai.ink)
                            Spacer()
                            Circle()
                                .fill(theme.accent)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(YuBai.hairline, lineWidth: 1))
                            Text(theme.accentHex)
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(YuBai.dim)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16).padding(.vertical, 12)

                        Divider().overlay(YuBai.hairline).padding(.leading, 44)

                        HStack(spacing: 6) {
                            Image(systemName: theme.syncedFromBlog ? "checkmark.circle" : "clock")
                                .font(.caption2)
                            Text(theme.syncedFromBlog ? "已同步博客主题色，随博客设置自动变化" : "暂未取到博客主题色，正在使用内置玫瑰粉")
                                .font(.caption2)
                        }
                        .foregroundStyle(YuBai.dim)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }
                    .background(RoundedRectangle(cornerRadius: 16).fill(YuBai.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(YuBai.hairline, lineWidth: 1))

                    // 站点信息
                    VStack(spacing: 0) {
                        row(icon: "server.rack", label: "API 服务器", value: "kami.caiths.com")
                        Divider().overlay(YuBai.hairline).padding(.leading, 44)
                        row(icon: "safari", label: "博客", value: "blog.caiths.com")
                        Divider().overlay(YuBai.hairline).padding(.leading, 44)
                        row(icon: "doc.text", label: "手记与文章", value: "实时同步")
                    }
                    .background(RoundedRectangle(cornerRadius: 16).fill(YuBai.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(YuBai.hairline, lineWidth: 1))

                    // 关于
                    VStack(spacing: 0) {
                        Link(destination: URL(string: "https://blog.caiths.com")!) {
                            rowLabel(icon: "globe.asia.australia", label: "在浏览器打开博客")
                            Divider().overlay(YuBai.hairline).padding(.leading, 44)
                        }
                        Link(destination: URL(string: "https://github.com/poboll/miao-reader")!) {
                            rowLabel(icon: "curlybraces.square", label: "App 源码（MIT）")
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 16).fill(YuBai.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(YuBai.hairline, lineWidth: 1))

                    Text("喵内阅读室 · v0.4.0")
                        .font(.caption2).foregroundStyle(YuBai.dim)
                        .padding(.top, 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
            .background(PaperBackground())
            .navigationTitle("设置")
        }
        .tint(theme.accent)
    }

    private func row(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(theme.accent)
            Text(label).foregroundStyle(YuBai.ink)
            Spacer()
            Text(value).foregroundStyle(YuBai.dim)
        }
        .font(.subheadline)
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private func rowLabel(icon: String, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(theme.accent)
            Text(label).foregroundStyle(YuBai.ink)
            Spacer()
            Image(systemName: "chevron.right").font(.caption2).foregroundStyle(YuBai.dim)
        }
        .font(.subheadline)
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}
