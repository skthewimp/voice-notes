import Foundation

/// Network protocol for syncing voice notes between iOS and macOS
struct NetworkProtocol {
    static let serviceType = "_voicenotes._tcp"
    static let serviceName = "VoiceNotesServer"
    static let port: UInt16 = 8888
}

/// Message types for communication
enum MessageType: String, Codable {
    case audioUpload = "audio_upload"
    case uploadComplete = "upload_complete"
    case processingStatus = "processing_status"
    case error = "error"
}

/// Message structure for network communication
struct NetworkMessage: Codable {
    let type: MessageType
    let payload: Data?
    let metadata: [String: String]?

    init(type: MessageType, payload: Data? = nil, metadata: [String: String]? = nil) {
        self.type = type
        self.payload = payload
        self.metadata = metadata
    }
}

/// Voice note metadata
struct VoiceNoteMetadata: Codable {
    let id: String
    let filename: String
    let duration: TimeInterval
    let recordedAt: Date
    let fileSize: Int

    init(id: String = UUID().uuidString,
         filename: String,
         duration: TimeInterval,
         recordedAt: Date = Date(),
         fileSize: Int) {
        self.id = id
        self.filename = filename
        self.duration = duration
        self.recordedAt = recordedAt
        self.fileSize = fileSize
    }
}
