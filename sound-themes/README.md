# Claude Code Sound Themes

A collection of sound themes for Claude Code notification hooks.

## Theme Structure

Each theme is a directory containing subdirectories for different event types:

```
your-theme-name/
├── bash/           # Bash tool permission sounds
├── write/          # Write tool permission sounds  
├── read/           # Read tool permission sounds
├── edit/           # Edit tool permission sounds
├── default/        # Default/fallback sounds
└── stop/           # Completion/stop sounds
```

## File Naming Convention

Files should be named with the pattern: `description-volume.extension`

- **description**: Brief description of the sound
- **volume**: Volume level (0-100)
- **extension**: Audio file format (.aiff, .wav, .mp3, .m4a, .ogg)

Examples:
- `lightsaber-on-80.mp3` (plays at 80% volume)
- `r2d2-beep-65.wav` (plays at 65% volume)
- `completion-75.aiff` (plays at 75% volume)

## Supported Audio Formats

- **macOS**: .aiff, .wav, .mp3, .m4a, .ogg
- **Linux**: .wav, .ogg (depends on installed players)
- **Windows**: .wav (recommended for best compatibility)

## Random Selection

If multiple files exist in an event directory, one will be chosen randomly each time the event occurs.

## Installation

1. Copy your theme directory to `~/.claude/sound-themes/`
2. Update `soundTheme` in `~/.claude/settings.json` to your theme name
3. Restart Claude Code for changes to take effect

## Theme Configuration

Edit `~/.claude/settings.json`:

```json
{
  "soundTheme": "your-theme-name",
  "hooks": {
    // ... existing hooks
  }
}
```

## Contributing Themes

1. Create your theme directory following the structure above
2. Test all sounds work correctly
3. Include a brief description of your theme
4. Submit as a pull request or share with the community

## Example Themes

### Default Theme
Classic macOS system sounds with balanced volume levels.

### Star Wars Theme (Example)
```
star-wars/
├── bash/
│   ├── lightsaber-on-80.mp3
│   └── r2d2-beep-70.wav
├── stop/
│   └── force-theme-65.mp3
└── default/
    └── c3po-alert-75.wav
```

## Volume Guidelines

- **50-60%**: Quiet, subtle sounds
- **70-80%**: Normal notification volume
- **90-100%**: Loud, attention-grabbing sounds
- **100%+**: Amplification for normalizing quiet recordings

**Amplification Examples:**
- `quiet-recording-120.mp3` - Boost soft audio by 20%
- `whisper-sound-200.wav` - Double volume for very quiet sounds
- `normalize-150.aiff` - 50% amplification for consistent levels

Test your volumes in a quiet environment to ensure they're not too jarring.

## Troubleshooting

- Ensure file permissions allow reading: `chmod 644 sound-files`
- Check the sound log: `tail -f ~/.claude/sound-log.txt`
- Verify theme directory exists and has correct structure
- Test individual files with your system's audio player

## Advanced Features

### Multiple Random Sounds
Place multiple files in any event directory for random selection:

```
bash/
├── option1-75.mp3
├── option2-80.wav
└── option3-70.aiff
```

### Volume Balancing
Different sounds may need different volume levels. Test and adjust the volume number in filenames accordingly.