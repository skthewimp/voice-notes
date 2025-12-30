#!/usr/bin/env python3
"""
Generate concise titles for voice notes using Ollama.

This script is called by the Mac server to create descriptive 3-6 word titles
from transcribed voice notes.

Usage:
    python generate_title.py "text to title" [--model mistral:latest]

Example:
    python generate_title.py "Today I went to the store and bought milk" --model mistral:latest
"""

import sys
import argparse
import subprocess
import re


def call_ollama(prompt: str, model: str = "mistral:latest") -> str:
    """
    Call Ollama API to generate title.

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
            timeout=30
        )

        if result.returncode != 0:
            raise RuntimeError(f"Ollama error: {result.stderr}")

        # Remove ANSI escape codes from output
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        clean_output = ansi_escape.sub('', result.stdout)

        return clean_output.strip()

    except subprocess.TimeoutExpired:
        raise RuntimeError("Ollama request timed out")
    except FileNotFoundError:
        raise RuntimeError("Ollama not found. Is it installed?")


def generate_title(text: str, model: str = "mistral:latest") -> str:
    """
    Generate a concise title (3-6 words) for a voice note.

    Args:
        text: Text to generate title from (first 500 chars used)
        model: Ollama model to use

    Returns:
        Generated title
    """
    # Use only first 500 characters for title generation
    snippet = text[:500] if len(text) > 500 else text

    prompt = f"""Generate a short, descriptive title (3-6 words) for this voice note. Only output the title text, no formatting, no bullets, no dashes.

Voice note: {snippet}

Title:"""

    print(f"Generating title with {model}...", file=sys.stderr)
    title = call_ollama(prompt, model)

    # Clean up the title - remove quotes, "Title:" prefix, bullets, dashes
    title = title.replace('"', '').replace('Title:', '').strip()

    # Remove leading bullets, dashes, numbers
    title = re.sub(r'^[\-\*\•\d\.\)]+\s*', '', title).strip()

    # Remove any remaining line breaks or extra whitespace
    title = ' '.join(title.split())

    # If title is too long, truncate to first 6 words
    words = title.split()
    if len(words) > 6:
        title = ' '.join(words[:6])

    # Ensure title is not empty
    if not title:
        title = "Voice Note"

    return title


def main():
    parser = argparse.ArgumentParser(description="Generate title using Ollama")
    parser.add_argument("input", help="Text to generate title from")
    parser.add_argument("--model", default="mistral:latest",
                       help="Ollama model to use (default: mistral:latest)")

    args = parser.parse_args()

    if not args.input.strip():
        print("Error: No text provided", file=sys.stderr)
        sys.exit(1)

    try:
        title = generate_title(args.input, args.model)
        print(title)

    except Exception as e:
        print(f"Error during title generation: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
