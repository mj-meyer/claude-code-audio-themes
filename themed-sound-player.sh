#!/bin/bash

# Themed notification sound player for Claude Code hooks
# Supports themes, random sound selection, and volume control
# Dependencies: jq (for JSON parsing), bc (for volume calculations), platform-specific audio players

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="$HOME/.claude/sound-log.txt"
readonly MAX_JSON_TIMEOUT=5

# Error codes
readonly E_DEPENDENCY_MISSING=2
readonly E_FILE_NOT_FOUND=3
readonly E_FILE_NOT_READABLE=4
readonly E_INVALID_VOLUME=5
readonly E_PLATFORM_UNSUPPORTED=6
readonly E_JSON_PARSE_ERROR=7
readonly E_NETWORK_TIMEOUT=8
readonly E_INVALID_ARGS=9

# Logging function
log_message() {
  local level="$1"
  local message="$2"
  # Only output to stderr for ERROR level
  if [[ "$level" == "ERROR" ]]; then
    echo "[$level] $SCRIPT_NAME: $message" >&2
  fi
  # Always log to file if possible
  if [[ -w "$(dirname "$LOG_FILE")" ]] 2>/dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE" 2>/dev/null
  fi
}

# Check for required dependencies
check_dependencies() {
  local missing_deps=()
  
  # Check for jq (required for JSON parsing)
  if ! command -v jq >/dev/null 2>&1; then
    missing_deps+=("jq")
  fi
  
  # Check for bc (required for volume calculations)
  if ! command -v bc >/dev/null 2>&1; then
    missing_deps+=("bc")
  fi
  
  # Check for platform-specific audio players
  local platform_support=false
  case "$(uname 2>/dev/null || echo 'unknown')" in
    "Darwin") # macOS
      if command -v afplay >/dev/null 2>&1; then
        platform_support=true
      else
        missing_deps+=("afplay")
      fi
      ;;
    "Linux")
      if command -v paplay >/dev/null 2>&1 || command -v aplay >/dev/null 2>&1 || command -v play >/dev/null 2>&1; then
        platform_support=true
      else
        missing_deps+=("paplay, aplay, or play (sox)")
      fi
      ;;
    "CYGWIN"*|"MINGW"*|"MSYS"*) # Windows
      if command -v powershell.exe >/dev/null 2>&1; then
        platform_support=true
      else
        missing_deps+=("powershell.exe")
      fi
      ;;
    *)
      log_message "ERROR" "Unsupported platform: $(uname 2>/dev/null || echo 'unknown')"
      return $E_PLATFORM_UNSUPPORTED
      ;;
  esac
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_message "ERROR" "Missing required dependencies: ${missing_deps[*]}"
    log_message "INFO" "Installation instructions:"
    for dep in "${missing_deps[@]}"; do
      case "$dep" in
        "jq")
          log_message "INFO" "  - Install jq: https://stedolan.github.io/jq/download/"
          ;;
        "bc")
          log_message "INFO" "  - Install bc: Usually available in system package manager"
          ;;
        "afplay")
          log_message "INFO" "  - afplay should be available on macOS by default"
          ;;
        "paplay, aplay, or play (sox)")
          log_message "INFO" "  - Install pulseaudio-utils (paplay), alsa-utils (aplay), or sox (play)"
          ;;
        "powershell.exe")
          log_message "INFO" "  - PowerShell should be available on Windows by default"
          ;;
      esac
    done
    return $E_DEPENDENCY_MISSING
  fi
  
  return 0
}

# Get theme from settings.json with robust error handling
get_theme() {
  local settings_file="$HOME/.claude/settings.json"
  local theme="default"
  
  # Check if settings file exists and is readable
  if [[ ! -f "$settings_file" ]]; then
    log_message "DEBUG" "Settings file not found: $settings_file, using default theme"
    echo "default"
    return 0
  fi
  
  if [[ ! -r "$settings_file" ]]; then
    log_message "WARN" "Settings file not readable: $settings_file, using default theme"
    echo "default"
    return 0
  fi
  
  # Check file size to prevent processing extremely large files
  local file_size
  if command -v stat >/dev/null 2>&1; then
    file_size=$(stat -f%z "$settings_file" 2>/dev/null || stat -c%s "$settings_file" 2>/dev/null || echo "0")
    if [[ "$file_size" -gt 1048576 ]]; then # 1MB limit
      log_message "WARN" "Settings file too large (${file_size} bytes), using default theme"
      echo "default"
      return 0
    fi
  fi
  
  # Parse JSON with timeout and error handling
  local json_result
  if command -v timeout >/dev/null 2>&1; then
    json_result=$(timeout $MAX_JSON_TIMEOUT jq -r '.soundTheme // "default"' "$settings_file" 2>/dev/null)
  else
    json_result=$(jq -r '.soundTheme // "default"' "$settings_file" 2>/dev/null)
  fi
  
  local jq_exit_code=$?
  
  if [[ $jq_exit_code -eq 124 ]]; then
    log_message "WARN" "JSON parsing timed out after ${MAX_JSON_TIMEOUT}s, using default theme"
    echo "default"
    return 0
  elif [[ $jq_exit_code -ne 0 ]]; then
    log_message "WARN" "Failed to parse settings JSON (exit code: $jq_exit_code), using default theme"
    echo "default"
    return 0
  fi
  
  # Validate theme name (alphanumeric, dash, underscore only)
  if [[ -n "$json_result" && "$json_result" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "$json_result"
  else
    log_message "WARN" "Invalid theme name '$json_result', using default theme"
    echo "default"
  fi
}

# Parse volume from filename with robust error handling (e.g., "sound-75.mp3" -> 75)
parse_volume() {
  local filename="$1"
  local default_volume="70"
  
  if [[ -z "$filename" ]]; then
    log_message "WARN" "Empty filename provided to parse_volume, using default volume $default_volume"
    echo "$default_volume"
    return 0
  fi
  
  local basename
  basename=$(basename "$filename" 2>/dev/null)
  
  if [[ -z "$basename" ]]; then
    log_message "WARN" "Failed to get basename from '$filename', using default volume $default_volume"
    echo "$default_volume"
    return 0
  fi

  # Extract volume number from filename pattern: name-volume.ext
  if [[ "$basename" =~ -([0-9]+)\.[^.]+$ ]]; then
    local volume="${BASH_REMATCH[1]}"
    
    # Validate volume range (0-100)
    if [[ "$volume" =~ ^[0-9]+$ ]] && [[ "$volume" -ge 0 ]] && [[ "$volume" -le 100 ]]; then
      echo "$volume"
    else
      log_message "WARN" "Invalid volume '$volume' in filename '$basename', must be 0-100, using default $default_volume"
      echo "$default_volume"
    fi
  else
    log_message "DEBUG" "No volume found in filename '$basename', using default volume $default_volume"
    echo "$default_volume"
  fi
}

# Cross-platform sound player with robust error handling and volume control
play_sound() {
  local sound_file="$1"
  local volume="$2"
  
  # Input validation
  if [[ -z "$sound_file" ]]; then
    log_message "ERROR" "No sound file specified"
    return $E_FILE_NOT_FOUND
  fi
  
  if [[ -z "$volume" ]]; then
    log_message "WARN" "No volume specified, using default 70"
    volume="70"
  fi

  # Check if file exists
  if [[ ! -f "$sound_file" ]]; then
    log_message "ERROR" "Sound file not found: $sound_file"
    return $E_FILE_NOT_FOUND
  fi
  
  # Check if file is readable
  if [[ ! -r "$sound_file" ]]; then
    log_message "ERROR" "Sound file not readable: $sound_file (check permissions)"
    return $E_FILE_NOT_READABLE
  fi
  
  # Check file size (prevent attempting to play extremely large files)
  local file_size
  if command -v stat >/dev/null 2>&1; then
    file_size=$(stat -f%z "$sound_file" 2>/dev/null || stat -c%s "$sound_file" 2>/dev/null || echo "0")
    if [[ "$file_size" -gt 104857600 ]]; then # 100MB limit
      log_message "ERROR" "Sound file too large (${file_size} bytes): $sound_file"
      return $E_FILE_NOT_READABLE
    fi
    if [[ "$file_size" -eq 0 ]]; then
      log_message "ERROR" "Sound file is empty: $sound_file"
      return $E_FILE_NOT_READABLE
    fi
  fi

  # Validate volume
  if ! [[ "$volume" =~ ^[0-9]+$ ]] || [[ "$volume" -lt 0 ]] || [[ "$volume" -gt 100 ]]; then
    log_message "ERROR" "Invalid volume '$volume', must be 0-100"
    return $E_INVALID_VOLUME
  fi

  # Convert volume (0-100) to decimal (0.0-1.0) for macOS and some Linux players
  local volume_decimal
  if command -v bc >/dev/null 2>&1; then
    volume_decimal=$(echo "scale=2; $volume / 100" | bc 2>/dev/null)
    if [[ -z "$volume_decimal" || ! "$volume_decimal" =~ ^[0-9]*\.?[0-9]+$ ]]; then
      log_message "WARN" "Failed to calculate volume decimal, using 0.7"
      volume_decimal="0.7"
    fi
  else
    log_message "WARN" "bc not available for volume calculation, using default 0.7"
    volume_decimal="0.7"
  fi

  # Detect platform and use appropriate sound player
  local platform
  platform=$(uname 2>/dev/null || echo 'unknown')
  
  case "$platform" in
  "Darwin") # macOS
    if command -v afplay >/dev/null 2>&1; then
      log_message "DEBUG" "Playing sound with afplay: $sound_file @ ${volume}%"
      if ! afplay -v "$volume_decimal" "$sound_file" 2>/dev/null &; then
        log_message "ERROR" "Failed to play sound with afplay: $sound_file"
        return 1
      fi
    else
      log_message "ERROR" "afplay not found on macOS"
      return $E_DEPENDENCY_MISSING
    fi
    ;;
  "Linux")
    local player_used=false
    
    # Try paplay (PulseAudio)
    if command -v paplay >/dev/null 2>&1; then
      log_message "DEBUG" "Playing sound with paplay: $sound_file @ ${volume}%"
      local pa_volume=$((volume * 655)) # PulseAudio volume scale
      if paplay --volume="$pa_volume" "$sound_file" 2>/dev/null &; then
        player_used=true
      else
        log_message "WARN" "paplay failed, trying next player"
      fi
    fi
    
    # Try aplay (ALSA) if paplay failed or not available
    if [[ "$player_used" == false ]] && command -v aplay >/dev/null 2>&1; then
      log_message "DEBUG" "Playing sound with aplay: $sound_file (volume control not supported)"
      if aplay -q "$sound_file" 2>/dev/null &; then
        player_used=true
      else
        log_message "WARN" "aplay failed, trying next player"
      fi
    fi
    
    # Try play (sox) if other players failed or not available
    if [[ "$player_used" == false ]] && command -v play >/dev/null 2>&1; then
      log_message "DEBUG" "Playing sound with play (sox): $sound_file @ ${volume}%"
      if play -q -v "$volume_decimal" "$sound_file" 2>/dev/null &; then
        player_used=true
      else
        log_message "WARN" "play (sox) failed"
      fi
    fi
    
    if [[ "$player_used" == false ]]; then
      log_message "ERROR" "No working sound player found on Linux (tried paplay, aplay, play)"
      return $E_DEPENDENCY_MISSING
    fi
    ;;
  "CYGWIN"*|"MINGW"*|"MSYS"*) # Windows
    if command -v powershell.exe >/dev/null 2>&1; then
      log_message "DEBUG" "Playing sound with PowerShell: $sound_file (volume control not supported)"
      # Convert path for Windows if needed
      local win_path="$sound_file"
      if [[ "$sound_file" == /cygdrive/* ]] || [[ "$sound_file" == /mnt/* ]]; then
        # Convert Unix-style path to Windows path for WSL/Cygwin
        win_path=$(cygpath -w "$sound_file" 2>/dev/null || echo "$sound_file")
      fi
      
      if ! powershell.exe -c "(New-Object Media.SoundPlayer '$win_path').PlaySync()" 2>/dev/null &; then
        log_message "ERROR" "Failed to play sound with PowerShell: $sound_file"
        return 1
      fi
    else
      log_message "ERROR" "PowerShell not found on Windows"
      return $E_DEPENDENCY_MISSING
    fi
    ;;
  *)
    log_message "ERROR" "Unsupported platform: $platform"
    return $E_PLATFORM_UNSUPPORTED
    ;;
  esac
  
  log_message "DEBUG" "Successfully started playing: $(basename "$sound_file") @ ${volume}%"
  return 0
}

# Get random sound file from theme directory with robust error handling and fallbacks
get_random_sound() {
  local theme="$1"
  local event_type="$2"
  
  # Input validation
  if [[ -z "$theme" ]]; then
    log_message "WARN" "No theme specified, using 'default'"
    theme="default"
  fi
  
  if [[ -z "$event_type" ]]; then
    log_message "WARN" "No event type specified, using 'default'"
    event_type="default"
  fi
  
  # Validate theme and event_type names (security: prevent path traversal)
  if [[ ! "$theme" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_message "ERROR" "Invalid theme name '$theme', must contain only alphanumeric, dash, and underscore characters"
    return $E_INVALID_ARGS
  fi
  
  if [[ ! "$event_type" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_message "ERROR" "Invalid event type '$event_type', must contain only alphanumeric, dash, and underscore characters"
    return $E_INVALID_ARGS
  fi
  
  local base_dir="$HOME/.claude/sound-themes"
  local theme_dir="$base_dir/$theme/$event_type"
  local fallback_dirs=(
    "$base_dir/$theme/default"
    "$base_dir/default/$event_type" 
    "$base_dir/default/default"
  )
  
  # Check if base directory exists
  if [[ ! -d "$base_dir" ]]; then
    log_message "ERROR" "Sound themes directory not found: $base_dir"
    return $E_FILE_NOT_FOUND
  fi
  
  # Check if base directory is readable
  if [[ ! -r "$base_dir" ]]; then
    log_message "ERROR" "Sound themes directory not readable: $base_dir"
    return $E_FILE_NOT_READABLE
  fi

  local sound_files=()
  local search_dirs=("$theme_dir" "${fallback_dirs[@]}")
  local supported_extensions=("aiff" "wav" "mp3" "m4a" "ogg" "flac" "aac")
  
  # Build find expression for supported audio formats
  local find_expr=()
  for ext in "${supported_extensions[@]}"; do
    find_expr+=("-name" "*.$ext" "-o")
  done
  # Remove the last "-o"
  unset 'find_expr[-1]'

  # Try each directory in order of preference
  for search_dir in "${search_dirs[@]}"; do
    if [[ -d "$search_dir" && -r "$search_dir" ]]; then
      log_message "DEBUG" "Searching for sounds in: $search_dir"
      
      # Use timeout for find command to prevent hanging on network filesystems
      local find_cmd=(find "$search_dir" -type f \( "${find_expr[@]}" \) -print0)
      local find_result
      
      if command -v timeout >/dev/null 2>&1; then
        find_result=$(timeout 10 "${find_cmd[@]}" 2>/dev/null)
      else
        find_result=$("${find_cmd[@]}" 2>/dev/null)
      fi
      
      local find_exit_code=$?
      
      if [[ $find_exit_code -eq 124 ]]; then
        log_message "WARN" "Find command timed out in directory: $search_dir"
        continue
      elif [[ $find_exit_code -ne 0 ]]; then
        log_message "WARN" "Find command failed in directory: $search_dir"
        continue
      fi
      
      # Parse find results
      if [[ -n "$find_result" ]]; then
        while IFS= read -r -d '' file; do
          # Additional validation: check if file is readable and not empty
          if [[ -r "$file" ]]; then
            local file_size
            if command -v stat >/dev/null 2>&1; then
              file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "1")
              if [[ "$file_size" -gt 0 ]]; then
                sound_files+=("$file")
              else
                log_message "DEBUG" "Skipping empty file: $file"
              fi
            else
              # If stat is not available, assume file is valid
              sound_files+=("$file")
            fi
          else
            log_message "DEBUG" "Skipping unreadable file: $file"
          fi
        done <<< "$find_result"
        
        # If we found sounds in this directory, stop searching
        if [[ ${#sound_files[@]} -gt 0 ]]; then
          log_message "DEBUG" "Found ${#sound_files[@]} sound file(s) in: $search_dir"
          break
        fi
      fi
    else
      log_message "DEBUG" "Directory not accessible: $search_dir"
    fi
  done

  if [[ ${#sound_files[@]} -eq 0 ]]; then
    local searched_dirs="${search_dirs[*]}"
    log_message "ERROR" "No accessible sound files found in any of: $searched_dirs"
    log_message "INFO" "Supported formats: ${supported_extensions[*]}"
    log_message "INFO" "Make sure sound files exist and are readable in one of the searched directories"
    return $E_FILE_NOT_FOUND
  fi

  # Select random file with proper error handling
  local random_index
  if [[ ${#sound_files[@]} -eq 1 ]]; then
    random_index=0
  else
    # Use RANDOM with proper bounds checking
    random_index=$((RANDOM % ${#sound_files[@]}))
    if [[ $random_index -lt 0 || $random_index -ge ${#sound_files[@]} ]]; then
      log_message "WARN" "Random index out of bounds, using first file"
      random_index=0
    fi
  fi
  
  local selected_file="${sound_files[$random_index]}"
  log_message "DEBUG" "Selected sound file: $(basename "$selected_file") (${random_index}/${#sound_files[@]})"
  echo "$selected_file"
}

# Determine event type from notification message with error handling
determine_event_type() {
  local message="$1"
  
  # Handle empty or null message
  if [[ -z "$message" ]]; then
    log_message "DEBUG" "Empty message provided to determine_event_type, using 'default'"
    echo "default"
    return 0
  fi
  
  # Sanitize message (remove potential problematic characters, limit length)
  local sanitized_message
  sanitized_message=$(echo "$message" | tr -cd '[:print:]' | head -c 1000)
  
  if [[ -z "$sanitized_message" ]]; then
    log_message "DEBUG" "Message became empty after sanitization, using 'default'"
    echo "default"
    return 0
  fi
  
  local message_lower
  message_lower=$(echo "$sanitized_message" | tr '[:upper:]' '[:lower:]' 2>/dev/null)
  
  if [[ -z "$message_lower" ]]; then
    log_message "WARN" "Failed to convert message to lowercase, using 'default'"
    echo "default"
    return 0
  fi

  log_message "DEBUG" "Analyzing message for event type: $sanitized_message"
  
  # Pattern matching for event types
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
  elif [[ "$message_lower" == *"error"* || "$message_lower" == *"fail"* ]]; then
    echo "error"
  elif [[ "$message_lower" == *"success"* || "$message_lower" == *"complete"* ]]; then
    echo "success"
  elif [[ "$message_lower" == *"warning"* || "$message_lower" == *"warn"* ]]; then
    echo "warning"
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
    echo "Usage: $0 {notification|stop}" >&2
    echo "  notification - for Notification hook events" >&2
    echo "  stop - for Stop hook events" >&2
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
      # Silently fail - don't interrupt workflow
      exit 0
    fi

    # Read JSON from stdin
    local json_input
    json_input=$(cat)

    # Extract message from JSON - fail silently if issues
    if [[ -n "$json_input" ]]; then
      message=$(echo "$json_input" | jq -r '.message // ""' 2>/dev/null || echo "")
    else
      message=""
    fi

    if [[ -z "$message" ]]; then
      event_type="default"
      message="Unknown notification"
      # Silent - no warning logs for missing message
    else
      event_type=$(determine_event_type "$message")
      # Silent - no info logs during normal operation
    fi
  fi

  # Get random sound file for this event type
  local sound_file
  sound_file=$(get_random_sound "$theme" "$event_type")

  if [[ $? -ne 0 ]]; then
    # Silently fail - don't interrupt workflow
    exit 0
  fi

  # Parse volume from filename
  local volume
  volume=$(parse_volume "$sound_file")

  # Play the sound
  play_sound "$sound_file" "$volume"

  # Optional: Log for debugging
  echo "$(date): $theme/$event_type - $(basename "$sound_file") @ ${volume}% - $message" >>~/.claude/sound-log.txt
}

main "$@"

