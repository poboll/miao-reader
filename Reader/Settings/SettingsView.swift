import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack { PaperBackground() }
            .navigationTitle("设置")
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .center, spacing: 8) {
                        Image("AppIcon-1024") // 不一定在 bundle，失败时静默
                            .resizable().scaledToFill()
                            .frame(width: 72, height: 72).clipShape(RoundedRectangle(cornerRadius: 16))
                        Text("喵内阅读室").font(YuBai.serif(20, .bold)).foregroundStyle(YuBai.ink)
                        Text("阅读快乐。").font(.subheadline).foregroundStyle(YuBai.dim)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 16).fill(YuBai.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(YuBai.hairline.opacity(0.6), lineWidth: 1))

                    VStack(spacing: 0) {
                        row("服务器", "kami.caiths.com")
                        Divider().overlay(YuBai.hairline)
                        row("博客", "blog.caiths.com")
                        Divider().overlay(YuBai.hairline)
                        row("版本", Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.2.0")
                    }
                    .background(RoundedRectangle(cornerRadius: 14).fill(YuBai.card))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(YuBai.hairline.opacity(0.6), lineWidth: 1))

                    Link(destination: URL(string: "https://blog.caiths.com")!) {
                        HStack { Spacer(); Text("在浏览器打开博客 →").font(.subheadline); Spacer() }
                            .foregroundStyle(YuBai.accent)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(YuBai.card))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(YuBai.hairline.opacity(0.6), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
        }
        .tint(YuBai.accent)
    }
    private func row(_ k: String, _ v: String) -> some View {
        HStack { Text(k).foregroundStyle(YuBai.ink); Spacer(); Text(v).foregroundStyle(YuBai.dim) }
            .font(.subheadline).padding(.horizontal, 16).padding(.vertical, 12)
    }
}
