# Claude Code Sound Themes

A customizable sound notification system for Claude Code hooks that plays different sounds for different events.

## Features

🎨 **Theme Support** - Switch between different sound themes  
🎲 **Random Selection** - Multiple sounds per event for variety  
🔊 **Volume Control** - Set volume levels via filename  
🌍 **Cross-Platform** - Works on macOS, Linux, and Windows  
📁 **Easy Contribution** - Simple directory structure for creating themes  

## Quick Start

1. **Install using Claude Code**:
   ```
   /project:install
   ```
   Or install with a specific theme:
   ```
   /project:install star-wars
   ```
   This intelligently merges the sound hooks with your existing Claude Code settings and validates theme selection.

2. **Restart Claude Code** for the hooks to take effect

## How It Works

### Event Types

- **bash/** - Bash tool permission sounds
- **write/** - Write tool permission sounds  
- **read/** - Read tool permission sounds
- **edit/** - Edit tool permission sounds
- **stop/** - Completion sounds (when Claude finishes responding)
- **default/** - Fallback sounds for any missing event types

### Sound Selection

1. **Specific event** - Tries the specific folder (e.g., `bash/`)
2. **Fallback** - Uses `default/` folder if specific folder is empty
3. **Random** - If multiple files exist, one is chosen randomly

### Volume Control

Name your sound files with volume levels:
- `sound-75.mp3` - Plays at 75% volume
- `notification.wav` - Plays at 70% (default)
- `alert-90.aiff` - Plays at 90% volume
- `quiet-150.mp3` - Amplifies quiet sounds to 150% (useful for normalizing soft recordings)

## Creating Themes

Use the intelligent theme creation command:

```
/project:create-theme my-theme "Description" default,stop,bash
```

This automatically:
- Creates proper directory structure for specified event types
- Generates comprehensive README template
- Sets up development workflow
- Provides testing guidance

### Theme Structure
The command creates only the directories you need:
```
your-theme/
├── default/        # Always created (required fallback)
├── stop/           # Created by default (popular choice)  
├── bash/           # Optional: Only if requested
├── [other-events]/ # Only event types you specify
└── README.md       # Generated automatically
```

### Supported Formats
- **macOS**: .aiff, .wav, .mp3, .m4a, .ogg
- **Linux**: .wav, .ogg (depends on installed audio players)
- **Windows**: .wav (recommended for best compatibility)

## Theme Configuration

Change themes by updating the `soundTheme` setting in `~/.claude/settings.json`:

```json
{
  "soundTheme": "star-wars",
  "hooks": {
    // ... your hooks
  }
}
```

## Manual Hook Configuration

The `/project:install` command handles this automatically, but if you need to configure manually, add these hooks to your `~/.claude/settings.json`:

```json
{
  "soundTheme": "default",
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "comment": "Sound player - plays different sounds for different notification types",
            "command": "bash ~/.claude/themed-sound-player.sh notification"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "comment": "Sound player - plays completion sound when Claude stops responding", 
            "command": "bash ~/.claude/themed-sound-player.sh stop"
          }
        ]
      }
    ]
  }
}
```

**Important**: If you already have hooks, add these to your existing hook arrays rather than replacing them.

## Installation

Use Claude Code's intelligent installation command:

```
/project:install
```

Or install with a specific theme:

```
/project:install theme-name
```

This handles intelligent settings merging, theme validation, and preserves your existing configuration. If you misspell a theme name, Claude will suggest similar themes for confirmation.

### Updating Themes

Switch to a different theme or get the latest themes:

```
/project:update-theme star-wars
```

This command intelligently handles:
- Local theme validation with fuzzy matching
- Repository updates when themes aren't found locally  
- Git safety checks (uncommitted changes, network issues)
- User confirmation before major operations

### Creating Themes

Create a new theme with customizable event types:

```
/project:create-theme my-theme "Cool sounds theme"
/project:create-theme retro-game "8-bit gaming sounds" default,stop,bash
```

This command:
- Dynamically discovers available event types from existing themes
- Creates minimal directory structure (defaults to default + stop events)
- Generates comprehensive README template
- Provides clear development workflow guidance

## Troubleshooting

- **No sounds playing**: Check that the script path is correct in settings.json
- **Permission errors**: The script uses `bash` explicitly, so no chmod needed
- **Wrong sounds**: Verify your theme name matches the directory name
- **Volume issues**: Adjust the volume numbers in filenames

## Contributing

### Creating New Themes

1. **Use the theme creation command**:
   ```
   /project:create-theme your-theme-name "Cool theme description"
   ```
   This creates the proper directory structure and README template automatically.

2. **Add your sound files** to the created directories following the naming convention:
   - `description-volume.extension` (e.g., `alert-75.mp3`)
   - At least one file in the `default/` directory is required

3. **Test your theme**:
   ```
   /project:update-theme your-theme-name
   ```
   This installs your theme locally for testing.

4. **Submit your contribution**:
   - The create command can help set up git workflow for contributions
   - Test all sounds work correctly across different volume levels
   - Ensure your theme README is complete
   - Submit a pull request with your new theme

## Examples

Check out the included themes:
- **default** - Classic macOS system sounds with balanced volume levels
- **darth-vader** - Star Wars Darth Vader themed sounds
- **TEMPLATE** - Reference structure for understanding theme organization

To explore available themes: `/project:update-theme` will show all current options.

## License

MIT License - feel free to use and modify!