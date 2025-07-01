---
allowed-tools: Bash(*), Read(*), Edit(*), Write(*), MultiEdit(*)
description: Create a new sound theme with customizable event types
---

# Create New Sound Theme

Create a new sound theme with customizable directory structure based on which events you want to support.

## Usage

```
/project:create-theme theme-name "Theme Description"
/project:create-theme theme-name "Description" default,stop
/project:create-theme theme-name "Description" default,stop,bash
```

## Arguments

Theme parameters: $ARGUMENTS

Expected format: `theme-name "Optional description" optional,event,types`

## Current Environment

- Current working directory: !`pwd`
- Existing themes: !`find sound-themes -maxdepth 1 -type d -not -name sound-themes -not -name ".*" | sed 's|sound-themes/||' | sort`
- Git repository status: !`git status --porcelain 2>/dev/null | wc -l | tr -d ' '` uncommitted changes
- Available event types: !`find sound-themes -mindepth 2 -maxdepth 2 -type d -not -name ".*" | sed 's|sound-themes/[^/]*/||' | sort -u`

## Theme Creation Workflow

### Phase 1: Input Validation
1. **Parse arguments**:
   - Extract theme name (required)
   - Extract description (optional)
   - Extract event types (optional, defaults to "default,stop")
   - Validate theme name format and check conflicts

### Phase 2: Event Type Discovery and Selection
2. **Determine available event types**:
   - Scan existing themes to discover all possible event types
   - Always ensure "default" is available (it's the fallback)
   - Validate requested event types against discovered options
   - Show available options if user requests unknown event type

### Phase 3: Directory Structure Creation
3. **Create minimal theme structure**:
   ```
   sound-themes/theme-name/
   ├── default/        # Always created (fallback sounds)
   ├── [selected]/     # Only requested event types
   └── README.md       # Theme documentation
   ```

### Phase 4: Documentation Generation
4. **Generate README.md** with:
   - Theme name and description
   - Which events are supported
   - File naming convention guidance
   - Volume level recommendations
   - Testing instructions using `/project:update-theme`
   - Credits/attribution section

### Phase 5: Development Guidance
5. **Provide focused next steps**:
   - Show which directories were created
   - Explain minimum requirements (at least one sound in default/)
   - File naming examples for each event type
   - Testing workflow instructions

## Input Processing

### Default Behavior (no event types specified)
- Creates: `default/` and `stop/` directories
- Most common use case for simple themes

### Custom Event Types
- Parse comma-separated list from available event types
- Always include `default/` even if not specified
- Validate each event type against discovered options
- Create only requested directories

## Theme Structure Examples

### Minimal Theme (default behavior)
```
my-theme/
├── default/        # Required: at least one sound file
├── stop/           # Popular choice: completion sounds
└── README.md
```

### Custom Theme
```
coding-sounds/
├── default/        # Always included
├── bash/           # If requested and available
├── write/          # If requested and available
└── README.md
```

## File Naming Convention
- Pattern: `description-volume.extension`
- Volume: 0-100 (e.g., `notification-75.mp3`)
- Supported formats: .aiff, .wav, .mp3, .m4a, .ogg

## User Interaction Flow

1. **Parse and validate inputs**
2. **Discover available event types** from existing themes
3. **Validate requested event types** or show available options
4. **Show creation plan** with selected event types
5. **Create directories** with .gitkeep files
6. **Generate README** with specific guidance
7. **Provide development instructions** for selected events

## Success Criteria

- Theme directory created with requested event types only
- README.md with focused guidance for selected events
- Clear instructions for minimum requirements
- Testing workflow provided
- No unnecessary empty directories
- Dynamic event type discovery

## Required Actions

Please create the new theme with the following workflow:

1. Parse theme name, description, and event types from: "$ARGUMENTS"
2. Discover available event types from existing themes
3. Default to "default,stop" if no event types specified
4. Always ensure "default" is included (it's the fallback)
5. Validate requested event types against available options
6. Show creation plan with selected event types
7. Create minimal directory structure
8. Generate focused README.md
9. Provide clear next steps for adding sound files

Make the theme creation adaptive to the actual event types available in the repository.