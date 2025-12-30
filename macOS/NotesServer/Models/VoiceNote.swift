import Foundation

/// Represents a processed voice note with transcription and summary
struct VoiceNote: Identifiable, Codable, Hashable {
    let id: String
    let filename: String
    let audioPath: URL
    let recordedAt: Date
    let duration: TimeInterval

    var transcription: String?
    var summary: String?
    var processedAt: Date?

    enum ProcessingStatus: String, Codable {
        case received
        case transcribing
        case summarizing
        case savingToNotes
        case completed
        case failed
    }

    var status: ProcessingStatus

    init(id: String = UUID().uuidString,
         filename: String,
         audioPath: URL,
         recordedAt: Date,
         duration: TimeInterval,
         status: ProcessingStatus = .received) {
        self.id = id
        self.filename = filename
        self.audioPath = audioPath
        self.recordedAt = recordedAt
        self.duration = duration
        self.status = status
    }
}

extension VoiceNote {
    /// Format duration as MM:SS
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Format recorded date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: recordedAt)
    }
}
