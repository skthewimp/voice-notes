# Voice Notes Agent

Dictate voice notes on your iPhone, automatically sync to your Mac, transcribe with Whisper, summarize with Ollama, and save to Apple Notes.

## 🚀 Quick Start

### Running the Mac Server

The NotesServer app is now installed in `/Applications/` and can run **without Xcode**:

```bash
# Start the server
open -a /Applications/NotesServer.app

# Or use the helper script
/Users/Karthik/Documents/work/NotesAgent/start-notes-server.sh

# To stop the server
killall NotesServer
```

The server will:
- Listen on port 8888 for iPhone connections
- Automatically transcribe recordings with Whisper
- Summarize with Mistral (Ollama)
- Save to Apple Notes in "Voice Summaries" folder

### Using the iPhone App

1. Open VoiceNotes on your iPhone
2. Tap settings → Enter your Mac's IP address → Connect
3. Record a voice note (tap microphone button)
4. Swipe left on the recording → Tap "Sync"
5. Check Apple Notes → "Voice Summaries" folder for the result

## System Requirements

- **iPhone**: iOS 14+ with microphone access
- **Mac**: macOS with Apple Silicon or Intel
- **RAM**: 16GB+ recommended for local LLM
- **Python**: 3.13+ (installed)
- **Ollama**: 0.13.5+ (installed via Homebrew)
- **ffmpeg**: (installed via Homebrew)
- **Whisper**: (installed in Python venv)

## Features

- 🎤 **Record** voice notes on iPhone with simple tap-to-record
- 📡 **WiFi Sync** when on same network (local, fast, private)
- 📝 **Transcribe** using OpenAI Whisper (runs locally on Mac)
- 🤖 **Summarize** using Mistral via Ollama (generates bullet points)
- 📓 **Save to Apple Notes** automatically in "Voice Summaries" folder
- 💾 **Fully Local** - no cloud services needed
- 🔒 **Private** - all processing happens on your devices
- 🎨 **Custom Icons** - microphone and sound wave design

## What's Included

✅ Python scripts for transcription and summarization
✅ macOS server app (Swift/SwiftUI) - installed in /Applications
✅ iOS recording app (Swift/SwiftUI)
✅ Apple Notes integration
✅ Shared networking protocol
✅ Custom app icons
✅ Complete documentation

## Project Structure

```
NotesAgent/
├── iOS/VoiceNotes/          # iPhone app (Swift/SwiftUI)
├── macOS/NotesServer/       # Mac server app (Swift/SwiftUI)
├── shared/                  # Shared Swift code
├── scripts/                 # Python scripts
│   ├── transcribe.py       # Whisper transcription
│   ├── summarize.py        # Ollama summarization
│   └── generate_icons.py   # App icon generator
├── icons/                  # App icons
│   ├── macos/              # macOS .icns and PNGs
│   └── ios/                # iOS AppIcon assets
└── venv/                   # Python virtual environment
```

## File Locations

- **Mac Server**: `/Applications/NotesServer.app`
- **Received Audio**: `~/Documents/VoiceNotes/`
- **Apple Notes**: "Voice Summaries" folder
- **Python venv**: `/Users/Karthik/Documents/work/NotesAgent/venv`
- **Ollama**: `/opt/homebrew/bin/ollama`

## Workflow

1. **Record**: Open iOS app → Tap microphone → Record → Stop
2. **Sync**: Swipe left on recording → Tap "Sync"
3. **Process**: Mac receives → Transcribes with Whisper → Summarizes with Mistral
4. **Save**: Creates note in Apple Notes "Voice Summaries" folder

## Configuration

- **Whisper Model**: `base` (fast, accurate for voice notes)
- **Ollama Model**: `mistral:latest` (excellent for summaries)
- **Ollama Service**: Started via `brew services start ollama`
- **Network Port**: 8888 (TCP, local network only)
- **Network Protocol**: 4-byte length prefix + JSON messages

## Troubleshooting

### Server Not Receiving
```bash
# Check server is running
pgrep NotesServer

# Check listening on port 8888
lsof -nP -iTCP:8888 -sTCP:LISTEN

# Verify same WiFi network
# Check Mac firewall allows port 8888
```

### Transcription Failing
```bash
# Verify ffmpeg
/opt/homebrew/bin/ffmpeg -version

# Check Whisper installed
/Users/Karthik/Documents/work/NotesAgent/venv/bin/python3 -c "import whisper"

# Check audio files
ls ~/Documents/VoiceNotes/
```

### Summarization Failing
```bash
# Check Ollama running
brew services list | grep ollama

# Start if needed
brew services start ollama

# Verify model
/opt/homebrew/bin/ollama list

# Test manually
echo "test" | /opt/homebrew/bin/ollama run mistral:latest
```

## Development

### Rebuild Mac Server
```bash
cd /Users/Karthik/Documents/work/NotesAgent/macOS
xcodebuild -project NotesServer.xcodeproj -scheme NotesServer -configuration Release build
cp -R ~/Library/Developer/Xcode/DerivedData/NotesServer-*/Build/Products/Release/NotesServer.app /Applications/
```

### Rebuild iOS App
```bash
cd /Users/Karthik/Documents/work/NotesAgent/iOS
xcodegen generate
# Then build and install via Xcode
```

### Regenerate Icons
```bash
/Users/Karthik/Documents/work/NotesAgent/venv/bin/python3 /Users/Karthik/Documents/work/NotesAgent/scripts/generate_icons.py
```

## Apple Notes Format

Each processed voice note appears in "Voice Summaries" with:
- **Summary**: Bullet points at the top
- **Separator**: `---`
- **Full Transcription**: Complete text below

The HTML formatting ensures proper line breaks between bullet points.

## License

Personal use project.
