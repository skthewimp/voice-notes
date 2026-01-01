import Foundation

/// Service for processing voice notes (transcription and summarization)
class ProcessingService {
    private let projectRoot: URL
    private let venvPython: URL
    private let notesService = AppleNotesService()

    init() {
        // IMPORTANT: Update this path to match where you cloned the repository
        // You can also set the VOICE_NOTES_ROOT environment variable
        if let envRoot = ProcessInfo.processInfo.environment["VOICE_NOTES_ROOT"] {
            self.projectRoot = URL(fileURLWithPath: envRoot)
        } else {
            // For current user setup
            self.projectRoot = URL(fileURLWithPath: "/Users/Karthik/Documents/work/NotesAgent")
        }

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
            "--model", "small"  // Upgraded from "base" for better accuracy
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

    /// Generate a concise title from transcribed text using Ollama
    func generateTitle(text: String, model: String = "mistral:latest") async throws -> String {
        let scriptPath = projectRoot
            .appendingPathComponent("scripts")
            .appendingPathComponent("generate_title.py")

        let process = Process()
        process.executableURL = venvPython
        process.arguments = [
            scriptPath.path,
            text,
            "--model", model
        ]

        // Set up environment to ensure venv and ollama work properly
        var environment = ProcessInfo.processInfo.environment
        environment["VIRTUAL_ENV"] = projectRoot.appendingPathComponent("venv").path
        // Include homebrew bin for ollama, venv bin, and existing PATH
        environment["PATH"] = "/opt/homebrew/bin:\(projectRoot.appendingPathComponent("venv/bin").path):\(environment["PATH"] ?? "")"
        process.environment = environment

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        print("📝 Generating title with model: \(model)")

        try process.run()
        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            print("⚠️  Title generation stderr: \(errorOutput)")
        }

        guard process.terminationStatus == 0 else {
            print("❌ Title generation failed with status: \(process.terminationStatus)")
            throw ProcessingError.titleGenerationFailed
        }

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let title = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            print("❌ No title output received")
            throw ProcessingError.invalidOutput
        }

        print("✅ Title generated: \(title)")
        return title
    }

    /// Summarize transcribed text using Ollama
    func summarize(text: String, model: String = "qwen2.5:7b-instruct") async throws -> String {
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

    /// Generate a concise title using AI
    func generateTitle(from transcription: String, model: String = "qwen2.5:7b-instruct") async throws -> String {
        // Use first 500 chars of transcription for title generation
        let snippet = String(transcription.prefix(500))

        let prompt = """
        Generate a concise 3-5 word title for this voice note. Output ONLY the title, nothing else.

        Voice note: \(snippet)

        Title:
        """

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ollama")
        process.arguments = ["run", model]

        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "/opt/homebrew/bin:\(environment["PATH"] ?? "")"
        process.environment = environment

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        print("📝 Generating title...")

        try process.run()

        if let promptData = prompt.data(using: .utf8) {
            inputPipe.fileHandleForWriting.write(promptData)
        }
        inputPipe.fileHandleForWriting.closeFile()

        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            print("❌ Title generation failed, using fallback")
            // Fallback: use first few words of transcription
            let words = transcription.split(separator: " ").prefix(4)
            return words.joined(separator: " ")
        }

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let rawOutput = String(data: data, encoding: .utf8) ?? ""

        // Clean up the output: remove ANSI codes, quotes, "Title:", etc.
        var title = rawOutput
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "Title:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove ANSI escape codes
        let ansiPattern = "\\x1B(?:[@-Z\\\\-_]|\\[[0-?]*[ -/]*[@-~])"
        if let regex = try? NSRegularExpression(pattern: ansiPattern) {
            let range = NSRange(title.startIndex..., in: title)
            title = regex.stringByReplacingMatches(in: title, range: range, withTemplate: "")
        }

        title = title.trimmingCharacters(in: .whitespacesAndNewlines)

        // Limit to 8 words max
        let words = title.split(separator: " ")
        if words.count > 8 {
            title = words.prefix(8).joined(separator: " ")
        }

        // If empty or too short, use fallback
        if title.isEmpty || title.count < 3 {
            let words = transcription.split(separator: " ").prefix(4)
            title = words.joined(separator: " ")
        }

        print("✅ Title: \(title)")
        return title
    }

    /// Process a voice note: transcribe and summarize
    func process(note: inout VoiceNote) async throws {
        // Step 1: Transcribe
        note.status = .transcribing
        let transcription = try await transcribe(audioURL: note.audioPath)
        note.transcription = transcription

        // Step 2: Generate title from transcription
        let noteTitle = try await generateTitle(from: transcription)

        // Step 3: Summarize
        note.status = .summarizing
        let summary = try await summarize(text: transcription)
        note.summary = summary

        // Step 4: Save to Apple Notes
        note.status = .savingToNotes
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
    case titleGenerationFailed
    case summarizationFailed
    case invalidOutput

    var errorDescription: String? {
        switch self {
        case .transcriptionFailed:
            return "Failed to transcribe audio"
        case .titleGenerationFailed:
            return "Failed to generate note title"
        case .summarizationFailed:
            return "Failed to generate summary"
        case .invalidOutput:
            return "Invalid output from processing script"
        }
    }
}
