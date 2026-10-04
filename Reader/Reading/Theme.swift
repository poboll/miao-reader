import SwiftUI

/// 余白风格设计令牌：暖纸 + 绯红 + 衬线（深浅色自适应）
enum YuBai {
    static let paper    = Color(light: UIColor(red: 0.97, green: 0.95, blue: 0.92, alpha: 1),
                                dark:  UIColor(red: 0.09, green: 0.08, blue: 0.07, alpha: 1))
    static let card     = Color(light: UIColor(red: 1.00, green: 0.99, blue: 0.97, alpha: 1),
                                dark:  UIColor(red: 0.14, green: 0.12, blue: 0.11, alpha: 1))
    static let ink      = Color(light: UIColor(red: 0.17, green: 0.15, blue: 0.13, alpha: 1),
                                dark:  UIColor(red: 0.91, green: 0.89, blue: 0.85, alpha: 1))
    static let dim      = Color(light: UIColor(red: 0.54, green: 0.51, blue: 0.47, alpha: 1),
                                dark:  UIColor(red: 0.60, green: 0.57, blue: 0.51, alpha: 1))
    static let accent   = Color(light: UIColor(red: 0.65, green: 0.25, blue: 0.18, alpha: 1),
                                dark:  UIColor(red: 0.84, green: 0.49, blue: 0.38, alpha: 1))
    static let hairline = Color(light: UIColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1),
                                dark:  UIColor(red: 0.23, green: 0.21, blue: 0.19, alpha: 1))

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

/// 通用页面背景（暖纸色）
struct PaperBackground: View {
    var body: some View {
        YuBai.paper.ignoresSafeArea()
    }
}
