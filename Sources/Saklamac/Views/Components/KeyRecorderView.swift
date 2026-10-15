import SwiftUI
import AppKit

public final class KeyRecorderState: ObservableObject {
    @Published public var isRecording = false
    public var localMonitor: Any?

    public init() {}

    public func stopRecording() {
        isRecording = false
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    deinit {
        stopRecording()
    }
}

public struct KeyRecorderView: View {
    @Binding var keyCombo: KeyCombo?
    @StateObject private var recorder = KeyRecorderState()

    public init(keyCombo: Binding<KeyCombo?>) {
        self._keyCombo = keyCombo
    }

    public var body: some View {
        HStack(spacing: 8) {
            Button(action: toggleRecording) {
                HStack(spacing: 6) {
                    if recorder.isRecording {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("Type Shortcut...")
                            .foregroundColor(.primary)
                            .font(.system(size: 13, weight: .medium))
                    } else if let combo = keyCombo {
                        Text(combo.displayString)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    } else {
                        Text("Click to Record")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(recorder.isRecording ? Color.accentColor.opacity(0.15) : Color(NSColor.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(recorder.isRecording ? Color.accentColor : Color(NSColor.separatorColor), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            if keyCombo != nil {
                Button(action: {
                    keyCombo = nil
                    recorder.stopRecording()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("Clear shortcut")
            }
        }
        .onDisappear {
            recorder.stopRecording()
        }
    }

    private func toggleRecording() {
        if recorder.isRecording {
            recorder.stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        recorder.isRecording = true

        recorder.localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak recorder] event in
            guard let recorder = recorder else { return event }

            // Handle Escape to cancel
            if event.keyCode == 53 { // ESC
                recorder.stopRecording()
                return nil
            }

            // Handle Delete/Backspace to clear
            if event.keyCode == 51 && event.modifierFlags.intersection([.command, .option, .control, .shift]).isEmpty {
                self.keyCombo = nil
                recorder.stopRecording()
                return nil
            }

            let flags = event.modifierFlags
            let carbonMods = KeyCombo.carbonModifiers(from: flags)

            // Must contain at least one modifier
            if carbonMods != 0 {
                self.keyCombo = KeyCombo(keyCode: UInt32(event.keyCode), modifiers: carbonMods)
                recorder.stopRecording()
                return nil
            }

            return event
        }
    }
}
