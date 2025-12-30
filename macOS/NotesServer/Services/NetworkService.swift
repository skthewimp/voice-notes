import Foundation
import Network

/// Network service for receiving voice notes from iOS devices
class NetworkService: ObservableObject {
    @Published var isRunning = false
    @Published var receivedNotes: [VoiceNote] = []

    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.voicenotes.server")
    private let processingService = ProcessingService()
    private let storageURL: URL

    init() {
        // Create storage directory for received audio files
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.storageURL = documentsPath.appendingPathComponent("VoiceNotes")
        try? FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
    }

    /// Start the network listener
    func start() {
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true

            let listener = try NWListener(using: params, on: NWEndpoint.Port(integerLiteral: NetworkProtocol.port))

            listener.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async {
                    switch state {
                    case .ready:
                        self?.isRunning = true
                        print("✅ Server listening on port \(NetworkProtocol.port)")
                    case .failed(let error):
                        self?.isRunning = false
                        print("❌ Server failed: \(error)")
                    case .cancelled:
                        self?.isRunning = false
                        print("⏹ Server stopped")
                    default:
                        break
                    }
                }
            }

            listener.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }

            listener.start(queue: queue)
            self.listener = listener

        } catch {
            print("❌ Failed to start server: \(error)")
        }
    }

    /// Stop the network listener
    func stop() {
        listener?.cancel()
        listener = nil
    }

    /// Handle incoming connection
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)

        receiveMessage(on: connection)
    }

    /// Receive message from connection
    private func receiveMessage(on connection: NWConnection) {
        // First, receive the 4-byte length prefix
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] lengthData, _, isComplete, error in
            guard let lengthData = lengthData, lengthData.count == 4 else {
                if !isComplete && error == nil {
                    self?.receiveMessage(on: connection)
                } else {
                    connection.cancel()
                }
                return
            }

            // Extract message length
            let messageLength = lengthData.withUnsafeBytes { $0.load(as: UInt32.self) }

            // Now receive the actual message
            connection.receive(minimumIncompleteLength: Int(messageLength), maximumLength: Int(messageLength)) { data, _, isComplete, error in
                if let data = data, !data.isEmpty {
                    self?.handleReceivedData(data, on: connection)
                }

                if isComplete {
                    connection.cancel()
                } else if error == nil {
                    self?.receiveMessage(on: connection)
                }
            }
        }
    }

    /// Handle received data
    private func handleReceivedData(_ data: Data, on connection: NWConnection) {
        do {
            let decoder = JSONDecoder()
            let message = try decoder.decode(NetworkMessage.self, from: data)

            switch message.type {
            case .audioUpload:
                guard let audioData = message.payload,
                      let metadata = message.metadata,
                      let filename = metadata["filename"],
                      let durationStr = metadata["duration"],
                      let duration = TimeInterval(durationStr) else {
                    sendError("Invalid audio upload data", on: connection)
                    return
                }

                // Save audio file
                let audioURL = storageURL.appendingPathComponent(filename)
                try audioData.write(to: audioURL)

                // Create voice note
                var note = VoiceNote(
                    id: metadata["id"] ?? UUID().uuidString,
                    filename: filename,
                    audioPath: audioURL,
                    recordedAt: Date(),
                    duration: duration,
                    status: .received
                )

                // Add to list
                DispatchQueue.main.async {
                    self.receivedNotes.append(note)
                }

                // Send confirmation
                sendConfirmation(on: connection)

                // Process in background
                Task {
                    do {
                        try await processingService.process(note: &note)
                        DispatchQueue.main.async {
                            if let index = self.receivedNotes.firstIndex(where: { $0.id == note.id }) {
                                self.receivedNotes[index] = note
                            }
                        }
                        print("✅ Processed note: \(note.filename)")
                    } catch {
                        print("❌ Processing failed: \(error)")
                        note.status = .failed
                        DispatchQueue.main.async {
                            if let index = self.receivedNotes.firstIndex(where: { $0.id == note.id }) {
                                self.receivedNotes[index] = note
                            }
                        }
                    }
                }

            default:
                print("Received message type: \(message.type)")
            }

        } catch {
            print("❌ Failed to decode message: \(error)")
        }
    }

    /// Send confirmation message
    private func sendConfirmation(on connection: NWConnection) {
        let message = NetworkMessage(type: .uploadComplete)
        if let messageData = try? JSONEncoder().encode(message) {
            var lengthPrefix = UInt32(messageData.count)
            let lengthData = withUnsafeBytes(of: &lengthPrefix) { Data($0) }
            var fullMessage = lengthData
            fullMessage.append(messageData)
            connection.send(content: fullMessage, completion: .contentProcessed { _ in })
        }
    }

    /// Send error message
    private func sendError(_ errorMessage: String, on connection: NWConnection) {
        let message = NetworkMessage(
            type: .error,
            metadata: ["error": errorMessage]
        )
        if let messageData = try? JSONEncoder().encode(message) {
            var lengthPrefix = UInt32(messageData.count)
            let lengthData = withUnsafeBytes(of: &lengthPrefix) { Data($0) }
            var fullMessage = lengthData
            fullMessage.append(messageData)
            connection.send(content: fullMessage, completion: .contentProcessed { _ in })
        }
    }
}
