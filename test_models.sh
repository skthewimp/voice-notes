#!/bin/bash

TEST_TEXT="I had a great day in the gym today. I hit a new PR in my Benchpress lifting 87 kgs by Levey 85 kgs. My previous PR was 80 kgs. I think I'd been afraid to go higher and also I had had had an injury a couple of months ago because of which I had a big progress I had started. But since my target for this year was to bench-mess my body weight I just thought I'll just go for it today and yeah it actually happened."

PROMPT="You are a helpful assistant that summarizes voice notes into clear, concise bullet points.

Given the following transcribed voice note, create a summary using bullet points. Focus on:
- Key ideas and main points
- Action items (if any)
- Important details or decisions

Keep it brief and well-organized.

Voice note transcription:
$TEST_TEXT

Summary (bullet points only):"

echo "Testing voice note summarization models..."
echo ""
echo "=========================================="

# Test Mistral (current)
echo "🔵 MISTRAL (current)"
echo "=========================================="
echo "$PROMPT" | /opt/homebrew/bin/ollama run mistral:latest
echo ""
echo ""

# Test Llama 3.1
echo "🦙 LLAMA 3.1"
echo "=========================================="
echo "$PROMPT" | /opt/homebrew/bin/ollama run llama3.1:latest
echo ""
echo ""

# Test Llama 3.2
echo "🦙 LLAMA 3.2"
echo "=========================================="
echo "$PROMPT" | /opt/homebrew/bin/ollama run llama3.2:latest
echo ""
echo ""

# Test Gemma2
echo "💎 GEMMA 2"
echo "=========================================="
echo "$PROMPT" | /opt/homebrew/bin/ollama run gemma2:latest
echo ""
echo ""

# Test Nous Hermes
echo "🧙 NOUS HERMES"
echo "=========================================="
echo "$PROMPT" | /opt/homebrew/bin/ollama run nous-hermes:latest
echo ""
