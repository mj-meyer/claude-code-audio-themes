---
allowed-tools: Bash(*), Read(*), Edit(*), Write(*)
description: Install Claude Code sound themes with intelligent settings merging and theme selection
---

# Install Claude Code Audio Themes

Install the audio notification system for Claude Code with intelligent settings merging and optional theme selection.

## Usage

- `/project:install` - Install with default theme
- `/project:install theme-name` - Install and set specific theme

## Current Environment

- Claude directory: !`test -d ~/.claude && echo "EXISTS" || echo "NOT FOUND"`
- Existing settings: !`test -f ~/.claude/settings.json && echo "EXISTS" || echo "NOT FOUND"`
- Current working directory: !`pwd`
- Available themes: !`find sound-themes -maxdepth 1 -type d -not -name sound-themes -not -name ".*" | sed 's|sound-themes/||' | sort`

## Arguments

Theme parameter: $ARGUMENTS

## Installation Tasks

1. **Validate theme selection** (if provided):
   - Check if specified theme exists exactly
   - If not exact match, find similar themes and confirm with user
   - Default to "default" theme if no argument provided

2. **Copy sound player script** to `~/.claude/themed-sound-player.sh`

3. **Copy sound themes directory** to `~/.claude/sound-themes/`

4. **Intelligently merge settings**:
   - If no existing settings exist, use the template
   - If settings exist, merge the required hooks without overwriting existing configuration
   - Preserve existing hooks and add sound hooks
   - Set the specified soundTheme (or default if none provided)
   - If user already has a soundTheme configured, ask before changing it

## Theme Validation Logic

1. If theme argument matches exactly → use it
2. If theme argument is similar to existing theme → confirm with user
3. If theme argument doesn't match any theme → show available themes and ask user to choose
4. If no theme argument → use "default"

## Requirements

- Ensure the Claude Code directory exists at `~/.claude/`
- Verify all source files are present in the current directory  
- Handle existing settings gracefully without data loss
- Validate theme exists before configuring it
- Provide clear feedback on theme selection and installation

## Success Criteria

- Sound player script is executable at `~/.claude/themed-sound-player.sh`
- Sound themes are available at `~/.claude/sound-themes/`
- Settings.json contains the required hooks for Notification and Stop events
- Correct theme is configured in settings.json
- Existing user configuration is preserved
- User knows which theme is active and how to change it

Please perform this installation now with intelligent theme validation and settings merging.