# Quick Start Guide

## TL;DR

1. **Create Xcode Projects** (see SETUP.md for detailed steps)
   - macOS app: `NotesServer` in `macOS/` folder
   - iOS app: `VoiceNotes` in `iOS/` folder
   - Add the Swift files from each folder to respective projects
   - Add `shared/NetworkProtocol.swift` to both projects

2. **Run Mac Server**
   ```bash
   # Make sure Ollama is running
   open -a "Ollama 2"

   # Run NotesServer app in Xcode (Cmd+R)
   # Note the "Server Running" status
   ```

3. **Find Mac IP Address**
   - System Settings → Network → Note your IP (e.g., `192.168.1.5`)

4. **Run iPhone App**
   - Build and run VoiceNotes on your iPhone
   - Tap Settings → Enter Mac IP → Connect

5. **Record & Sync**
   - Tap blue button to record
   - Tap again to stop
   - Swipe left on recording → Sync

6. **View on Mac**
   - Note appears in NotesServer
   - Auto-transcribed and summarized
   - Click to view full details

## Architecture Overview

```
iPhone                          Mac
┌─────────────┐                ┌──────────────┐
│             │                │              │
│  Record 🎤  │                │  Receive 📥  │
│     ↓       │   WiFi Sync    │     ↓        │
│  Save 💾    │ ─────────────→ │  Transcribe  │
│             │   (TCP/8888)   │  (Whisper)   │
│  Sync ☁️    │                │     ↓        │
│             │                │  Summarize   │
│             │                │  (Ollama)    │
└─────────────┘                └──────────────┘
```

## Key Features

- **Private**: Everything runs locally, no cloud services
- **Fast**: M1 Pro handles transcription and summarization quickly
- **Simple**: Just record and sync, processing is automatic
- **Accurate**: Whisper provides high-quality transcription
- **Smart**: Qwen3:8b generates concise bullet-point summaries

## System Requirements

- **Mac**: M1 Pro or better, 16GB RAM, macOS 12+
- **iPhone**: iOS 17+, microphone access
- **Network**: Both devices on same WiFi

## What Gets Installed

- **Ollama**: Already installed, using qwen3:8b model (5.2GB)
- **Whisper**: Installed in virtual environment, downloads base model (~140MB) on first use
- **Python packages**: openai-whisper and dependencies (~500MB)

## Models Used

- **Transcription**: Whisper base model (fast, accurate for voice)
- **Summarization**: Qwen3:8b (excellent for structured bullet points)

Both models run entirely on your Mac - no API calls, no internet required after initial setup.

## Typical Workflow

1. Record voice note during meeting/brainstorming
2. Notes sync automatically when you're home on WiFi
3. Check Mac app to see transcribed + summarized notes
4. Copy summary to your task manager, docs, etc.

## Development Time Estimate

- **Xcode Setup**: ~20 minutes
- **First Build**: ~5 minutes (download dependencies)
- **Testing**: ~10 minutes
- **Total**: ~35 minutes to fully working system
