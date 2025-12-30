# Complete Voice Notes Flow Guide

## ✅ Everything You Need to Know

### What's Been Added
Your macOS app now **automatically saves summaries to Apple Notes** in a folder called "Voice Summaries"!

---

## Part 1: Getting the App on Your iPhone

### Option A: Using Xcode (Recommended)

1. **Connect iPhone to Mac**
   - Plug in USB cable OR use WiFi debugging
   - Make sure iPhone is unlocked

2. **Open iOS Project**
   ```bash
   open iOS/VoiceNotes.xcodeproj
   ```

3. **Select Your iPhone**
   - In Xcode's top bar, click the device dropdown
   - Select your iPhone from the list

4. **Build & Run**
   - Press **Cmd + R** (or click the Play ▶️ button)
   - Xcode will:
     - Build the app
     - Sign it with your Apple ID
     - Install it on your iPhone
     - Launch it automatically

5. **Trust Developer (First Time Only)**
   - On iPhone: Settings → General → VPN & Device Management
   - Tap your Apple ID → Trust

### First Launch
- App will ask for **microphone permission** → Tap "Allow"
- You're now on the main screen with a big blue record button!

---

## Part 2: Recording Voice Notes on iPhone

### The Recording Screen

```
┌─────────────────────────┐
│   Voice Notes      [⚙️]  │ ← Settings gear icon
├─────────────────────────┤
│                         │
│   Ready to Record       │
│                         │
│        ⭕️ 🔵 ⭕️         │ ← BIG BLUE BUTTON
│                         │
│   Tap to Record         │
│                         │
├─────────────────────────┤
│  📝 Your Recordings     │
│                         │
│  🎤 Note 12:30 PM       │
│  ✓ Synced  •  01:23     │
│                         │
│  🎤 Note 11:45 AM       │
│  ⬆️ Not synced  •  00:45 │
│                         │
└─────────────────────────┘
```

### How to Record

1. **Start Recording**
   - Tap the **big blue circle button**
   - Button turns **RED** and shows a **SQUARE**
   - Timer starts counting: `00:00.0`

2. **Speak Your Note**
   - Talk normally into your iPhone
   - The button pulses while recording

3. **Stop Recording**
   - Tap the **red square button** again
   - Recording saved immediately!
   - Appears in the list below

---

## Part 3: Syncing to Your Mac

### First-Time Setup

1. **Start Mac Server**
   ```bash
   open macOS/NotesServer.xcodeproj
   ```
   - In Xcode: Press Cmd + R to run
   - You'll see "Server Running" 🟢 in the window

2. **Find Your Mac's IP Address**
   - Mac: System Settings → Network
   - Look for your WiFi connection
   - Note the IP address (e.g., `192.168.1.5`)

3. **Connect iPhone to Mac**
   - On iPhone app: Tap the **⚙️ Settings** icon (top right)
   - Enter **Mac IP Address**: `192.168.1.5`
   - Port: `8888` (already filled in)
   - Tap **Connect**
   - Status changes to **"Connected" 🟢**
   - Tap **Done**

### Syncing Recordings

**Method 1: Sync Individual Recording**
1. Find the recording in your list
2. **Swipe LEFT** on it
3. Tap the **blue upload arrow ⬆️** button
4. Recording uploads to Mac
5. Checkmark ✓ appears when synced

**Method 2: Sync All Recordings**
1. Tap **Settings** (⚙️)
2. Tap **"Sync All Recordings"** button
3. All unsynced recordings upload
4. Get confirmation message

---

## Part 4: What Happens on Your Mac

### Automatic Processing Flow

When a recording arrives on your Mac:

```
1. ⬇️  RECEIVED
   "Recording received from iPhone"

2. 🎧 TRANSCRIBING...  (5-10 seconds)
   "Whisper is converting speech to text"

3. 🤖 SUMMARIZING...  (10-15 seconds)
   "Ollama (qwen3:8b) creating bullet points"

4. 📝 SAVING TO NOTES...  (1-2 seconds)
   "Creating note in Apple Notes"

5. ✅ COMPLETE!
   "Ready to view"
```

**Total Time**: ~15-25 seconds for a 30-second recording

### Viewing Results

**In NotesServer App:**
1. Recording appears in the left sidebar
2. Status badge shows progress
3. When **Complete** ✅, click on it
4. See:
   - 🎤 Audio player
   - 📝 Bullet-point summary
   - 📄 Full transcription
   - Copy buttons for both

**In Apple Notes App:**
1. Open **Notes** app on Mac
2. Look for **"Voice Summaries"** folder (created automatically)
3. Find note titled: **"Voice Note - Dec 30, 2024 at 3:45 PM"**
4. Contains:
   - Bullet-point summary (top)
   - Separator line
   - Full transcription (bottom)

---

## Part 5: Complete Example Walkthrough

### Scenario: Recording a Meeting Note

**On iPhone:**
1. Open VoiceNotes app
2. Tap big blue button 🔵
3. Say: *"Reminder for tomorrow's meeting. Need to prepare quarterly report slides, review budget numbers with Sarah, and follow up with the marketing team about the new campaign launch."*
4. Tap red square ⏹️ to stop
5. Swipe left on the new recording
6. Tap sync ⬆️

**On Mac (NotesServer):**
1. Recording appears: "Note 2024-12-30-154530.m4a"
2. Status: "Transcribing..." (10 seconds)
3. Status: "Summarizing..." (15 seconds)
4. Status: "Saving to Notes..." (2 seconds)
5. Status: "Complete" ✅

**Click to View:**
```
📝 Summary:
• Prepare quarterly report slides for tomorrow's meeting
• Review budget numbers with Sarah
• Follow up with marketing team about new campaign launch
```

**In Apple Notes:**
- Open Notes → "Voice Summaries" folder
- New note created automatically
- Same content available for editing, sharing, organizing

---

## Settings & Configuration

### iPhone App Settings

Tap ⚙️ to access:
- **Mac IP Address**: Your Mac's local IP
- **Port**: 8888 (default)
- **Connection Status**: Shows if connected to Mac
- **Sync All Recordings**: Bulk sync button
- **Last Sync**: Timestamp of last successful sync
- **Total Recordings**: Count of your recordings
- **Synced**: How many are backed up

### Mac Server App

The NotesServer app runs in the background and:
- Listens on port **8888**
- Auto-processes all incoming recordings
- Creates notes in **"Voice Summaries"** folder
- Shows real-time status for each recording

---

## Permissions You'll Be Asked For

### iPhone
- **Microphone Access**: Required to record
  - Prompt: "VoiceNotes would like to access the microphone"
  - Choose: **Allow**

### Mac (First Run)
- **Automation Permission**: Required to save to Apple Notes
  - macOS will ask: "NotesServer wants to control Notes.app"
  - Choose: **OK** or **Allow**
  - This is normal and safe!

---

## Troubleshooting

### "Can't Connect to Server"
- ✅ Make sure NotesServer app is **running** on Mac
- ✅ Both devices on **same WiFi network**
- ✅ Check Mac's IP address is correct
- ✅ Try disabling/re-enabling WiFi on both devices

### "Recording Failed"
- ✅ Grant microphone permission in Settings
- ✅ Make sure iPhone isn't in silent mode
- ✅ Close and reopen the app

### "Processing Failed"
- ✅ Make sure **Ollama is running**: `open -a "Ollama 2"`
- ✅ Check Python environment:
  ```bash
  cd /Users/Karthik/Documents/work/NotesAgent
  source venv/bin/activate
  python scripts/transcribe.py --help
  ```

### "Note Not Created in Apple Notes"
- ✅ Grant automation permission when prompted
- ✅ Open **Notes app** first (it must be installed)
- ✅ Check System Settings → Privacy & Security → Automation
  - Make sure **NotesServer** can control **Notes**

### Sync is Slow
- Use **5 GHz WiFi** for faster transfer
- Recordings are compressed but large files take longer
- Check WiFi signal strength on both devices

---

## Tips & Best Practices

### Recording Tips
- **Speak clearly** and at normal pace
- **2-3 feet** from iPhone microphone is optimal
- **Quiet environment** = better transcription
- **Keep recordings under 5 minutes** for faster processing

### Organizing Notes
- Notes are saved with timestamp titles
- In Apple Notes, you can:
  - Rename notes
  - Add tags
  - Move to other folders
  - Share via email, Messages, etc.

### Managing Storage
- **iPhone**: Delete synced recordings to free space
  - Swipe left → Tap trash icon
- **Mac**: Audio files stored in `~/Documents/VoiceNotes`
  - Delete old recordings if needed

---

## What's Happening Behind the Scenes

### Tech Stack
- **iPhone**: Swift/SwiftUI native app
- **Mac Server**: Swift/SwiftUI native app
- **Transcription**: OpenAI Whisper (base model)
- **Summarization**: Ollama (qwen3:8b model)
- **Notes Integration**: AppleScript automation
- **Sync**: TCP socket on port 8888

### Where Files Are Stored

**iPhone:**
```
Documents/
  └── Recordings/
      ├── Note-1234567890.m4a
      └── recordings.json (metadata)
```

**Mac:**
```
Documents/
  └── VoiceNotes/
      ├── Note-1234567890.m4a
      └── (transcriptions & summaries in memory)
```

**Apple Notes:**
```
iCloud/Notes/
  └── Voice Summaries/
      ├── Voice Note - Dec 30, 2024 at 3:45 PM
      └── Voice Note - Dec 30, 2024 at 2:30 PM
```

---

## Quick Reference

### iPhone Controls
- **🔵 Blue Button**: Start recording
- **🔴 Red Square**: Stop recording
- **⬅️ Swipe Left**: Show sync option
- **⬆️ Blue Arrow**: Sync to Mac
- **⚙️ Settings**: Configure connection
- **🗑️ Trash**: Delete recording

### Mac Server Status Indicators
- **🔴 Offline**: Server not running
- **🟢 Running**: Ready to receive
- **🟠 Processing**: Working on a recording
- **✅ Complete**: Note ready and saved

### Keyboard Shortcuts (Mac App)
- **Cmd + R**: Run server (in Xcode)
- **Cmd + Q**: Quit app
- Click recording → **Space**: Play/Pause audio

---

## Next Steps

Now that everything is set up:

1. **Record your first note** on iPhone
2. **Sync it to Mac**
3. **Watch the magic happen** (transcription → summary → Apple Notes)
4. **Check Apple Notes** for your organized summary

Your voice notes are now automatically transcribed, summarized, and saved to Apple Notes!

---

**Questions or Issues?**
- Check the troubleshooting section above
- Review the example walkthrough
- Make sure all apps have required permissions
