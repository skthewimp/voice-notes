import Foundation
import AppKit

/// Service for creating notes in Apple Notes app
class AppleNotesService {
    private let folderName = "Voice Summaries"

    /// Create a note in Apple Notes with the given content
    func createNote(title: String, summary: String, transcription: String) async throws {
        // Convert plain text to HTML with proper line breaks
        let summaryHTML = summary.replacingOccurrences(of: "\n", with: "<br>")
        let transcriptionHTML = transcription.replacingOccurrences(of: "\n", with: "<br>")

        let htmlContent = """
        <div>\(summaryHTML)</div>
        <br>
        <div>---</div>
        <br>
        <div><b>Full Transcription:</b></div>
        <div>\(transcriptionHTML)</div>
        """

        let appleScript = """
        tell application "Notes"
            -- Activate to ensure it's running
            activate

            -- Try to find the folder, create if it doesn't exist
            set targetFolder to missing value
            try
                set targetFolder to folder "\(folderName)"
            on error
                -- Create the folder if it doesn't exist
                set targetFolder to make new folder with properties {name:"\(folderName)"}
            end try

            -- Create the note with HTML content
            tell targetFolder
                make new note with properties {name:"\(escapeForAppleScriptSimple(title))", body:"\(escapeForAppleScriptSimple(htmlContent))"}
            end tell
        end tell
        """

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                var error: NSDictionary?
                if let scriptObject = NSAppleScript(source: appleScript) {
                    let output = scriptObject.executeAndReturnError(&error)

                    if let error = error {
                        print("❌ AppleScript error: \(error)")
                        continuation.resume(throwing: AppleNotesError.scriptFailed(error.description))
                    } else {
                        print("✅ Note created in Apple Notes: \(title)")
                        continuation.resume()
                    }
                } else {
                    continuation.resume(throwing: AppleNotesError.invalidScript)
                }
            }
        }
    }

    /// Escape special characters for AppleScript strings (simple version without newline handling)
    private func escapeForAppleScriptSimple(_ string: String) -> String {
        // Only escape backslashes and quotes - newlines are handled separately
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

enum AppleNotesError: LocalizedError {
    case scriptFailed(String)
    case invalidScript

    var errorDescription: String? {
        switch self {
        case .scriptFailed(let details):
            return "Failed to create note in Apple Notes: \(details)"
        case .invalidScript:
            return "Invalid AppleScript"
        }
    }
}
