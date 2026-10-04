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
    static let accent   = Color(light: UIColor(red: 0.878, green: 0.584, blue: 0.643, alpha: 1),  // #e095a4
                                dark:  UIColor(red: 0.878, green: 0.584, blue: 0.643, alpha: 1))
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
