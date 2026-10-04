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
    /// markdown 首行图片剔除后的摘要
    static func excerpt(from md: String, limit: Int = 80) -> String {
        let t = text(from: md).replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)
        return t.count > limit ? String(t.prefix(limit)) + "…" : t
    }
}
