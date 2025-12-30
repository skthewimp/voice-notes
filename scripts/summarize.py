#!/usr/bin/env python3
"""
Summarize transcribed text into bullet points using Ollama.
Usage: python summarize.py <text_or_file> [--model qwen3:8b]
"""

import sys
import argparse
import json
import subprocess
from pathlib import Path


def call_ollama(prompt: str, model: str = "mistral:latest") -> str:
    """
    Call Ollama API to generate summary.

    Args:
        prompt: The full prompt to send to the model
        model: Ollama model to use

    Returns:
        Generated text response
    """
    try:
        # Use the Ollama CLI directly (Homebrew installation)
        result = subprocess.run(
            ["/opt/homebrew/bin/ollama", "run", model],
            input=prompt,
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode != 0:
            raise RuntimeError(f"Ollama error: {result.stderr}")

        return result.stdout.strip()

    except subprocess.TimeoutExpired:
        raise RuntimeError("Ollama request timed out")
    except FileNotFoundError:
        raise RuntimeError("Ollama not found. Is it installed?")


def summarize_text(text: str, model: str = "mistral:latest") -> str:
    """
    Summarize text into concise bullet points.

    Args:
        text: Text to summarize
        model: Ollama model to use

    Returns:
        Summarized text in bullet points
    """
    prompt = f"""You are a helpful assistant that summarizes voice notes into clear, concise bullet points.

Given the following transcribed voice note, create a summary using bullet points. Focus on:
- Key ideas and main points
- Action items (if any)
- Important details or decisions

Keep it brief and well-organized.

Voice note transcription:
{text}

Summary (bullet points only):"""

    print(f"Generating summary with {model}...", file=sys.stderr)
    summary = call_ollama(prompt, model)

    return summary


def main():
    parser = argparse.ArgumentParser(description="Summarize text using Ollama")
    parser.add_argument("input", help="Text to summarize or path to text file")
    parser.add_argument("--model", default="mistral:latest",
                       help="Ollama model to use (default: mistral:latest)")
    parser.add_argument("--json", action="store_true",
                       help="Output as JSON")

    args = parser.parse_args()

    # Check if input is a file or direct text
    # Only check for file if input looks like a reasonable path
    if len(args.input) < 500 and not args.input.startswith('\n'):
        try:
            input_path = Path(args.input)
            if input_path.exists() and input_path.is_file():
                text = input_path.read_text()
            else:
                text = args.input
        except (OSError, ValueError):
            text = args.input
    else:
        text = args.input

    if not text.strip():
        print("Error: No text provided", file=sys.stderr)
        sys.exit(1)

    try:
        summary = summarize_text(text, args.model)

        if args.json:
            output = {
                "original_text": text,
                "summary": summary,
                "model": args.model
            }
            print(json.dumps(output, indent=2))
        else:
            print(summary)

    except Exception as e:
        print(f"Error during summarization: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
