import SwiftUI

struct RecordingView: View {
    @EnvironmentObject var audioRecorder: AudioRecorderService
    @State private var permissionGranted = false
    @State private var showPermissionAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Duration display
            if audioRecorder.isRecording {
                Text(formatDuration(audioRecorder.recordingDuration))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(.red)
            } else {
                Text("Ready to Record")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }

            // Record button
            Button(action: handleRecordButtonTap) {
                ZStack {
                    Circle()
                        .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                        .frame(width: 120, height: 120)
                        .shadow(radius: 10)

                    if audioRecorder.isRecording {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                    } else {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(audioRecorder.isRecording ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: audioRecorder.isRecording)

            Text(audioRecorder.isRecording ? "Tap to Stop" : "Tap to Record")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .alert("Microphone Access Required", isPresented: $showPermissionAlert) {
            Button("OK") {}
        } message: {
            Text("Please grant microphone access in Settings to record voice notes.")
        }
    }

    private func handleRecordButtonTap() {
        if audioRecorder.isRecording {
            audioRecorder.stopRecording()
        } else {
            Task {
                if !permissionGranted {
                    permissionGranted = await audioRecorder.requestPermission()
                }

                if permissionGranted {
                    audioRecorder.startRecording()
                } else {
                    showPermissionAlert = true
                }
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}

#Preview {
    RecordingView()
        .environmentObject(AudioRecorderService())
}
