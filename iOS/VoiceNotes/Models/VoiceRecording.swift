import Foundation

/// Represents a voice recording on iOS
struct VoiceRecording: Identifiable, Codable {
    let id: String
    let filename: String
    let audioURL: URL
    let recordedAt: Date
    let duration: TimeInterval
    var isSynced: Bool

    init(id: String = UUID().uuidString,
         filename: String,
         audioURL: URL,
         recordedAt: Date = Date(),
         duration: TimeInterval,
         isSynced: Bool = false) {
        self.id = id
        self.filename = filename
        self.audioURL = audioURL
        self.recordedAt = recordedAt
        self.duration = duration
        self.isSynced = isSynced
    }

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

    /// Short date for filename
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: recordedAt)
    }
}
