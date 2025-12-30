import SwiftUI

@main
struct NotesServerApp: App {
    @StateObject private var networkService = NetworkService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkService)
                .onAppear {
                    networkService.start()
                }
                .onDisappear {
                    networkService.stop()
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
