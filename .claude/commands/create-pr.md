---
allowed-tools: Bash(*), Read(*), Edit(*), Write(*)
description: Create pull request with intelligent validation and customized descriptions based on contribution type
---

# Create Pull Request for Claude Code Sound Themes

Creates a pull request with intelligent analysis of changes and customized descriptions based on the type of contribution (theme, code, documentation).

## Usage

- `/project:create-pr` - Analyze changes and create PR with appropriate description
- `/project:create-pr "Custom PR title"` - Create PR with custom title

## Current Environment

- Current branch: !`git branch --show-current`
- Git status: !`git status --porcelain`
- Uncommitted changes: !`git diff --name-only`
- Staged changes: !`git diff --cached --name-only`
- Recent commits on branch: !`git log --oneline -5`
- Compare with main: !`git diff main...HEAD --name-only`

## Arguments

Custom PR title: $ARGUMENTS

## Pre-Flight Validation

The command performs comprehensive validation before creating the PR:

### 1. **Sensitive File Detection**
Warns if these sensitive files are modified:
- `CLAUDE.md` - Technical documentation (requires careful review)
- `.claude/commands/*` - Slash commands (potential security implications)
- `settings-template.json` - Core configuration template
- `themed-sound-player.sh` - Core script (extensive testing required)

### 2. **Contribution Type Analysis**
Automatically detects contribution type based on changed files:

**Theme Contribution**: New or modified files in `sound-themes/`
- Validates theme structure and naming conventions
- Checks for required README.md files
- Verifies sound file naming patterns (`name-volume.extension`)
- Ensures proper directory structure (default/, stop/, bash/, etc.)

**Code Contribution**: Changes to core scripts or commands
- Validates bash syntax where applicable
- Checks for breaking changes
- Warns about cross-platform compatibility requirements

**Documentation Contribution**: Changes to .md files
- Validates markdown structure
- Checks for consistency with existing docs

### 3. **Quality Checks**
- Ensures proper git workflow (feature branch, not main)
- Validates commit messages follow project standards
- Checks for untracked files that should be included
- Verifies no sensitive information is accidentally committed

## PR Creation Process

### 1. **Branch Management**
- Ensures you're on a feature branch (not main)
- Creates feature branch if needed: `feature/contribution-type-timestamp`
- Pushes branch to origin with tracking

### 2. **Change Analysis**
Analyzes all changes since diverging from main branch:
- Categorizes files by type (theme, code, docs)
- Identifies new themes vs modifications
- Detects potential breaking changes
- Counts files and lines changed

### 3. **PR Description Generation**
Creates customized PR descriptions based on contribution type:

**For Theme Contributions**:
```markdown
## New Sound Theme: [Theme Name]

### Theme Details
- **Name**: theme-name
- **Description**: [extracted from README]
- **Event Types**: default, stop, bash, write, read, edit
- **Sound Count**: X files
- **Formats**: .aiff, .mp3, .wav

### Checklist
- [x] Theme follows proper directory structure
- [x] All sounds follow naming convention (name-volume.extension)
- [x] README.md is complete and descriptive
- [x] Appropriate volume levels (50-95%)
- [x] Sounds are original or properly licensed
- [x] Tested locally with `/project:update-theme`
```

**For Code Contributions**:
```markdown
## Code Enhancement: [Feature Name]

### Changes Made
- [detailed list of modifications]

### Impact
- **Breaking Changes**: Yes/No
- **Platform Compatibility**: macOS/Linux/Windows
- **Dependencies**: [any new requirements]

### Testing
- [x] Manually tested on [platform]
- [x] Existing functionality verified
- [x] Edge cases considered
```

**For Documentation Contributions**:
```markdown
## Documentation Update

### Changes Made
- [list of documentation updates]

### Impact
- **User-facing**: Yes/No
- **Technical docs**: Yes/No
- **Examples updated**: Yes/No
```

### 4. **Warning System**
Issues warnings for:
- Modifications to `CLAUDE.md` or command files
- Large files or binary files without proper LFS
- Missing documentation for new features
- Potential security concerns in script changes
- Cross-platform compatibility issues

## GitHub Integration

Uses `gh` CLI to:
- Create PR with generated title and description
- Set appropriate labels based on contribution type
- Link to related issues if referenced in commits
- Set reviewers if specified in repository settings

## Success Criteria

- PR created with appropriate title and description
- All relevant files included in PR
- Proper branch workflow followed
- No sensitive information exposed
- Quality checks passed
- Contribution type correctly identified and documented

## Example Outputs

**Theme Contribution**:
```
✅ Detected: New theme contribution (retro-gaming)
✅ Theme structure validation passed
✅ Sound file naming conventions correct
⚠️  Large binary files detected - ensure they're necessary
✅ README.md present and complete
🚀 Created PR: "Add retro gaming sound theme with 8-bit arcade sounds"
```

**Code Contribution**:
```
⚠️  Sensitive file modified: themed-sound-player.sh
✅ Bash syntax validation passed
✅ No breaking changes detected
⚠️  Cross-platform testing recommended
🚀 Created PR: "Improve volume control for Linux systems"
```

**Mixed Contribution**:
```
✅ Detected: Mixed contribution (theme + documentation)
✅ All validations passed
ℹ️  Consider splitting into separate PRs for easier review
🚀 Created PR: "Add cyberpunk theme and update installation docs"
```

## Error Handling

- **No changes detected**: Prompts to stage changes first
- **On main branch**: Creates feature branch automatically
- **Sensitive file changes**: Requires explicit confirmation
- **Invalid theme structure**: Provides specific fixing guidance
- **Missing dependencies**: Guides user to install required tools

Please analyze the current changes and create an appropriate pull request now.