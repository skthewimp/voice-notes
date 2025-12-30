# Setup Guide

Follow these steps to set up and run the Voice Notes app on your iPhone and Mac.

## Prerequisites

- Xcode 15+ installed on your Mac
- iPhone running iOS 17+
- Both devices on the same WiFi network
- Ollama running on your Mac (already installed)
- Python virtual environment (already created)

## Part 1: macOS Server App Setup

### 1. Create macOS Xcode Project

1. Open Xcode
2. Create a new project: **File → New → Project**
3. Choose **macOS → App**
4. Project settings:
   - Product Name: `NotesServer`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Save location: `/Users/Karthik/Documents/work/NotesAgent/macOS/`

### 2. Add Swift Files to Project

1. Delete the default `ContentView.swift` and `NotesServerApp.swift` that Xcode created
2. In Xcode, right-click on `NotesServer` folder → **Add Files to "NotesServer"**
3. Navigate to `/Users/Karthik/Documents/work/NotesAgent/macOS/NotesServer/`
4. Select all folders (Models, Services, Views) and `NotesServerApp.swift`
5. Make sure **"Copy items if needed"** is UNCHECKED
6. Click **Add**

### 3. Add Shared Files

1. Right-click on `NotesServer` folder → **Add Files to "NotesServer"**
2. Navigate to `/Users/Karthik/Documents/work/NotesAgent/shared/`
3. Select `NetworkProtocol.swift`
4. UNCHECK "Copy items if needed"
5. Click **Add**

### 4. Configure App Permissions

1. Select `NotesServer` target in Xcode
2. Go to **Signing & Capabilities** tab
3. Add capability: **Outgoing Connections (Client)** (for Ollama)
4. Add capability: **Incoming Connections (Server)** (for receiving from iPhone)
5. Go to **Info** tab
6. Add the following keys:
   - `NSMicrophoneUsageDescription`: "To play received voice notes"

### 5. Update Project Settings

1. Select the `NotesServer` target
2. Go to **Build Settings**
3. Search for "Deployment Target"
4. Set **macOS Deployment Target** to **12.0** or higher

### 6. Build and Run

1. Select **My Mac** as the run destination
2. Press **Cmd + R** to build and run
3. The server should start and show "Server Running" status
4. Note: Keep this app running to receive recordings from iPhone

## Part 2: iOS Voice Notes App Setup

### 1. Create iOS Xcode Project

1. Open a new Xcode window (or use **File → New → Project** in same window)
2. Choose **iOS → App**
3. Project settings:
   - Product Name: `VoiceNotes`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Save location: `/Users/Karthik/Documents/work/NotesAgent/iOS/`

### 2. Add Swift Files to Project

1. Delete the default `ContentView.swift` and `VoiceNotesApp.swift` that Xcode created
2. Right-click on `VoiceNotes` folder → **Add Files to "VoiceNotes"**
3. Navigate to `/Users/Karthik/Documents/work/NotesAgent/iOS/VoiceNotes/`
4. Select all folders (Models, Services, Views) and `VoiceNotesApp.swift`
5. Make sure **"Copy items if needed"** is UNCHECKED
6. Click **Add**

### 3. Add Shared Files

1. Right-click on `VoiceNotes` folder → **Add Files to "VoiceNotes"**
2. Navigate to `/Users/Karthik/Documents/work/NotesAgent/shared/`
3. Select `NetworkProtocol.swift`
4. UNCHECK "Copy items if needed"
5. Click **Add**

### 4. Configure App Permissions

1. Select `VoiceNotes` target in Xcode
2. Go to **Info** tab
3. Add the following Privacy keys:
   - `NSMicrophoneUsageDescription`: "To record voice notes"
   - Right-click in the list → **Add Row**
   - Key: **Privacy - Microphone Usage Description**
   - Value: **"This app needs microphone access to record voice notes"**

### 5. Enable Required Capabilities

1. Go to **Signing & Capabilities** tab
2. Click **+ Capability**
3. Add: **Background Modes**
4. Check: **Audio, AirPlay, and Picture in Picture**

### 6. Build and Run on iPhone

1. Connect your iPhone via USB or use wireless debugging
2. Select your iPhone as the run destination
3. You may need to trust the developer certificate on your iPhone:
   - Settings → General → VPN & Device Management → Trust
4. Press **Cmd + R** to build and run

## Part 3: Connect iPhone to Mac

### 1. Find Your Mac's IP Address

1. On your Mac, click the Apple menu → **System Settings**
2. Click **Network**
3. Select your WiFi connection
4. Note the IP address (e.g., `192.168.1.5`)

### 2. Configure iPhone App

1. Open the VoiceNotes app on your iPhone
2. Tap the **Settings** gear icon (top right)
3. Enter your Mac's IP address in the **"Mac IP Address"** field
4. Port should be `8888` (default)
5. Tap **Connect**
6. Status should show **"Connected"** in green
7. Tap **Done**

## Part 4: Test the Complete Workflow

### 1. Make Sure Mac Server is Running

1. Launch the NotesServer app on your Mac
2. Verify "Server Running" status is green
3. Keep it running in the background

### 2. Record on iPhone

1. Open VoiceNotes app on iPhone
2. Tap the blue **Record** button
3. Speak your note
4. Tap again to **Stop**
5. Your recording appears in the list below

### 3. Sync to Mac

1. Swipe left on the recording
2. Tap the blue **Sync** button (arrow up icon)
3. The checkmark turns green when synced

**Or** use automatic sync:
1. Go to Settings
2. Tap **Sync All Recordings**

### 4. View on Mac

1. The recording appears in the NotesServer app on Mac
2. Watch the status change:
   - **Received** → **Transcribing** → **Summarizing** → **Complete**
3. Click on the note to see:
   - Full transcription
   - Bullet-point summary
   - Play the audio
   - Copy transcription or summary

## Troubleshooting

### iPhone Can't Connect to Mac

- Ensure both devices are on the same WiFi network
- Check firewall settings on Mac (System Settings → Network → Firewall)
- Try disabling and re-enabling WiFi on both devices
- Make sure NotesServer app is running on Mac

### Transcription or Summarization Fails

- Ensure Ollama app is running: `open -a "Ollama 2"`
- Activate virtual environment and test scripts:
  ```bash
  cd /Users/Karthik/Documents/work/NotesAgent
  source venv/bin/activate
  python scripts/transcribe.py <test-audio-file>
  ```

### Permission Errors

- Grant microphone access when iOS app requests it
- Check macOS System Settings → Privacy & Security for permissions

### Build Errors in Xcode

- Make sure all files are properly added to the target
- Check that NetworkProtocol.swift is included in both targets
- Clean build folder: **Product → Clean Build Folder** (Cmd + Shift + K)
- Restart Xcode if needed

## Next Steps

Once everything is working:

1. **Auto-sync**: Enhance sync to happen automatically when on WiFi
2. **Bonjour Discovery**: Implement automatic Mac discovery (no manual IP entry)
3. **Notifications**: Add push notifications when processing completes
4. **Export**: Add ability to export summaries to Notes, Email, etc.
5. **Cloud Backup**: Optional iCloud sync for recordings

## File Structure Summary

```
NotesAgent/
├── iOS/VoiceNotes/              # iPhone App (Xcode project here)
│   ├── VoiceNotesApp.swift
│   ├── Models/
│   │   └── VoiceRecording.swift
│   ├── Services/
│   │   ├── AudioRecorderService.swift
│   │   └── SyncService.swift
│   └── Views/
│       ├── ContentView.swift
│       ├── RecordingView.swift
│       ├── RecordingsListView.swift
│       └── SettingsView.swift
│
├── macOS/NotesServer/           # Mac Server App (Xcode project here)
│   ├── NotesServerApp.swift
│   ├── Models/
│   │   └── VoiceNote.swift
│   ├── Services/
│   │   ├── NetworkService.swift
│   │   └── ProcessingService.swift
│   └── Views/
│       ├── ContentView.swift
│       └── NoteDetailView.swift
│
├── shared/                      # Shared between iOS & macOS
│   └── NetworkProtocol.swift
│
├── scripts/                     # Python processing scripts
│   ├── transcribe.py           # Whisper transcription
│   └── summarize.py            # Ollama summarization
│
└── venv/                       # Python virtual environment
```

You're all set! Enjoy your voice notes app!
