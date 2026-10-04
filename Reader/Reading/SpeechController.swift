import AVFoundation

/// 文章朗读：AVSpeechSynthesizer zh-CN
final class SpeechController: NSObject, ObservableObject {
    static let shared = SpeechController()
    @Published var speaking = false
    private let synth = AVSpeechSynthesizer()

    func toggle(_ text: String) {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate)
        speaking = false
        return }
        let clean = text.prefix(8000)
        let u = AVSpeechUtterance(string: String(clean))
        u.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        u.rate = 0.5
        synth.speak(u)
        speaking = true
    }
}
