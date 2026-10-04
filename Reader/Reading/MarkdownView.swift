import SwiftUI
import MarkdownUI
import AVFoundation

/// 原生 Markdown 渲染（无 WebKit）+ 朗读
struct ArticleMarkdown: View {
    let markdown: String

    var body: some View {
        Markdown(markdown)
            .markdownTextStyle {
                FontSize(17)
            }
            .padding(.vertical, 4)
    }

    static func plainText(from md: String) -> String { Plain.text(from: md) }
}

@MainActor
final class SpeechController: ObservableObject {
    static let shared = SpeechController()
    @Published var speaking = false
    private let synth = AVSpeechSynthesizer()

    func toggle(_ text: String) {
        if synth.isSpeaking {
            synth.stopSpeaking(at: .immediate)
            speaking = false
            return
        }
        let u = AVSpeechUtterance(string: String(Plain.text(from: text).prefix(9000)))
        u.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        u.rate = 0.5
        synth.speak(u)
        speaking = true
    }
}
