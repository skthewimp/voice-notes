import Foundation
import Network

/// Service for syncing recordings to Mac server
class SyncService: ObservableObject {
    @Published var isServerAvailable = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?

    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.voicenotes.sync")
    private var serverEndpoint: NWEndpoint?

    /// Connect to server at specific IP
    func connect(to host: String, port: UInt16 = 8888) {
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(integerLiteral: port))
        serverEndpoint = endpoint

        let params = NWParameters.tcp
        let connection = NWConnection(to: endpoint, using: params)

        connection.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isServerAvailable = true
                    print("✅ Connected to server")
                case .failed(let error):
                    self?.isServerAvailable = false
                    print("❌ Connection failed: \(error)")
                case .cancelled:
                    self?.isServerAvailable = false
                    print("Connection cancelled")
                default:
                    break
                }
            }
        }

        connection.start(queue: queue)
        self.connection = connection
    }

    /// Sync recording to server
    func syncRecording(_ recording: VoiceRecording) async throws {
        guard let endpoint = serverEndpoint else {
            throw SyncError.notConnected
        }

        print("📤 Syncing: \(recording.filename)")

        DispatchQueue.main.async {
            self.isSyncing = true
        }

        defer {
            DispatchQueue.main.async {
                self.isSyncing = false
            }
        }

        // Read audio file
        guard let audioData = try? Data(contentsOf: recording.audioURL) else {
            print("❌ Failed to read file at: \(recording.audioURL.path)")
            throw SyncError.fileReadFailed
        }

        print("✅ Read \(audioData.count) bytes from file")

        // Create metadata
        let metadata: [String: String] = [
            "id": recording.id,
            "filename": recording.filename,
            "duration": String(recording.duration)
        ]

        // Create message
        let message = NetworkMessage(
            type: .audioUpload,
            payload: audioData,
            metadata: metadata
        )

        // Encode message
        guard let messageData = try? JSONEncoder().encode(message) else {
            throw SyncError.encodingFailed
        }

        // Prepend length prefix (4 bytes, UInt32)
        var lengthPrefix = UInt32(messageData.count)
        let lengthData = withUnsafeBytes(of: &lengthPrefix) { Data($0) }
        var fullMessage = lengthData
        fullMessage.append(messageData)

        print("📦 Sending \(fullMessage.count) bytes total")

        // Create fresh connection for this sync
        let params = NWParameters.tcp
        let syncConnection = NWConnection(to: endpoint, using: params)

        return try await withCheckedThrowingContinuation { continuation in
            syncConnection.stateUpdateHandler = { state in
                if case .ready = state {
                    // Connection ready, send data
                    syncConnection.send(content: fullMessage, completion: .contentProcessed { error in
                        if let error = error {
                            print("❌ Send failed: \(error)")
                            syncConnection.cancel()
                            continuation.resume(throwing: error)
                        } else {
                            print("✅ Send completed")
                            DispatchQueue.main.async {
                                self.lastSyncDate = Date()
                            }
                            syncConnection.cancel()
                            continuation.resume()
                        }
                    })
                } else if case .failed(let error) = state {
                    print("❌ Connection failed: \(error)")
                    continuation.resume(throwing: error)
                }
            }

            syncConnection.start(queue: queue)
        }
    }

    /// Sync all unsynced recordings
    func syncAll(recordings: [VoiceRecording]) async throws {
        let unsyncedRecordings = recordings.filter { !$0.isSynced }

        for recording in unsyncedRecordings {
            try await syncRecording(recording)
        }
    }

    /// Disconnect from server
    func disconnect() {
        connection?.cancel()
        connection = nil
        isServerAvailable = false
    }
}

enum SyncError: LocalizedError {
    case notConnected
    case fileReadFailed
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to server"
        case .fileReadFailed:
            return "Failed to read audio file"
        case .encodingFailed:
            return "Failed to encode message"
        }
    }
}
