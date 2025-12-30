import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioRecorder: AudioRecorderService
    @EnvironmentObject var syncService: SyncService
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Recording interface
                RecordingView()
                    .frame(maxHeight: 300)

                Divider()

                // Recordings list
                RecordingsListView()
            }
            .navigationTitle("Voice Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    ConnectionStatusView()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

struct ConnectionStatusView: View {
    @EnvironmentObject var syncService: SyncService

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(syncService.isServerAvailable ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text(syncService.isServerAvailable ? "Connected" : "Offline")
                .font(.caption)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioRecorderService())
        .environmentObject(SyncService())
}
