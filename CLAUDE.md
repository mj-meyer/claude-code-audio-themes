# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a sound notification system for Claude Code hooks that plays customizable themed sounds for different events like tool permissions and completion notifications.

## Quick Reference

For user workflows and installation instructions, see README.md. This file focuses on technical implementation details.

### Available Slash Commands
- `/project:install [theme]` - Install with intelligent settings merging and theme validation
- `/project:update-theme theme` - Update with git workflow for local customizations  
- `/project:create-theme name "desc" types` - Create themes with dynamic event type discovery

## Architecture

### Core Components

- **themed-sound-player.sh**: Main script that handles sound selection and playback with cross-platform volume control
- **sound-themes/**: Directory containing organized sound files by theme and event type
- **settings-template.json**: Template Claude Code settings with hook configuration
- **.claude/commands/**: Slash commands for installation, theme management, and creation

### Sound Selection Logic

1. Attempts to find sounds in the specific event directory (e.g., `bash/`)
2. Falls back to `default/` directory if specific event has no sounds
3. Randomly selects from available files if multiple exist
4. Extracts volume level from filename pattern: `name-volume.extension`

### Hook Integration

The system integrates with Claude Code through hooks in `settings.json`:
- **Notification hook**: Triggered by tool permission requests, analyzes message content to determine event type
- **Stop hook**: Triggered when Claude finishes responding

### Event Types and Sound Organization

The system organizes sounds into event-specific directories:
- `bash/` - Bash tool permission sounds
- `write/` - Write tool permission sounds  
- `read/` - Read tool permission sounds
- `edit/` - Edit tool permission sounds
- `stop/` - Completion sounds when Claude finishes
- `default/` - Fallback sounds for missing event types

Event types are dynamically discovered from existing themes, not hardcoded.

## File Naming Convention

Sound files use the pattern: `description-volume.extension`
- Volume range: 0-∞ (values >100% amplify sound for normalizing quiet recordings)
- Default volume: 70% if no volume specified
- Supported formats: .aiff, .wav, .mp3, .m4a, .ogg (platform dependent)

## Dependencies

- **jq**: Required for JSON parsing (notification events and settings management)
- **afplay**: macOS sound playback (built-in) with volume control
- **paplay/aplay/play**: Linux sound players (varies by distribution)
- **bc**: For volume calculations (typically pre-installed)
- **git**: Required for update-theme workflow with local customizations

## Technical Details

### Volume Control Implementation
- **macOS**: `afplay -v decimal` where volume/100 = decimal (supports >1.0 for amplification)
- **Linux**: `paplay --volume=int` where volume*655 = int, or `play -v decimal`
- **Windows**: Basic PowerShell support (no volume control, uses Play() for non-blocking)

### Git Workflow for Local Customizations
The update-theme command implements sophisticated git workflow:
- Detects local changes vs git HEAD
- Creates personal branches: `personal-$(whoami)-$(date)`
- Rebases personal changes onto updated main branch
- Handles merge conflicts interactively

## Debugging

- Sound activity is logged to `~/.claude/sound-log.txt` with timestamps, theme, event type, filename, volume, and trigger message
- Use `tail -f ~/.claude/sound-log.txt` to monitor sound events in real-time
- Check git status with commands that show uncommitted changes and branch state

## Platform Support

- **macOS**: Full support with afplay and volume control
- **Linux**: Supports multiple audio players (paplay, aplay, play) with varying volume control
- **Windows**: Basic support via PowerShell (limited volume control)