# Voice Notes Agent

A **100% local-first** voice notes system: Record on iPhone, sync to Mac, transcribe with Whisper, summarize with AI, and save to Apple Notes.

> **Privacy First**: All processing happens on your devices. No cloud services, no data leaves your network.

## ✨ Features

- 🎤 **iOS App**: Simple voice recording with tap-to-record interface
- 📡 **WiFi Sync**: Automatic sync when iPhone and Mac are on same network
- 📝 **Transcription**: OpenAI Whisper converts speech to text (runs locally)
- 🤖 **AI Summary**: Ollama generates bullet-point summaries (runs locally)
- 📓 **Apple Notes**: Automatically saves formatted notes to "Voice Summaries" folder
- 🤖 **AI-Powered Setup**: MCP assistant helps you install everything (optional)
- 🔒 **Private**: Everything stays on your devices
- 🎨 **Custom Icons**: Beautiful microphone design

## 📋 Prerequisites

Before you begin, you'll need:

### On Mac
- macOS 12+ (Apple Silicon or Intel)
- [Xcode 15+](https://apps.apple.com/us/app/xcode/id497799835) (from App Store)
- [Homebrew](https://brew.sh/) (package manager)
- 16GB+ RAM recommended (for running local AI models)

### On iPhone
- iOS 14+
- iPhone connected to same WiFi as Mac

## 🚀 Quick Setup

> **🤖 Want AI to do this for you?** If you use Claude Desktop or another MCP-compatible AI assistant, you can ask it to install everything automatically. See [MCP Setup Assistant](MCP_SETUP_ASSISTANT.md) for details.

### Step 1: Install Dependencies (Mac)

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install python@3.13 ffmpeg ollama xcodegen

# Start Ollama service
brew services start ollama

# Download AI model for summarization (best quality)
ollama pull qwen2.5:7b-instruct
```

### Step 2: Set Up Python Environment

```bash
cd voice-notes

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install Whisper for transcription
pip install openai-whisper

# Deactivate for now
deactivate
```

### Step 3: Build the Apps

#### Mac Server App

```bash
cd macOS

# Build the app
xcodebuild -project NotesServer.xcodeproj -scheme NotesServer -configuration Release build

# Install to Applications
cp -R ~/Library/Developer/Xcode/DerivedData/NotesServer-*/Build/Products/Release/NotesServer.app /Applications/

# Start the server
open -a /Applications/NotesServer.app
```

#### iOS App

```bash
cd iOS

# Generate Xcode project
xcodegen generate

# Open in Xcode
open VoiceNotes.xcodeproj
```

In Xcode:
1. Select your development team in Signing & Capabilities
2. Connect your iPhone via cable
3. Select your iPhone as the build destination
4. Press Cmd+R to build and install

## 📱 How to Use

### First Time Setup

1. **Start the Mac server**:
   ```bash
   open -a /Applications/NotesServer.app
   ```
   You should see "Server listening on port 8888" in the app window.

2. **Find your Mac's IP address**:
   - System Preferences → Network
   - Look for your IP (e.g., `192.168.1.100`)

3. **Connect from iPhone**:
   - Open VoiceNotes app
   - Tap the settings icon (⚙️)
   - Enter your Mac's IP address
   - Tap "Connect"
   - You should see "Connected" status

### Recording and Processing

1. **Record**: Tap the microphone button to start recording, tap again to stop
2. **Sync**: Swipe left on the recording → Tap "Sync"
3. **Wait**: The Mac will transcribe and summarize (takes 10-30 seconds)
4. **Check Apple Notes**: Open Notes app → "Voice Summaries" folder

Your note will contain:
- AI-generated bullet-point summary
- Separator line (`---`)
- Full transcription

## 📁 Project Structure

```
voice-notes/
├── iOS/                    # iPhone app
│   ├── VoiceNotes/        # App source code
│   │   ├── Models/        # Data models
│   │   ├── Services/      # Audio recording & sync
│   │   └── Views/         # SwiftUI interfaces
│   └── project.yml        # XcodeGen configuration
│
├── macOS/                  # Mac server app
│   ├── NotesServer/       # Server source code
│   │   ├── Models/        # Data models
│   │   ├── Services/      # Network, processing, Apple Notes
│   │   └── Views/         # SwiftUI interfaces
│   └── project.yml        # XcodeGen configuration
│
├── shared/                 # Code shared between apps
│   └── NetworkProtocol.swift  # Network message format
│
├── scripts/                  # Python processing scripts
│   ├── transcribe.py        # Whisper transcription
│   ├── summarize.py         # Ollama summarization
│   └── generate_icons.py    # Icon generator
│
├── mcp_setup_assistant.py   # AI-powered setup assistant (optional)
├── MCP_SETUP_ASSISTANT.md   # Setup assistant documentation
│
└── icons/                   # App icons
    ├── macos/              # macOS .icns
    └── ios/                # iOS AppIcon assets
```

## 🔧 Configuration

### Change AI Model for Summarization

Edit `macOS/NotesServer/Services/ProcessingService.swift`:

```swift
func summarize(text: String, model: String = "qwen2.5:7b-instruct") async throws -> String {
```

Available models (must be downloaded first with `ollama pull`):
- **`qwen2.5:7b-instruct`** - Best quality summaries (default, recommended)
- `llama3.1:latest` - Good quality but verbose
- `gemma2:latest` - Faster, lighter weight
- `mistral:latest` - Older option, less concise

### Change Whisper Model for Transcription

Current default: **`small`** (good balance of accuracy and speed)

Edit `macOS/NotesServer/Services/ProcessingService.swift` to change:

```swift
"--model", "small"  // Change this value
```

Available models:
- `tiny` - Fastest, least accurate (not recommended)
- `base` - Decent but misses details
- **`small`** - 2x better accuracy than base, ~15 sec slower (default, recommended)
- `medium` - Best accuracy/speed balance, ~30 sec slower (best for quality)
- `large` - Highest accuracy, ~60+ sec (overkill for voice notes)

## 🐛 Troubleshooting

### Mac Server Won't Start

```bash
# Check if port 8888 is in use
lsof -nP -iTCP:8888 -sTCP:LISTEN

# If something is using it, kill it
killall NotesServer
```

### iPhone Won't Connect

1. Make sure both devices are on the **same WiFi network**
2. Check Mac firewall: System Preferences → Security & Privacy → Firewall → Allow incoming connections
3. Verify Mac IP address is correct
4. Try restarting both apps

### Transcription Fails

```bash
# Verify ffmpeg is installed
ffmpeg -version

# Verify Whisper is installed
source venv/bin/activate
python -c "import whisper"
deactivate
```

### Summarization Fails

```bash
# Check Ollama is running
brew services list | grep ollama

# Start if needed
brew services start ollama

# Verify model is downloaded
ollama list

# Download if needed
ollama pull mistral:latest
```

### No Notes Created in Apple Notes

1. Open Apple Notes app manually first
2. Grant permissions if prompted
3. Check for "Voice Summaries" folder
4. Try creating a test note manually to verify Notes is working

## 🛠 Development

### Regenerate Xcode Projects

```bash
# iOS
cd iOS && xcodegen generate

# macOS
cd macOS && xcodegen generate
```

### Regenerate Icons

```bash
source venv/bin/activate
python scripts/generate_icons.py
deactivate
```

## 💡 How It Works

1. **Record**: iOS app captures audio using AVAudioRecorder
2. **Sync**: Audio file sent over TCP (port 8888) with metadata
3. **Transcribe**: Mac runs Whisper Python script to convert speech→text
4. **Summarize**: Mac runs Ollama to generate bullet points
5. **Save**: Mac uses AppleScript to create formatted note in Apple Notes

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs by opening an issue
- Suggest features or improvements
- Submit pull requests

## 📄 Technical Details

- **Network Protocol**: TCP on port 8888, JSON messages with 4-byte length prefix
- **Audio Format**: M4A (AAC), 44.1kHz, mono
- **Transcription**: OpenAI Whisper (base model)
- **Summarization**: Ollama with Mistral model
- **Apple Notes**: HTML formatting via AppleScript automation

## ⚠️ Known Issues

- First transcription is slow (~30 seconds) as Whisper loads the model
- Subsequent transcriptions are faster (~10 seconds)
- Large audio files (>5 minutes) may take longer to process
- Requires Mac and iPhone to be on same WiFi network

## 🙏 Credits

Built with:
- [OpenAI Whisper](https://github.com/openai/whisper) - Speech recognition
- [Ollama](https://ollama.ai/) - Local LLM runtime
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) - Xcode project generation
- Swift, SwiftUI, Python

---

**Made with Claude Code** 🤖
