import SwiftUI
import MarkdownUI

/// 余白阅读排版：衬线正文 + 绯红标题
extension Theme {
    static let yuBaiReading: Theme = Theme()
        .paragraph { conf in
            conf.label
                .lineSpacing(9)
                .padding(.vertical, 2)
        }
        .heading1 { conf in
            conf.label
                .font(YuBai.serif(21, .bold))
                .foregroundStyle(YuBai.accent)
                .padding(.top, 18)
        }
        .heading2 { conf in
            conf.label
                .font(YuBai.serif(19, .semibold))
                .foregroundStyle(YuBai.accent)
                .padding(.top, 16)
        }
        .heading3 { conf in
            conf.label
                .font(YuBai.serif(17, .semibold))
                .foregroundStyle(YuBai.ink)
                .padding(.top, 12)
        }
        .blockquote { conf in
            conf.label
                .font(YuBai.serifBody)
                .foregroundStyle(YuBai.dim)
                .padding(.leading, 14)
                .overlay(alignment: .leading) {
                    Rectangle().fill(YuBai.accent.opacity(0.7)).frame(width: 3)
                }
        }
        .codeBlock { conf in
            conf.label
                .font(.system(size: 13, design: .monospaced))
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(light: UIColor(red: 0.95, green: 0.93, blue: 0.89, alpha: 1),
                                  dark: UIColor(red: 0.13, green: 0.12, blue: 0.11, alpha: 1)))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
}
