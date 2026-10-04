import Foundation

struct Envelope<T: Decodable>: Decodable { let data: T }

struct Category: Decodable, Hashable { let id: String; let name: String; let slug: String? }

/// 列表条目：不解码正文，控制内存
struct PostItem: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let slug: String?
    let summary: String?
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

enum Plain {
    /// markdown → 朗读用纯文本
    static func text(from md: String) -> String {
        md.replacingOccurrences(of: #"!\[[^\]]*\]\([^)]*\)"#, with: "", options: .regularExpression)
          .replacingOccurrences(of: #"\[([^\]]*)\]\([^)]*\)"#, with: "$1", options: .regularExpression)
          .replacingOccurrences(of: #"[`#>]"#, with: "", options: .regularExpression)
    }
}
