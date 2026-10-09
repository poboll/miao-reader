import SwiftUI

/// 设计令牌 = poboll/Shiroi（Yohaku）主题 variables.css 原值：
/// 一个点缀（灰玫瑰 #e095a4）+ 三级中性 + 其余留白
enum YuBai {
    static let paper    = Color(light: UIColor(red: 1.00, green: 1.00, blue: 0.984, alpha: 1),   // #fefefb
                                dark:  UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1))    // #1c1c1e
    static let card     = Color(light: .white,
                                dark:  UIColor(red: 0.141, green: 0.141, blue: 0.157, alpha: 1))  // #242424
    static let ink      = Color(light: UIColor(red: 0.078, green: 0.078, blue: 0.078, alpha: 1),  // #141414
                                dark:  UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1))  // #f8f8f8
    static let dim      = Color(light: UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1),     // #787878
                                dark:  UIColor(red: 0.596, green: 0.596, blue: 0.596, alpha: 1))
    static let accent   = accentFallback  // 静态回退；动态值走 ThemeStore（environmentObject）
    static let accentFallback = Color(light: UIColor(red: 0.878, green: 0.584, blue: 0.643, alpha: 1),  // #e095a4
                                dark:  UIColor(red: 0.878, green: 0.584, blue: 0.643, alpha: 1))
    static let accentFallbackHex = "#e095a4"
    static let hairline = Color(light: UIColor(red: 0.094, green: 0.094, blue: 0.106, alpha: 0.08),
                                dark:  UIColor(red: 1, green: 1, blue: 1, alpha: 0.10))

    static let serifTitle = Font.system(.title2, design: .serif).weight(.bold)
    static let serifBody = Font.system(size: 16.5, design: .serif)
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .serif)
    }
}

extension Color {
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}

/// 通用页面背景
struct PaperBackground: View {
    var body: some View { YuBai.paper.ignoresSafeArea() }
}


// MARK: - 动态主题（从博客 CSS 同步 accent）

@MainActor
final class ThemeStore: ObservableObject {
    @Published private(set) var accent: Color = YuBai.accentFallback
    @Published private(set) var accentHex: String = YuBai.accentFallbackHex
    @Published private(set) var syncedFromBlog = false

    static let shared = ThemeStore()
    private let cacheKey = "miao.blog.accent.hex"

    private init() {
        if let saved = UserDefaults.standard.string(forKey: cacheKey),
           let color = Color(hexString: saved) {
            accent = color
            accentHex = saved
        }
    }

    /// 拉取博客首页 → 找编译后的 CSS → 解析 --color-accent
    func loadFromBlog() async {
        guard let home = await Self.fetchString("https://blog.caiths.com/") else { return }
        let pattern = #"(?:href|src)="([^"]+\.css[^"]*)""#
        guard let re = try? NSRegularExpression(pattern: pattern) else { return }
        let ns = home as NSString
        var hrefs: [String] = []
        for m in re.matches(in: home, range: NSRange(location: 0, length: ns.length)) {
            if hrefs.count >= 6 { break }
            let raw = ns.substring(with: m.range(at: 1))
            let url = raw.hasPrefix("http") ? raw : "https://blog.caiths.com\(raw)"
            if !hrefs.contains(url) { hrefs.append(url) }
        }
        for href in hrefs {
            guard let css = await Self.fetchString(href) else { continue }
            if let hex = Self.firstMatch(in: css, pattern: #"--color-accent:\s*(#[0-9a-fA-F]{3,8})"#) {
                apply(hex)
                return
            }
        }
    }

    private func apply(_ hex: String) {
        guard let color = Color(hexString: hex) else { return }
        let clean = String(hex.prefix(7))
        accent = color
        accentHex = clean
        syncedFromBlog = true
        UserDefaults.standard.set(clean, forKey: cacheKey)
    }

    private static func firstMatch(in text: String, pattern: String) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern) else { return nil }
        let ns = text as NSString
        guard let m = re.firstMatch(in: text, range: NSRange(location: 0, length: ns.length)),
              m.numberOfRanges > 1 else { return nil }
        return ns.substring(with: m.range(at: 1))
    }

    private static func fetchString(_ url: String) async -> String? {
        guard let u = URL(string: url) else { return nil }
        var req = URLRequest(url: u)
        req.timeoutInterval = 15
        guard let (data, resp) = try? await URLSession.shared.data(for: req),
              (resp as? HTTPURLResponse)?.statusCode == 200,
              let text = String(data: data, encoding: .utf8) else { return nil }
        return text
    }
}

extension Color {
    init?(hexString hex: String) {
        var value = hex.trimmingCharacters(in: .whitespaces)
        if value.hasPrefix("#") { value.removeFirst() }
        // 支持 #rgb / #rgba / #rrggbb / #rrggbbaa
        switch value.count {
        case 3, 4:
            let chars = value.map { String($0) }
            let expanded = chars.flatMap { [$0, $0] }.joined()
            value = expanded
        case 6, 8:
            break
        default:
            return nil
        }
        var rgba: UInt64 = 0
        guard Scanner(string: value).scanHexInt64(&rgba) else { return nil }
        let hasAlpha = value.count == 8
        let r, g, b, a: Double
        if hasAlpha {
            r = Double((rgba >> 24) & 0xFF) / 255
            g = Double((rgba >> 16) & 0xFF) / 255
            b = Double((rgba >> 8) & 0xFF) / 255
            a = Double(rgba & 0xFF) / 255
        } else {
            r = Double((rgba >> 16) & 0xFF) / 255
            g = Double((rgba >> 8) & 0xFF) / 255
            b = Double(rgba & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
