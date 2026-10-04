import Foundation

enum Api {
    static var base = URL(string: "https://kami.caiths.com/api/v3")!

    static func get<T: Decodable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        var comps = URLComponents(url: base.appending(path: path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            comps.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        var req = URLRequest(url: comps.url!)
        req.timeoutInterval = 20
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(Envelope<T>.self, from: data).data
    }
}

extension DateFormatter {
    static let api: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    static let display: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()
    static func display(_ iso: String?) -> String {
        guard let iso, let d = api.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return "" }
        return display.string(from: d)
    }
}
