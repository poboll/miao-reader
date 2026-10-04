import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("站点") {
                    LabeledContent("服务器", value: "kami.caiths.com")
                    LabeledContent("博客", value: "blog.caiths.com")
                }
                Section("关于") {
                    LabeledContent("版本", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0")
                    LabeledContent("App", value: "喵内阅读室 v0.1")
                    Link("在浏览器打开博客", destination: URL(string: "https://blog.caiths.com")!)
                }
                Section {
                    Text("阅读快乐。— 喵内")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("设置")
        }
    }
}
