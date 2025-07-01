---
allowed-tools: Bash(*), Read(*), Edit(*), Write(*)
description: Update to a new theme with intelligent repo syncing and validation
---

# Update Sound Theme

Switch to a new sound theme with intelligent repository updates and validation.

## Usage

```
/project:update-theme theme-name
```

## Arguments

Target theme: $ARGUMENTS

## Current Environment

- Current working directory: !`pwd`
- Git repository status: !`git status --porcelain 2>/dev/null | wc -l | tr -d ' '` uncommitted changes
- Current branch: !`git branch --show-current 2>/dev/null || echo "not a git repo"`
- Repository is up to date: !`git fetch 2>/dev/null && git status -uno | grep -q "up to date" && echo "YES" || echo "NO"`
- Currently available themes: !`find sound-themes -maxdepth 1 -type d -not -name sound-themes -not -name ".*" | sed 's|sound-themes/||' | sort`
- Current theme in settings: !`test -f ~/.claude/settings.json && jq -r '.soundTheme // "not set"' ~/.claude/settings.json 2>/dev/null || echo "no settings file"`

## Validation and Update Workflow

### Phase 1: Initial Theme Validation
1. **Check if theme exists locally**:
   - If exact match found → proceed to Phase 2 (Local Changes Check)
   - If similar match found → ask user for confirmation, then proceed to Phase 2
   - If no match found → proceed to Phase 3 (Repository Update)

### Phase 2: Local Changes Detection
2. **Check for local customizations**:
   - Compare local theme files with git HEAD
   - Detect renamed files (volume changes), added files, modified files
   - If no local changes → proceed to Phase 4 (Theme Switch)
   - If local changes found → proceed to Phase 3 (Git Workflow)

### Phase 3: Repository Update & Git Workflow
3. **Handle local customizations**:
   - **Warn user about local changes**: Show what's been modified
   - **Offer choices**:
     - A) Create personal branch and rebase (recommended)
     - B) Overwrite local changes with repo version
     - C) Cancel and keep current state
   
4. **Personal branch workflow** (if user chooses A):
   - Create branch: `personal-customizations-$(whoami)` or similar
   - Commit local changes to personal branch
   - Switch back to main branch
   - Pull latest changes from remote
   - Switch to personal branch and rebase onto updated main
   - Handle merge conflicts interactively if needed

5. **Repository update**:
   - Fetch latest changes from remote
   - Pull latest changes (handle conflicts if any)
   - Re-scan available themes after update

6. **Re-validate theme after update**:
   - Check if theme now exists (for new themes)
   - If still not found, suggest similar themes or list all available themes

### Phase 4: Theme Deployment
7. **Deploy theme to Claude directory**:
   - Copy theme files from current branch to `~/.claude/sound-themes/`
   - Update theme setting in `~/.claude/settings.json`
   - Preserve all other settings

### Phase 5: Confirmation & Guidance
8. **Provide feedback**:
   - Confirm theme has been updated
   - Show what changed (repository updates, branch created, conflicts resolved)
   - Show current branch status if personal branch was created
   - Remind user to restart Claude Code if needed
   - Provide guidance on managing personal branch going forward

## Safety Measures

- **Git Safety**: Always preserve local changes via branching before pulling
- **Settings Safety**: Always preserve existing settings when updating theme
- **Branch Safety**: Personal branches are never pushed to remote by default
- **Validation**: Multiple rounds of theme validation before giving up
- **User Control**: Ask for confirmation before major actions (repo pulls, branch creation, rebasing)
- **Conflict Resolution**: Interactive merge conflict resolution with clear guidance

## Error Handling

- **No git repository**: Inform user and proceed with local theme validation only
- **Network issues**: Handle git fetch/pull failures gracefully
- **Merge conflicts**: Provide step-by-step conflict resolution guidance
- **Branch creation failures**: Fallback to simple overwrite with user confirmation
- **Permission issues**: Guide user on fixing file permissions
- **Rebase failures**: Help user resolve conflicts or abort safely

## Required Actions

Please perform the theme update with the following sophisticated workflow:

1. **Validate theme name**: "$ARGUMENTS" with fuzzy matching
2. **Check for local customizations**: Compare working directory with git HEAD
3. **If local changes detected**:
   - Show user what's been modified (files renamed, added, changed)
   - Offer three clear choices: A) Personal branch + rebase, B) Overwrite, C) Cancel
   - If user chooses A, create personal branch workflow
4. **Repository update**: Fetch and pull latest changes safely
5. **Personal branch management**:
   - Create branch: `personal-$(whoami)-$(date +%Y%m%d)` or similar
   - Commit local changes with descriptive message
   - Rebase personal branch onto updated main
   - Handle conflicts interactively with clear guidance
6. **Deploy theme**: Copy from current branch to Claude directory
7. **Provide comprehensive feedback**: Branch status, conflicts resolved, next steps

**Key Principles**:
- Never lose user's customizations
- Always ask before destructive operations  
- Provide clear git workflow guidance
- Handle merge conflicts gracefully
- Give users control over their personal branches