import Foundation
import AppKit

/// Service for creating notes in Apple Notes app
class AppleNotesService {
    private let folderName = "Voice Summaries"

    /// Create a note in Apple Notes with the given content
    func createNote(title: String, summary: String, transcription: String) async throws {
        // Convert plain text to HTML with proper line breaks
        let summaryHTML = escapeForHTML(summary).replacingOccurrences(of: "\n", with: "<br>")
        let transcriptionHTML = escapeForHTML(transcription).replacingOccurrences(of: "\n", with: "<br>")

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
            activate

            set targetFolder to missing value
            try
                set targetFolder to folder "\(folderName)"
            on error
                set targetFolder to make new folder with properties {name:"\(folderName)"}
            end try

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

    /// Escape special characters for HTML
    private func escapeForHTML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
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
