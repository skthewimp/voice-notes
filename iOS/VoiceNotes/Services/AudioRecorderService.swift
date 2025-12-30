import Foundation
import AVFoundation
import SwiftUI

/// Service for recording audio on iOS
class AudioRecorderService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordings: [VoiceRecording] = []
    @Published var recordingDuration: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private let recordingsDirectory: URL

    override init() {
        // Set up recordings directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.recordingsDirectory = documentsPath.appendingPathComponent("Recordings")

        super.init()

        // Create directory if needed
        try? FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)

        // Load existing recordings
        loadRecordings()
    }

    /// Request microphone permission
    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    /// Start recording
    func startRecording() {
        // Set up audio session
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            // Create filename
            let filename = "Note-\(Date().timeIntervalSince1970).m4a"
            let audioURL = recordingsDirectory.appendingPathComponent(filename)

            // Recording settings
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            // Create recorder
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            isRecording = true
            recordingDuration = 0

            // Start timer to update duration
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateDuration()
            }

        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    /// Stop recording
    func stopRecording() {
        guard let recorder = audioRecorder else { return }

        recorder.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil

        isRecording = false

        // Create VoiceRecording object
        let recording = VoiceRecording(
            filename: recorder.url.lastPathComponent,
            audioURL: recorder.url,
            recordedAt: Date(),
            duration: recordingDuration,
            isSynced: false
        )

        recordings.insert(recording, at: 0)
        saveRecordings()

        // Reset audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    /// Delete recording
    func deleteRecording(_ recording: VoiceRecording) {
        // Delete file
        try? FileManager.default.removeItem(at: recording.audioURL)

        // Remove from list
        recordings.removeAll { $0.id == recording.id }
        saveRecordings()
    }

    /// Mark recording as synced
    func markAsSynced(_ recording: VoiceRecording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index].isSynced = true
            saveRecordings()
        }
    }

    private func updateDuration() {
        guard let recorder = audioRecorder else { return }
        recordingDuration = recorder.currentTime
    }

    private func loadRecordings() {
        let metadataURL = recordingsDirectory.appendingPathComponent("recordings.json")

        guard let data = try? Data(contentsOf: metadataURL) else { return }
        let loadedRecordings = (try? JSONDecoder().decode([VoiceRecording].self, from: data)) ?? []

        // Fix URLs by reconstructing them from filenames
        recordings = loadedRecordings.map { recording in
            let correctURL = recordingsDirectory.appendingPathComponent(recording.filename)
            return VoiceRecording(
                id: recording.id,
                filename: recording.filename,
                audioURL: correctURL,
                recordedAt: recording.recordedAt,
                duration: recording.duration,
                isSynced: recording.isSynced
            )
        }
    }

    private func saveRecordings() {
        let metadataURL = recordingsDirectory.appendingPathComponent("recordings.json")
        if let data = try? JSONEncoder().encode(recordings) {
            try? data.write(to: metadataURL)
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorderService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}
