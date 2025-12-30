import Foundation

/// Service for processing voice notes (transcription and summarization)
class ProcessingService {
    private let projectRoot: URL
    private let venvPython: URL
    private let notesService = AppleNotesService()

    init() {
        // Use hardcoded path to project root
        self.projectRoot = URL(fileURLWithPath: "/Users/Karthik/Documents/work/NotesAgent")

        self.venvPython = projectRoot
            .appendingPathComponent("venv")
            .appendingPathComponent("bin")
            .appendingPathComponent("python3")

        print("📁 Project root: \(projectRoot.path)")
        print("🐍 Python path: \(venvPython.path)")
    }

    /// Transcribe audio file using Whisper
    func transcribe(audioURL: URL) async throws -> String {
        let scriptPath = projectRoot
            .appendingPathComponent("scripts")
            .appendingPathComponent("transcribe.py")

        // Verify files exist before processing
        print("🔍 Checking file existence...")
        print("   Python: \(FileManager.default.fileExists(atPath: venvPython.path))")
        print("   Script: \(FileManager.default.fileExists(atPath: scriptPath.path))")
        print("   Audio:  \(FileManager.default.fileExists(atPath: audioURL.path))")

        if !FileManager.default.fileExists(atPath: audioURL.path) {
            print("❌ Audio file does not exist at: \(audioURL.path)")
            throw ProcessingError.transcriptionFailed
        }

        let process = Process()
        process.executableURL = venvPython
        process.arguments = [
            scriptPath.path,
            audioURL.path,
            "--model", "base"
        ]

        // Set up environment to ensure venv and ffmpeg work properly
        var environment = ProcessInfo.processInfo.environment
        environment["VIRTUAL_ENV"] = projectRoot.appendingPathComponent("venv").path
        // Include homebrew bin for ffmpeg, venv bin, and existing PATH
        environment["PATH"] = "/opt/homebrew/bin:\(projectRoot.appendingPathComponent("venv/bin").path):\(environment["PATH"] ?? "")"
        process.environment = environment

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        print("🎧 Running: \(venvPython.path) \(scriptPath.path) \(audioURL.path)")

        try process.run()
        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            print("⚠️  Transcription stderr: \(errorOutput)")
        }

        guard process.terminationStatus == 0 else {
            print("❌ Transcription failed with status: \(process.terminationStatus)")
            throw ProcessingError.transcriptionFailed
        }

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let transcription = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !transcription.isEmpty else {
            print("❌ No transcription output received")
            throw ProcessingError.invalidOutput
        }

        print("✅ Transcription: \(transcription.prefix(100))...")
        return transcription
    }

    /// Summarize transcribed text using Ollama
    func summarize(text: String, model: String = "mistral:latest") async throws -> String {
        let scriptPath = projectRoot
            .appendingPathComponent("scripts")
            .appendingPathComponent("summarize.py")

        let process = Process()
        process.executableURL = venvPython
        process.arguments = [
            scriptPath.path,
            text,
            "--model", model
        ]

        // Set up environment to ensure venv and ffmpeg work properly
        var environment = ProcessInfo.processInfo.environment
        environment["VIRTUAL_ENV"] = projectRoot.appendingPathComponent("venv").path
        // Include homebrew bin for ffmpeg, venv bin, and existing PATH
        environment["PATH"] = "/opt/homebrew/bin:\(projectRoot.appendingPathComponent("venv/bin").path):\(environment["PATH"] ?? "")"
        process.environment = environment

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        print("💬 Running summarization with model: \(model)")

        try process.run()
        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            print("⚠️  Summarization stderr: \(errorOutput)")
        }

        guard process.terminationStatus == 0 else {
            print("❌ Summarization failed with status: \(process.terminationStatus)")
            throw ProcessingError.summarizationFailed
        }

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let summary = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !summary.isEmpty else {
            print("❌ No summary output received")
            throw ProcessingError.invalidOutput
        }

        print("✅ Summary generated: \(summary.prefix(100))...")
        return summary
    }

    /// Process a voice note: transcribe and summarize
    func process(note: inout VoiceNote) async throws {
        // Step 1: Transcribe
        note.status = .transcribing
        let transcription = try await transcribe(audioURL: note.audioPath)
        note.transcription = transcription

        // Step 2: Summarize
        note.status = .summarizing
        let summary = try await summarize(text: transcription)
        note.summary = summary

        // Step 3: Save to Apple Notes
        note.status = .savingToNotes
        let noteTitle = "Voice Note - \(note.formattedDate)"
        try await notesService.createNote(
            title: noteTitle,
            summary: summary,
            transcription: transcription
        )

        // Complete
        note.status = .completed
        note.processedAt = Date()
    }
}

enum ProcessingError: LocalizedError {
    case transcriptionFailed
    case summarizationFailed
    case invalidOutput

    var errorDescription: String? {
        switch self {
        case .transcriptionFailed:
            return "Failed to transcribe audio"
        case .summarizationFailed:
            return "Failed to generate summary"
        case .invalidOutput:
            return "Invalid output from processing script"
        }
    }
}
