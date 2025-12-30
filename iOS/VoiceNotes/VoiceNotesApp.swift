import SwiftUI

@main
struct VoiceNotesApp: App {
    @StateObject private var audioRecorder = AudioRecorderService()
    @StateObject private var syncService = SyncService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioRecorder)
                .environmentObject(syncService)
        }
    }
}
