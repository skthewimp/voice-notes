import SwiftUI

struct RecordingsListView: View {
    @EnvironmentObject var audioRecorder: AudioRecorderService
    @EnvironmentObject var syncService: SyncService

    var body: some View {
        List {
            if audioRecorder.recordings.isEmpty {
                ContentUnavailableView(
                    "No Recordings",
                    systemImage: "mic.slash",
                    description: Text("Start recording to see your voice notes here")
                )
            } else {
                ForEach(audioRecorder.recordings) { recording in
                    RecordingRow(recording: recording)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                audioRecorder.deleteRecording(recording)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            if syncService.isServerAvailable {
                                Button {
                                    Task {
                                        do {
                                            try await syncService.syncRecording(recording)
                                            audioRecorder.markAsSynced(recording)
                                        } catch {
                                            print("❌ Sync failed: \(error)")
                                        }
                                    }
                                } label: {
                                    Label(recording.isSynced ? "Re-Sync" : "Sync", systemImage: "arrow.up.circle")
                                }
                                .tint(.blue)
                            }
                        }
                }
            }
        }
    }
}

struct RecordingRow: View {
    let recording: VoiceRecording
    @EnvironmentObject var syncService: SyncService

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: recording.isSynced ? "checkmark.circle.fill" : "mic.circle.fill")
                .font(.title2)
                .foregroundColor(recording.isSynced ? .green : .blue)

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.filename)
                    .font(.headline)

                HStack {
                    Text(recording.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(recording.formattedDuration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Sync status
            if syncService.isSyncing {
                ProgressView()
            } else if syncService.isServerAvailable {
                Image(systemName: "arrow.up.circle")
                    .foregroundColor(.blue)
                    .opacity(recording.isSynced ? 0.5 : 1.0)
            } else if !recording.isSynced {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RecordingsListView()
            .environmentObject(AudioRecorderService())
            .environmentObject(SyncService())
    }
}
