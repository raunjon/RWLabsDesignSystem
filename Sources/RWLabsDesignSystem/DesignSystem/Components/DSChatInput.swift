//
//  DSChatInput.swift
//  RWLabsDesignSystem
//
//  Chat typing field matching the Figma "Chat typing field":
//    Empty / Filled   attach, text field with emoji, mic, send (send turns coral once there is text)
//    Voice recording  attach, delete, coral panel with timer and live waveform, coral mic, send
//    Voice recorded   attach, delete, gray panel with play, waveform and length, mic, send
//
//  The app owns recording; it passes the state in and reacts to the actions:
//
//  DSChatInput(text: $draft, voiceState: recorder.state,
//              actions: .init(onAttach: pickPhoto, onMic: recorder.toggle,
//                             onDeleteRecording: recorder.discard, onPlayRecording: recorder.play)) {
//      send()
//  }
//

import SwiftUI

// MARK: - Voice State
public enum DSChatVoiceState: Equatable, Sendable {
    case idle
    /// `levels` are recent input levels, 0…1, oldest first.
    case recording(duration: TimeInterval, levels: [CGFloat] = [])
    case recorded(duration: TimeInterval, levels: [CGFloat] = [])
}

// MARK: - Actions
public struct DSChatInputActions {
    public var onAttach: () -> Void
    public var onEmoji: () -> Void
    public var onMic: () -> Void
    public var onDeleteRecording: () -> Void
    public var onPlayRecording: () -> Void

    public init(
        onAttach: @escaping () -> Void = {},
        onEmoji: @escaping () -> Void = {},
        onMic: @escaping () -> Void = {},
        onDeleteRecording: @escaping () -> Void = {},
        onPlayRecording: @escaping () -> Void = {}
    ) {
        self.onAttach = onAttach
        self.onEmoji = onEmoji
        self.onMic = onMic
        self.onDeleteRecording = onDeleteRecording
        self.onPlayRecording = onPlayRecording
    }
}

// MARK: - Chat Input
public struct DSChatInput: View {
    @Binding var text: String
    let voiceState: DSChatVoiceState
    let placeholder: String
    let actions: DSChatInputActions
    let onSend: () -> Void

    /// - Parameter onSend: Called for text, and for a finished recording.
    public init(
        text: Binding<String>,
        voiceState: DSChatVoiceState = .idle,
        placeholder: String = "Message",
        actions: DSChatInputActions = .init(),
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.voiceState = voiceState
        self.placeholder = placeholder
        self.actions = actions
        self.onSend = onSend
    }

    private var hasText: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    public var body: some View {
        HStack(spacing: .xs) {
            DSChatRoundButton(systemImage: "paperclip", label: "Attach", action: actions.onAttach)

            switch voiceState {
            case .idle:
                textField
                DSChatRoundButton(systemImage: "mic", label: "Record voice message", action: actions.onMic)
                DSChatRoundButton(systemImage: "paperplane", label: "Send", isActive: hasText, action: onSend)
                    .disabled(!hasText)

            case let .recording(duration, levels):
                DSChatRoundButton(systemImage: "trash", label: "Delete recording",
                                  fill: .Chat.recordingFill, tint: .Chat.recordingAccent,
                                  action: actions.onDeleteRecording)
                voicePanel(fill: .Chat.recordingFill, spacing: .sm) {
                    Text(Self.format(duration))
                        .fontStyle(.label)
                        .monospacedDigit()
                        .foregroundColor(.Chat.recordingAccent)
                    DSVoiceWaveform(levels: levels, color: .Chat.recordingAccent)
                }
                DSChatRoundButton(systemImage: "mic", label: "Stop recording", isActive: true, action: actions.onMic)
                DSChatRoundButton(systemImage: "paperplane", label: "Send", action: onSend)

            case let .recorded(duration, levels):
                DSChatRoundButton(systemImage: "trash", label: "Delete recording", action: actions.onDeleteRecording)
                voicePanel(fill: .Chat.surface, spacing: .xs) {
                    Button(action: actions.onPlayRecording) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.Chat.icon)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Play recording")
                    DSVoiceWaveform(levels: levels, color: .Chat.waveform)
                    Text(Self.format(duration))
                        .fontStyle(.label)
                        .monospacedDigit()
                        .foregroundColor(.Chat.recordedTime)
                }
                DSChatRoundButton(systemImage: "mic", label: "Record again", action: actions.onMic)
                DSChatRoundButton(systemImage: "paperplane", label: "Send", action: onSend)
            }
        }
        .padding(.horizontal, .md)
        .padding(.top, 13)
        .padding(.bottom, .xs)
        .background(Color.Chat.bar.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle().fill(Color.Chat.barBorder).frame(height: .thin)
        }
        .animation(.easeInOut(duration: 0.2), value: voiceState)
        .animation(.easeInOut(duration: 0.15), value: hasText)
    }

    private var textField: some View {
        HStack(spacing: 6) {
            TextField(placeholder, text: $text, axis: .vertical)
                .fontStyle(.bodySmall)
                .foregroundColor(.Chat.inputText)
                .tint(.Chat.activeFill)
                .lineLimit(1...4)
            Button(action: actions.onEmoji) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 20))
                    .foregroundColor(.Chat.icon)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Emoji")
        }
        .padding(.horizontal, .sm)
        .padding(.vertical, .xs)
        .frame(minHeight: 52)
        .background(RoundedRectangle(cornerRadius: .radiusLG).fill(Color.Chat.surface))
    }

    private func voicePanel<Content: View>(fill: Color, spacing: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: spacing) { content() }
            .padding(.horizontal, .sm)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: .radiusLG).fill(fill))
    }

    static func format(_ duration: TimeInterval) -> String {
        let seconds = max(0, Int(duration.rounded(.down)))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Round Button
/// The 42pt circular control used throughout the typing field.
struct DSChatRoundButton: View {
    let systemImage: String
    let label: String
    var isActive = false
    var fill: Color = .Chat.surface
    var tint: Color = .Chat.icon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundColor(isActive ? .Chat.activeIcon : tint)
                .frame(width: 42, height: 42)
                .background(Circle().fill(isActive ? Color.Chat.activeFill : fill))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

// MARK: - Waveform
/// 3pt bars with 1pt gaps, scaled to the panel's 28pt height. Without levels it draws a fixed pattern.
public struct DSVoiceWaveform: View {
    let levels: [CGFloat]
    let color: Color

    /// Bar heights from the Figma sheet, as a share of 28pt.
    static let placeholderLevels: [CGFloat] = [8, 14, 20, 12, 18, 24, 16, 10, 22, 14, 18, 12, 20, 8, 16, 14, 10, 22, 18, 12]
        .map { $0 / 28 }

    public init(levels: [CGFloat] = [], color: Color) {
        self.levels = levels
        self.color = color
    }

    public var body: some View {
        GeometryReader { geometry in
            let shown = Self.fit(levels.isEmpty ? Self.placeholderLevels : levels, width: geometry.size.width)
            HStack(spacing: 1) {
                ForEach(shown.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: 3, height: max(4, min(1, shown[index]) * geometry.size.height))
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 28)
        .accessibilityHidden(true)
    }

    /// The newest levels that fit the width.
    private static func fit(_ levels: [CGFloat], width: CGFloat) -> [CGFloat] {
        let capacity = max(1, Int((width + 1) / 4))
        return Array(levels.suffix(capacity))
    }
}

// MARK: - Preview
/// Mirrors the Figma Chat typing field sheet (Empty, Filled, Voice recording, Voice recorded).
private struct DSChatInputGallery: View {
    @State private var empty = ""
    @State private var filled = "This is a test message"

    var body: some View {
        VStack(spacing: .xl) {
            DSChatInput(text: $empty) {}
            DSChatInput(text: $filled) {}
            DSChatInput(text: $empty, voiceState: .recording(duration: 18)) {}
            DSChatInput(text: $empty, voiceState: .recorded(duration: 39)) {}
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChatInputGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChatInputGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSChatInputGallery().designSystem()
}
