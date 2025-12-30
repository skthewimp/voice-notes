#!/usr/bin/env python3
"""
Transcribe audio files using OpenAI Whisper.
Usage: python transcribe.py <audio_file> [--model base]
"""

import sys
import whisper
import argparse
import json
from pathlib import Path


def transcribe_audio(audio_path: str, model_name: str = "base") -> dict:
    """
    Transcribe an audio file using Whisper.

    Args:
        audio_path: Path to the audio file
        model_name: Whisper model to use (tiny, base, small, medium, large)

    Returns:
        Dictionary containing transcription and metadata
    """
    print(f"Loading Whisper model '{model_name}'...", file=sys.stderr)
    model = whisper.load_model(model_name)

    print(f"Transcribing {audio_path}...", file=sys.stderr)
    result = model.transcribe(audio_path)

    return {
        "text": result["text"].strip(),
        "language": result.get("language", "unknown"),
        "segments": [
            {
                "start": seg["start"],
                "end": seg["end"],
                "text": seg["text"].strip()
            }
            for seg in result.get("segments", [])
        ]
    }


def main():
    parser = argparse.ArgumentParser(description="Transcribe audio using Whisper")
    parser.add_argument("audio_file", help="Path to audio file")
    parser.add_argument("--model", default="base",
                       choices=["tiny", "base", "small", "medium", "large"],
                       help="Whisper model size (default: base)")
    parser.add_argument("--json", action="store_true",
                       help="Output as JSON instead of plain text")

    args = parser.parse_args()

    audio_path = Path(args.audio_file)
    if not audio_path.exists():
        print(f"Error: Audio file not found: {audio_path}", file=sys.stderr)
        sys.exit(1)

    try:
        result = transcribe_audio(str(audio_path), args.model)

        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print(result["text"])

    except Exception as e:
        print(f"Error during transcription: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
