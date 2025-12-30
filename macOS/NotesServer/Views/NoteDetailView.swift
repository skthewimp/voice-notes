import SwiftUI
import AVFoundation

struct NoteDetailView: View {
    let note: VoiceNote
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(note.filename)
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        StatusBadge(status: note.status)
                    }

                    HStack {
                        Label(note.formattedDate, systemImage: "calendar")
                        Spacer()
                        Label(note.formattedDuration, systemImage: "clock")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }

                Divider()

                // Audio Player
                VStack(spacing: 12) {
                    Text("Audio")
                        .font(.headline)

                    HStack {
                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 44))
                        }
                        .buttonStyle(.plain)
                        .disabled(note.status == .received)

                        Spacer()

                        Button("Open in Finder") {
                            NSWorkspace.shared.activateFileViewerSelecting([note.audioPath])
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Divider()

                // Summary
                if let summary = note.summary {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Summary")
                                .font(.headline)
                            Spacer()
                            Button(action: { copySummary(summary) }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.bordered)
                        }

                        Text(summary)
                            .font(.body)
                            .textSelection(.enabled)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }

                    Divider()
                }

                // Transcription
                if let transcription = note.transcription {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Full Transcription")
                                .font(.headline)
                            Spacer()
                            Button(action: { copyTranscription(transcription) }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.bordered)
                        }

                        Text(transcription)
                            .font(.body)
                            .textSelection(.enabled)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // Processing status
                if note.status == .transcribing || note.status == .summarizing || note.status == .savingToNotes {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text(statusMessage(for: note.status))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                if note.status == .failed {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Processing failed")
                            .foregroundColor(.red)
                    }
                    .padding()
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func statusMessage(for status: VoiceNote.ProcessingStatus) -> String {
        switch status {
        case .transcribing: return "Transcribing audio..."
        case .summarizing: return "Generating summary..."
        case .savingToNotes: return "Saving to Apple Notes..."
        default: return ""
        }
    }

    private func togglePlayback() {
        if let player = audioPlayer, player.isPlaying {
            player.pause()
            isPlaying = false
        } else if let player = audioPlayer {
            player.play()
            isPlaying = true
        } else {
            // Initialize player
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: note.audioPath)
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
    }

    private func copySummary(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func copyTranscription(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

#Preview {
    NoteDetailView(note: VoiceNote(
        filename: "Note 2024-01-15.m4a",
        audioPath: URL(fileURLWithPath: "/tmp/test.m4a"),
        recordedAt: Date(),
        duration: 125,
        status: .completed
    ))
}
