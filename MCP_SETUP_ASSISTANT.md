##

 MCP Setup Assistant

An AI-powered installation assistant for the Voice Notes system. Any AI assistant (Claude Desktop, Cursor, etc.) can guide you through the complete setup process.

## What Is This?

Instead of manually following README instructions, you can ask an AI assistant to help you install and configure everything. The AI can:

- ✅ Check what's already installed
- 📦 Install missing dependencies
- 🐍 Set up Python environment
- 🔨 Build Mac and iOS apps
- ✅ Test that everything works
- 🎯 Guide you step-by-step

## Setup for Claude Desktop

### Step 1: Add the Setup Assistant

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "voice-notes-setup": {
      "command": "python3",
      "args": ["/path/to/NotesAgent/mcp_setup_assistant.py"]
    }
  }
}
```

**Replace `/path/to/NotesAgent/` with the actual path where you cloned this repo!**

### Step 2: Restart Claude Desktop

Quit Claude Desktop completely and relaunch.

### Step 3: Ask Claude to Help You Install

Start a new conversation and say:

```
I want to set up the Voice Notes system. Can you check what's installed and help me get everything working?
```

Claude will use the MCP tools to:
1. Check what you have installed
2. Tell you what's missing
3. Install dependencies for you
4. Build the apps
5. Test everything

## Example Conversation

**You:** "Help me install the Voice Notes system"

**Claude:** "I'll check what you have installed first..."
*[Uses get_setup_status tool]*
"I can see you have Homebrew and Python installed, but you're missing Ollama and xcodegen. Would you like me to install them?"

**You:** "Yes, install everything"

**Claude:** *[Uses install_dependencies tool]*
"Installing dependencies via Homebrew... Done! Now let me set up your Python environment..."
*[Uses setup_python_env tool]*
"Python environment ready. Now building the Mac app..."
*[Uses build_mac_app tool]*

...and so on.

## Available Commands

Once set up, you can ask Claude things like:

- "What's the current setup status?"
- "Check if all prerequisites are installed"
- "Install missing dependencies"
- "Set up the Python environment"
- "Build the Mac app"
- "Generate the iOS Xcode project"
- "Test if everything is working"
- "Walk me through the complete setup"

## What the Assistant Can Do

### 1. `get_setup_status`
Shows overall progress and what's installed/configured.

### 2. `check_prerequisites`
Checks if required software is installed (Homebrew, Python, Xcode, Ollama, ffmpeg, xcodegen).

### 3. `install_dependencies`
Installs missing dependencies via Homebrew.

### 4. `setup_python_env`
Creates Python virtual environment and installs Whisper and other packages.

### 5. `build_mac_app`
Builds the macOS NotesServer app and installs it to /Applications.

### 6. `build_ios_app`
Generates the iOS Xcode project.

### 7. `test_system`
Runs tests to verify transcription and summarization work.

## For Other AI Assistants

This MCP server works with any MCP-compatible client:

- **Cursor IDE**: Add to Cursor settings
- **Continue.dev**: Add to Continue config
- **Any MCP client**: Use stdio transport

Use the same `command` and `args` from the Claude Desktop config above.

## Privacy & Security

The setup assistant:
- Only runs commands you approve through the AI conversation
- Installs software via Homebrew (standard Mac package manager)
- Creates files only in the project directory
- Does NOT send any data to external services
- Everything stays local on your Mac

## Troubleshooting

### "Command not found" errors

Make sure Python 3 is installed:
```bash
python3 --version
```

### MCP server not appearing in Claude

1. Check the path in `claude_desktop_config.json` is correct
2. Make sure you completely quit and restarted Claude Desktop
3. Check Claude logs: `~/Library/Logs/Claude/`

### Permission errors

The assistant may need your password for `brew install` commands. Claude will tell you when this happens.

## Benefits Over Manual Setup

- **Faster**: AI handles all the steps
- **Less error-prone**: AI checks each step succeeds before moving on
- **Guided**: AI explains what it's doing and why
- **Recoverable**: If something fails, AI can diagnose and fix it
- **Interactive**: Ask questions anytime during setup

## Example Full Setup Conversation

**You:** "I just cloned the voice-notes repo. Help me get it running."

**Claude:** "I'll help you set up the Voice Notes system. Let me check what you have installed first."
*[Runs get_setup_status]*

"Here's what I found:
- ✅ Homebrew: Installed
- ✅ Python 3.13: Installed
- ✅ Xcode: Installed
- ❌ Ollama: Not installed
- ❌ ffmpeg: Not installed
- ❌ xcodegen: Not installed
- ❌ Python venv: Not created
- ❌ Whisper: Not installed

I'll need to install 3 dependencies (Ollama, ffmpeg, xcodegen) and set up the Python environment. This will take about 5-10 minutes. Should I proceed?"

**You:** "Yes, do it"

**Claude:** "Installing dependencies via Homebrew..."
*[Runs install_dependencies]*
"Done! All dependencies installed.

Now setting up Python environment..."
*[Runs setup_python_env]*
"Python environment ready. Whisper is installed.

Building the Mac server app..."
*[Runs build_mac_app]*
"Mac app built and installed to /Applications/NotesServer.app

Generating iOS Xcode project..."
*[Runs build_ios_app]*
"iOS project generated at iOS/VoiceNotes.xcodeproj

Let me run some tests to verify everything works..."
*[Runs test_system]*
"All tests passed! ✅

The Voice Notes system is fully set up. Here's what you can do next:

1. **Start the Mac server**: Open /Applications/NotesServer.app
2. **Install iOS app**:
   - Open iOS/VoiceNotes.xcodeproj in Xcode
   - Select your development team
   - Connect your iPhone
   - Press Cmd+R to build and install

3. **Connect iPhone to Mac**:
   - Tap settings in the iOS app
   - Enter your Mac's IP address (System Preferences → Network)
   - Tap Connect

Would you like help with any of these steps?"
