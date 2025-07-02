#!/bin/bash

# Themed notification sound player for Claude Code hooks
# Supports themes, random sound selection, and volume control
# Requires: jq (for JSON parsing), afplay (macOS)

# Get theme from settings.json
get_theme() {
  local settings_file="$HOME/.claude/settings.json"
  if [[ -f "$settings_file" ]] && command -v jq >/dev/null 2>&1; then
    jq -r '.soundTheme // "default"' "$settings_file" 2>/dev/null || echo "default"
  else
    echo "default"
  fi
}

# Parse volume from filename (e.g., "sound-75.mp3" -> 75)
parse_volume() {
  local filename="$1"
  local basename=$(basename "$filename")

  # Extract volume number from filename pattern: name-volume.ext
  if [[ "$basename" =~ -([0-9]+)\.[^.]+$ ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo "70" # default volume
  fi
}

# Cross-platform sound player with volume control
play_sound() {
  local sound_file="$1"
  local volume="$2"

  if [[ ! -f "$sound_file" ]]; then
    return 1
  fi

  # Convert volume (0-100) to decimal (0.0-1.0) for afplay
  local volume_decimal=$(echo "scale=2; $volume / 100" | bc 2>/dev/null || echo "0.7")

  # Detect platform and use appropriate sound player
  case "$(uname)" in
  "Darwin") # macOS
    afplay -v "$volume_decimal" "$sound_file" 2>/dev/null &
    ;;
  "Linux")
    # Try common Linux sound players with volume
    if command -v paplay >/dev/null 2>&1; then
      paplay --volume=$((volume * 655)) "$sound_file" 2>/dev/null &
    elif command -v aplay >/dev/null 2>&1; then
      aplay -q "$sound_file" 2>/dev/null &
    elif command -v play >/dev/null 2>&1; then
      play -q -v "$(echo "scale=2; $volume / 100" | bc)" "$sound_file" 2>/dev/null &
    fi
    ;;
  "CYGWIN"* | "MINGW"* | "MSYS"*) # Windows
    if command -v powershell.exe >/dev/null 2>&1; then
      # Windows volume control is more complex, play at default volume
      powershell.exe -c "(New-Object Media.SoundPlayer '$sound_file').Play()" 2>/dev/null &
    fi
    ;;
  esac
}

# Get random sound file from theme directory with fallback to default
get_random_sound() {
  local theme="$1"
  local event_type="$2"
  local theme_dir="$HOME/.claude/sound-themes/$theme/$event_type"

  # Try specific event type first
  local sound_files=()
  if [[ -d "$theme_dir" ]]; then
    while IFS= read -r -d '' file; do
      sound_files+=("$file")
    done < <(find "$theme_dir" -type f \( -name "*.aiff" -o -name "*.wav" -o -name "*.mp3" -o -name "*.m4a" -o -name "*.ogg" \) -print0 2>/dev/null)
  fi

  # If no sounds found for specific event type, try default folder
  if [[ ${#sound_files[@]} -eq 0 ]]; then
    local default_dir="$HOME/.claude/sound-themes/$theme/default"
    if [[ -d "$default_dir" ]]; then
      while IFS= read -r -d '' file; do
        sound_files+=("$file")
      done < <(find "$default_dir" -type f \( -name "*.aiff" -o -name "*.wav" -o -name "*.mp3" -o -name "*.m4a" -o -name "*.ogg" \) -print0 2>/dev/null)
    fi
  fi

  if [[ ${#sound_files[@]} -eq 0 ]]; then
    return 1
  fi

  # Select random file
  local random_index=$((RANDOM % ${#sound_files[@]}))
  echo "${sound_files[$random_index]}"
}

# Determine event type from notification message
determine_event_type() {
  local message="$1"
  local message_lower
  message_lower=$(echo "$message" | tr '[:upper:]' '[:lower:]')

  if [[ "$message_lower" == *"permission"* ]]; then
    if [[ "$message_lower" == *"bash"* ]]; then
      echo "bash"
    elif [[ "$message_lower" == *"write"* ]]; then
      echo "write"
    elif [[ "$message_lower" == *"read"* ]]; then
      echo "read"
    elif [[ "$message_lower" == *"edit"* || "$message_lower" == *"update"* ]]; then
      echo "edit"
    else
      echo "default"
    fi
  else
    echo "default"
  fi
}

# Main execution
main() {
  # Get event type from command line argument
  local hook_type="$1"

  # Validate hook type
  if [[ "$hook_type" != "notification" && "$hook_type" != "stop" ]]; then
    exit 1
  fi

  # Get current theme
  local theme
  theme=$(get_theme)

  local event_type
  local message=""

  if [[ "$hook_type" == "stop" ]]; then
    # Stop event - use stop sounds
    event_type="stop"
    message="Stop event"
  else
    # Notification event - parse message to determine specific event type
    if ! command -v jq >/dev/null 2>&1; then
      exit 1
    fi

    # Read JSON from stdin
    local json_input
    json_input=$(cat)

    # Extract message from JSON with robust error handling
    if [[ -n "$json_input" ]]; then
      message=$(echo "$json_input" | jq -r '.message // ""' 2>/dev/null || echo "")
    else
      message=""
    fi

    if [[ -z "$message" ]]; then
      event_type="default"
      message="Unknown notification"
    else
      event_type=$(determine_event_type "$message")
    fi
  fi

  # Get random sound file for this event type
  local sound_file
  sound_file=$(get_random_sound "$theme" "$event_type")

  if [[ $? -ne 0 ]]; then
    exit 0
  fi

  # Parse volume from filename
  local volume
  volume=$(parse_volume "$sound_file")

  # Play the sound
  play_sound "$sound_file" "$volume"

  # Log for debugging
  echo "$(date): $theme/$event_type - $(basename "$sound_file") @ ${volume}% - $message" >>~/.claude/sound-log.txt
}

main "$@"

