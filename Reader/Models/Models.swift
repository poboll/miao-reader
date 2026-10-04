import Foundation

struct Envelope<T: Decodable>: Decodable { let data: T }

struct Category: Decodable, Hashable { let id: String; let name: String; let slug: String? }

struct Post: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let slug: String?
    let summary: String?
    let text: String?
    let category: Category?
    let tags: [String]?
    let images: [String]?
    let created_at: String?
    let modified_at: String?
    var coverImage: String? { images?.first }
}

struct Note: Decodable, Identifiable, Hashable {
    let id: String
    let nid: Int
    let title: String?
    let text: String?
    let mood: String?
    let weather: String?
    let location: String?
    let created_at: String?
    let public_at: String?
    let images: [String]?
}
