import SwiftUI

struct ContentView: View {
    @EnvironmentObject var networkService: NetworkService
    @State private var selectedNote: VoiceNote?

    var body: some View {
        NavigationSplitView {
            // Sidebar: List of notes
            List(networkService.receivedNotes, selection: $selectedNote) { note in
                NoteListItem(note: note)
                    .tag(note)
            }
            .navigationTitle("Voice Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ServerStatusView(isRunning: networkService.isRunning)
                }
            }

        } detail: {
            // Detail: Selected note
            if let note = selectedNote {
                NoteDetailView(note: note)
            } else {
                EmptyStateView()
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct NoteListItem: View {
    let note: VoiceNote

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.filename)
                    .font(.headline)
                Spacer()
                StatusBadge(status: note.status)
            }

            HStack {
                Text(note.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("•")
                    .foregroundColor(.secondary)
                Text(note.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if note.status == .completed, let summary = note.summary?.components(separatedBy: "\n").first {
                Text(summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: VoiceNote.ProcessingStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var statusColor: Color {
        switch status {
        case .received: return .gray
        case .transcribing, .summarizing, .savingToNotes: return .orange
        case .completed: return .green
        case .failed: return .red
        }
    }

    private var statusText: String {
        switch status {
        case .received: return "Received"
        case .transcribing: return "Transcribing..."
        case .summarizing: return "Summarizing..."
        case .savingToNotes: return "Saving to Notes..."
        case .completed: return "Complete"
        case .failed: return "Failed"
        }
    }
}

struct ServerStatusView: View {
    let isRunning: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isRunning ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            Text(isRunning ? "Server Running" : "Server Stopped")
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("No Notes Yet")
                .font(.title2)
                .fontWeight(.medium)
            Text("Record a voice note on your iPhone to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(NetworkService())
}
