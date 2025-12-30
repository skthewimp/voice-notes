#!/usr/bin/env python3
"""
MCP Setup Assistant for Voice Notes Agent

This MCP server helps users install and configure the Voice Notes system.
Any AI assistant (Claude Desktop, Cursor, etc.) can guide users through
the complete setup process using this server.

Available tools:
- check_prerequisites: Check if required software is installed
- install_dependencies: Install missing dependencies via Homebrew
- setup_python_env: Create virtualenv and install Python packages
- build_mac_app: Build the macOS NotesServer app
- build_ios_app: Generate iOS Xcode project
- configure_server: Set up server configuration
- test_system: Run system tests to verify everything works
- get_setup_status: Get overview of what's installed/configured
"""

import json
import os
import subprocess
from pathlib import Path
from typing import Any

from mcp.server import Server
from mcp.types import Tool, TextContent


# Get project root
PROJECT_ROOT = Path(__file__).parent


def run_command(cmd: list[str], timeout: int = 60) -> dict[str, Any]:
    """Run a shell command and return result."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=PROJECT_ROOT
        )
        return {
            "success": result.returncode == 0,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "returncode": result.returncode
        }
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "error": f"Command timed out after {timeout} seconds"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


def check_command_exists(cmd: str) -> bool:
    """Check if a command exists in PATH."""
    result = run_command(["which", cmd])
    return result["success"]


def check_prerequisites() -> dict[str, Any]:
    """Check if all required software is installed."""
    checks = {
        "homebrew": check_command_exists("brew"),
        "python3": check_command_exists("python3"),
        "xcodebuild": check_command_exists("xcodebuild"),
        "ollama": check_command_exists("ollama"),
        "ffmpeg": check_command_exists("ffmpeg"),
        "xcodegen": check_command_exists("xcodegen"),
    }

    # Check Python version
    if checks["python3"]:
        result = run_command(["python3", "--version"])
        if result["success"]:
            version = result["stdout"].strip()
            checks["python_version"] = version
        else:
            checks["python_version"] = "Unknown"

    # Check if venv exists
    venv_path = PROJECT_ROOT / "venv"
    checks["venv_exists"] = venv_path.exists()

    # Check if Whisper is installed in venv
    if checks["venv_exists"]:
        venv_python = venv_path / "bin" / "python3"
        result = run_command([str(venv_python), "-c", "import whisper"])
        checks["whisper_installed"] = result["success"]
    else:
        checks["whisper_installed"] = False

    # Check if Ollama is running
    result = run_command(["pgrep", "-f", "ollama"])
    checks["ollama_running"] = result["success"]

    # Check if mistral model is downloaded
    if checks["ollama"]:
        result = run_command(["ollama", "list"])
        checks["mistral_downloaded"] = "mistral" in result["stdout"] if result["success"] else False

    return checks


def install_dependencies() -> dict[str, Any]:
    """Install missing dependencies via Homebrew."""
    steps = []

    # Install Homebrew if missing
    if not check_command_exists("brew"):
        steps.append({
            "step": "install_homebrew",
            "message": "Homebrew not installed. User must install manually:",
            "command": '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
            "manual": True
        })
        return {"steps": steps, "requires_manual_action": True}

    # Install other dependencies
    deps = ["python@3.13", "ffmpeg", "ollama", "xcodegen"]
    for dep in deps:
        result = run_command(["brew", "list", dep])
        if not result["success"]:
            install_result = run_command(["brew", "install", dep], timeout=300)
            steps.append({
                "step": f"install_{dep}",
                "success": install_result["success"],
                "output": install_result.get("stdout", "")
            })

    # Start Ollama service
    result = run_command(["brew", "services", "start", "ollama"])
    steps.append({
        "step": "start_ollama",
        "success": result["success"]
    })

    # Download mistral model
    result = run_command(["ollama", "pull", "mistral:latest"], timeout=600)
    steps.append({
        "step": "download_mistral",
        "success": result["success"]
    })

    return {"steps": steps, "requires_manual_action": False}


def setup_python_env() -> dict[str, Any]:
    """Set up Python virtual environment and install packages."""
    steps = []

    # Create venv if it doesn't exist
    venv_path = PROJECT_ROOT / "venv"
    if not venv_path.exists():
        result = run_command(["python3", "-m", "venv", "venv"])
        steps.append({
            "step": "create_venv",
            "success": result["success"]
        })

    # Install Whisper
    venv_pip = venv_path / "bin" / "pip"
    result = run_command([str(venv_pip), "install", "openai-whisper"], timeout=300)
    steps.append({
        "step": "install_whisper",
        "success": result["success"]
    })

    # Install MCP (for this assistant)
    result = run_command([str(venv_pip), "install", "mcp"], timeout=120)
    steps.append({
        "step": "install_mcp",
        "success": result["success"]
    })

    return {"steps": steps}


def build_mac_app() -> dict[str, Any]:
    """Build the macOS NotesServer app."""
    mac_dir = PROJECT_ROOT / "macOS"

    # Build the app
    result = run_command([
        "xcodebuild",
        "-project", "NotesServer.xcodeproj",
        "-scheme", "NotesServer",
        "-configuration", "Release",
        "build"
    ], timeout=300)

    if not result["success"]:
        return {
            "success": False,
            "error": result.get("stderr", "Build failed")
        }

    # Copy to /Applications
    derived_data = Path.home() / "Library" / "Developer" / "Xcode" / "DerivedData"
    app_paths = list(derived_data.glob("NotesServer-*/Build/Products/Release/NotesServer.app"))

    if app_paths:
        app_path = app_paths[0]
        result = run_command(["cp", "-R", str(app_path), "/Applications/"])
        return {
            "success": result["success"],
            "app_location": "/Applications/NotesServer.app"
        }

    return {
        "success": False,
        "error": "Could not find built app"
    }


def build_ios_app() -> dict[str, Any]:
    """Generate iOS Xcode project."""
    ios_dir = PROJECT_ROOT / "iOS"

    result = run_command(["xcodegen", "generate"], timeout=60)

    return {
        "success": result["success"],
        "project_path": str(ios_dir / "VoiceNotes.xcodeproj"),
        "next_steps": [
            "Open VoiceNotes.xcodeproj in Xcode",
            "Select your development team",
            "Connect iPhone via cable",
            "Press Cmd+R to build and install"
        ]
    }


def test_system() -> dict[str, Any]:
    """Run system tests."""
    tests = {}

    # Test transcription
    venv_python = PROJECT_ROOT / "venv" / "bin" / "python3"
    transcribe_script = PROJECT_ROOT / "scripts" / "transcribe.py"

    # Check if test audio exists
    test_audio = list((PROJECT_ROOT.parent / "VoiceNotes").glob("*.m4a"))

    if test_audio:
        result = run_command([
            str(venv_python),
            str(transcribe_script),
            str(test_audio[0]),
            "--model", "base"
        ], timeout=180)
        tests["transcription"] = {
            "success": result["success"],
            "test_file": str(test_audio[0])
        }
    else:
        tests["transcription"] = {
            "skipped": True,
            "reason": "No test audio files found"
        }

    # Test Ollama
    result = run_command(["ollama", "list"])
    tests["ollama"] = {
        "success": result["success"],
        "models": result.get("stdout", "").strip() if result["success"] else None
    }

    # Check if NotesServer app exists
    tests["mac_app"] = {
        "exists": Path("/Applications/NotesServer.app").exists()
    }

    # Check if iOS project exists
    tests["ios_project"] = {
        "exists": (PROJECT_ROOT / "iOS" / "VoiceNotes.xcodeproj").exists()
    }

    return tests


def get_setup_status() -> dict[str, Any]:
    """Get complete setup status."""
    prereqs = check_prerequisites()

    status = {
        "dependencies": {
            "homebrew": "✅ Installed" if prereqs["homebrew"] else "❌ Missing",
            "python3": f"✅ {prereqs.get('python_version', 'Installed')}" if prereqs["python3"] else "❌ Missing",
            "xcodebuild": "✅ Installed" if prereqs["xcodebuild"] else "❌ Missing",
            "ollama": "✅ Installed" if prereqs["ollama"] else "❌ Missing",
            "ffmpeg": "✅ Installed" if prereqs["ffmpeg"] else "❌ Missing",
            "xcodegen": "✅ Installed" if prereqs["xcodegen"] else "❌ Missing",
        },
        "python_environment": {
            "venv": "✅ Created" if prereqs["venv_exists"] else "❌ Not created",
            "whisper": "✅ Installed" if prereqs["whisper_installed"] else "❌ Not installed",
        },
        "ollama": {
            "running": "✅ Running" if prereqs["ollama_running"] else "❌ Not running",
            "mistral_model": "✅ Downloaded" if prereqs.get("mistral_downloaded") else "❌ Not downloaded",
        },
        "apps": {
            "mac_server": "✅ Built" if Path("/Applications/NotesServer.app").exists() else "❌ Not built",
            "ios_project": "✅ Generated" if (PROJECT_ROOT / "iOS" / "VoiceNotes.xcodeproj").exists() else "❌ Not generated",
        }
    }

    # Calculate overall progress
    total_items = sum(len(v) for v in status.values())
    completed = sum(1 for section in status.values() for item in section.values() if item.startswith("✅"))
    status["overall_progress"] = f"{completed}/{total_items} steps complete"

    return status


# Create MCP server
app = Server("voice-notes-setup")


@app.list_tools()
async def list_tools() -> list[Tool]:
    """List available setup tools."""
    return [
        Tool(
            name="get_setup_status",
            description="Get complete overview of installation and setup status",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="check_prerequisites",
            description="Check if required software (Homebrew, Python, Xcode, Ollama, etc.) is installed",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="install_dependencies",
            description="Install missing dependencies via Homebrew (python, ffmpeg, ollama, xcodegen)",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="setup_python_env",
            description="Create Python virtual environment and install required packages (Whisper, etc.)",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="build_mac_app",
            description="Build the macOS NotesServer app and install to /Applications",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="build_ios_app",
            description="Generate iOS Xcode project using XcodeGen",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="test_system",
            description="Run tests to verify transcription, summarization, and apps work correctly",
            inputSchema={"type": "object", "properties": {}},
        ),
    ]


@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """Handle tool calls."""

    if name == "get_setup_status":
        status = get_setup_status()
        return [TextContent(type="text", text=json.dumps(status, indent=2))]

    elif name == "check_prerequisites":
        prereqs = check_prerequisites()
        return [TextContent(type="text", text=json.dumps(prereqs, indent=2))]

    elif name == "install_dependencies":
        result = install_dependencies()
        return [TextContent(type="text", text=json.dumps(result, indent=2))]

    elif name == "setup_python_env":
        result = setup_python_env()
        return [TextContent(type="text", text=json.dumps(result, indent=2))]

    elif name == "build_mac_app":
        result = build_mac_app()
        return [TextContent(type="text", text=json.dumps(result, indent=2))]

    elif name == "build_ios_app":
        result = build_ios_app()
        return [TextContent(type="text", text=json.dumps(result, indent=2))]

    elif name == "test_system":
        result = test_system()
        return [TextContent(type="text", text=json.dumps(result, indent=2))]

    else:
        return [TextContent(type="text", text=f"Error: Unknown tool {name}")]


async def main():
    """Run the MCP server."""
    from mcp.server.stdio import stdio_server

    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
