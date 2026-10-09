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

/// 朗读控制器：播放 / 暂停 / 继续 / 停止 + 语速档位（对标 Yohaku App 的 TTS）
@MainActor
final class SpeechController: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    enum State { case idle, speaking, paused }

    static let shared = SpeechController()
    static let rates: [Double] = [0.75, 1, 1.25, 1.5, 2]

    @Published private(set) var state: State = .idle
    @Published var rate: Double = 1

    private let synth = AVSpeechSynthesizer()
    private var currentRaw: String?

    private override init() {
        super.init()
        synth.delegate = self
    }

    var isActive: Bool { state != .idle }

    func toggle(_ raw: String) {
        switch state {
        case .idle:
            start(raw)
        case .speaking:
            synth.pauseSpeaking(at: .word)
            state = .paused
        case .paused:
            synth.continueSpeaking()
            state = .speaking
        }
    }

    func start(_ raw: String) {
        synth.stopSpeaking(at: .immediate)
        currentRaw = raw
        let text = String(Plain.speech(from: raw).prefix(12000))
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        u.rate = Float(min(max(0.5 * rate, 0.05), 0.95))
        synth.speak(u)
        state = .speaking
    }

    func stop() {
        synth.stopSpeaking(at: .immediate)
        state = .idle
    }

    func setRate(_ factor: Double) {
        rate = factor
        // 语速已合成进语句，变更需重启；暂停态改语速 = 以新语速从头朗读
        if state != .idle, let raw = currentRaw {
            start(raw)
        }
    }

    var rateLabel: String {
        rate == floor(rate) ? "\(Int(rate))×" : "\(rate)×"
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.state = .idle }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            if self.state != .paused { self.state = .idle }
        }
    }
}

/// 朗读迷你条：朗读/暂停时悬浮在底部（对标 Yohaku tts-mini-bar）
struct SpeechMiniBar: View {
    let text: String
    @EnvironmentObject private var theme: ThemeStore
    @ObservedObject private var speech = SpeechController.shared

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: speech.state == .paused ? "pause.circle.fill" : "waveform")
                .font(.title3)
                .foregroundStyle(theme.accent)
                .symbolRenderingMode(.hierarchical)
            VStack(alignment: .leading, spacing: 1) {
                Text(speech.state == .paused ? "朗读已暂停" : "正在朗读")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(YuBai.ink)
                Text("语速 \(speech.rateLabel)")
                    .font(.caption2)
                    .foregroundStyle(YuBai.dim)
            }
            Spacer()
            Button {
                speech.toggle(text)
            } label: {
                Image(systemName: speech.state == .paused ? "play.fill" : "pause.fill")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.accent)
            Button {
                speech.stop()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(YuBai.dim)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(YuBai.hairline, lineWidth: 1))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
}
