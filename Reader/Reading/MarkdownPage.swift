import SwiftUI
import WebKit

/// 正文渲染：markdown.js 转 HTML + Yohaku 风格排版 CSS + 深浅色自适应
struct MarkdownPage: UIViewRepresentable {
    let markdown: String
    @Binding var plainText: String

    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.configuration.userContentController.add(context.coordinator, name: "textReady")
        return wv
    }
    func updateUIView(_ wv: WKWebView, context: Context) {
        if context.coordinator.lastMarkdown != markdown {
            context.coordinator.lastMarkdown = markdown
            let html = Self.document(markdown: markdown)
            wv.loadHTMLString(html, baseURL: nil)
        }
    }
    func makeCoordinator() -> Coordinator { Coordinator($plainText) }

    class Coordinator: NSObject, WKScriptMessageHandler {
        var lastMarkdown: String?
        @Binding var plainText: String
        init(_ bind: Binding<String>) { _plainText = bind }
        func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "textReady", let t = message.body as? String { plainText = t }
        }
    }

    static func document(markdown: String) -> String {
        let md = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
        return """
        <!DOCTYPE html><html><head><meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
        <script>\(Self.markedJS)</script>
        <style>
          :root { --fg:#26301f; --dim:#5a6350; --code-bg:#f2efe5; --line:#dcd6c8; --accent:#3d6b35; }
          @media (prefers-color-scheme: dark) {
            :root { --fg:#e7ede6; --dim:#9aa79a; --code-bg:#1c241c; --line:#2a322a; --accent:#7ee787; }
          }
          * { box-sizing:border-box }
          body { margin:0; padding:20px 18px 60px; background:transparent;
                 font:17px/1.9 "PingFang SC","Songti SC",serif; color:var(--fg);
                 max-width:680px; margin:0 auto; word-break:break-word; }
          h1,h2,h3 { line-height:1.4; letter-spacing:-.01em; margin:1.6em 0 .6em; }
          h1 { font-size:1.6em } h2 { font-size:1.35em } h3 { font-size:1.15em }
          a { color:var(--accent) }
          img { max-width:100%; border-radius:10px; margin:14px 0 }
          code { font:13px/1.6 ui-monospace,Menlo,monospace; background:var(--code-bg);
                 padding:2px 6px; border-radius:5px }
          pre { background:var(--code-bg); padding:14px; border-radius:10px; overflow-x:auto }
          pre code { background:none; padding:0 }
          blockquote { margin:1.2em 0; padding:2px 16px; border-left:3px solid var(--accent);
                       color:var(--dim) }
          hr { border:none; border-top:1px solid var(--line); margin:2em 0 }
          table { border-collapse:collapse; width:100% } th,td { border:1px solid var(--line); padding:8px }
        </style></head><body>
        <div id="c"></div>
        <script>
          const src = `\(md)`;
          document.getElementById('c').innerHTML = marked.parse(src);
          setTimeout(() => webkit.messageHandlers.textReady.postMessage(document.body.innerText), 300);
        </script>
        </body></html>
        """
    }

    static let markedJS: String = {
        guard let url = Bundle.main.url(forResource: "marked.min", withExtension: "js"),
              let js = try? String(contentsOf: url, encoding: .utf8) else { return "" }
        return js
    }()
}
