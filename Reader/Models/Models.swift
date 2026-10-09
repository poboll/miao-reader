import Foundation

struct Envelope<T: Decodable>: Decodable { let data: T }

struct Category: Decodable, Hashable { let id: String; let name: String; let slug: String? }

/// 列表条目：不带正文
struct PostItem: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let slug: String?
    let summary: String?
    let images: [String]?
    let category: Category?
    let created_at: String?
}

/// 详情：全文
struct PostDetail: Decodable, Hashable {
    let id: String
    let title: String
    let text: String?
    let category: Category?
    let created_at: String?
}

struct Note: Decodable, Identifiable, Hashable {
    let id: String
    let nid: Int
    let title: String?
    let text: String?
    let mood: String?
    let weather: String?
    let created_at: String?
    let public_at: String?
}

/// 思考流（recently）
struct Thought: Decodable, Identifiable, Hashable {
    let id: String
    let content: String?
    let created_at: String?
}

enum Plain {
    static func text(from md: String) -> String {
        md.replacingOccurrences(of: #"!\[[^\]]*\]\([^)]*\)"#, with: "", options: .regularExpression)
          .replacingOccurrences(of: #"\[([^\]]*)\]\([^)]*\)"#, with: "$1", options: .regularExpression)
          .replacingOccurrences(of: #"[`#>]"#, with: "", options: .regularExpression)
    }

    /// 朗读专用：比 text() 更干净——去代码块/表格/分割线/脚注/加粗斜体记号，
    /// 并把连续空行压成一句一停顿的节奏
    static func speech(from md: String) -> String {
        var t = md
        // 代码块、表格、front-matter 整段去掉
        t = t.replacingOccurrences(of: #"(?s)```.*?```"#, with: "（代码）", options: .regularExpression)
        t = t.replacingOccurrences(of: #"(?m)^\|.*\|\??$"#, with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: #"(?s)^---\n.*?---\n"#, with: "", options: .regularExpression)
        // 图片、链接、脚注、HTML
        t = t.replacingOccurrences(of: #"!\[[^\]]*\]\([^)]*\)"#, with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: #"\[([^\]]*)\]\([^)]*\)"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
        // 行内记号
        t = t.replacingOccurrences(of: #"[*_~]{1,3}([^*_~]+)[*_~]{1,3}"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"[`#>]"#, with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: #"^-{3,}\s*$"#, with: "", options: .regularExpression, range: nil)
        return t
    }
    /// markdown 首行图片剔除后的摘要
    static func excerpt(from md: String, limit: Int = 80) -> String {
        let t = text(from: md).replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)
        guard t.count > limit else { return t }
        // 截断后吞掉句末标点再加省略号，避免「。 …」打架
        let head = String(t.prefix(limit)).trimmingCharacters(in: .whitespaces)
        let cleaned = head.replacingOccurrences(of: #"[。，；、,.!?！？…：\s]+$"#, with: "", options: .regularExpression)
        return cleaned + "…"
    }
}
