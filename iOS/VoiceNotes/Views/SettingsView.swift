import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var syncService: SyncService
    @EnvironmentObject var audioRecorder: AudioRecorderService
    @Environment(\.dismiss) var dismiss

    @AppStorage("serverHost") private var serverHost = ""
    @AppStorage("serverPort") private var serverPort = 8888

    @State private var tempHost = ""
    @State private var tempPort = 8888
    @State private var showingSyncAlert = false
    @State private var syncAlertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Server Configuration") {
                    TextField("Mac IP Address", text: $tempHost)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .keyboardType(.numbersAndPunctuation)

                    Stepper("Port: \(tempPort)", value: $tempPort, in: 1024...65535)

                    Button("Connect") {
                        connectToServer()
                    }
                    .disabled(tempHost.isEmpty)

                    HStack {
                        Text("Status:")
                        Spacer()
                        Text(syncService.isServerAvailable ? "Connected" : "Not Connected")
                            .foregroundColor(syncService.isServerAvailable ? .green : .secondary)
                    }
                }

                Section("Sync") {
                    Button("Sync All Recordings") {
                        syncAllRecordings()
                    }
                    .disabled(!syncService.isServerAvailable || audioRecorder.recordings.allSatisfy { $0.isSynced })

                    if let lastSync = syncService.lastSyncDate {
                        HStack {
                            Text("Last Sync:")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Text("Total Recordings")
                        Spacer()
                        Text("\(audioRecorder.recordings.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Synced")
                        Spacer()
                        Text("\(audioRecorder.recordings.filter { $0.isSynced }.count)")
                            .foregroundColor(.secondary)
                    }
                }

                Section("How to Find Mac IP") {
                    Text("On your Mac, open System Settings → Network, then note your IP address (e.g., 192.168.1.5)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Sync Status", isPresented: $showingSyncAlert) {
                Button("OK") {}
            } message: {
                Text(syncAlertMessage)
            }
        }
        .onAppear {
            tempHost = serverHost
            tempPort = serverPort
        }
    }

    private func connectToServer() {
        serverHost = tempHost
        serverPort = tempPort

        syncService.connect(to: tempHost, port: UInt16(tempPort))
    }

    private func syncAllRecordings() {
        Task {
            do {
                try await syncService.syncAll(recordings: audioRecorder.recordings)

                // Mark all as synced
                for recording in audioRecorder.recordings {
                    audioRecorder.markAsSynced(recording)
                }

                syncAlertMessage = "All recordings synced successfully!"
                showingSyncAlert = true

            } catch {
                syncAlertMessage = "Sync failed: \(error.localizedDescription)"
                showingSyncAlert = true
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SyncService())
        .environmentObject(AudioRecorderService())
}
