# Contributing to Claude Code Sound Themes

Thank you for your interest in contributing to the Claude Code Sound Themes project! This repository provides a customizable sound notification system for Claude Code hooks, allowing users to hear different themed sounds for various coding events.

## Table of Contents

- [Getting Started](#getting-started)
- [Theme Contributions](#theme-contributions)
- [Code Contributions](#code-contributions)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Code Style Guidelines](#code-style-guidelines)
- [Issue Reporting](#issue-reporting)
- [Community Guidelines](#community-guidelines)

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- Claude Code installed and configured
- Basic knowledge of sound file formats and volume levels
- For code contributions: Bash scripting experience and Git knowledge

### Development Setup

1. **Fork and clone the repository**:
   ```bash
   git clone https://github.com/yourusername/claude-code-sound-themes.git
   cd claude-code-sound-themes
   ```

2. **Install the development version**:
   ```
   /project:install
   ```

3. **Test the installation**:
   - Restart Claude Code
   - Try using various tools to hear the sounds
   - Check the sound log: `tail -f ~/.claude/sound-log.txt`

## Theme Contributions

Creating new sound themes is the most common way to contribute to this project. We welcome themes of all types - from professional notification sounds to fun character-based themes.

### Creating a New Theme

Use the built-in theme creation command for the best experience:

```
/project:create-theme your-theme-name "Brief theme description"
```

For themes with specific event types:
```
/project:create-theme retro-gaming "8-bit arcade sounds" default,stop,bash,write
```

This command will:
- Create the proper directory structure
- Generate a comprehensive README template
- Discover available event types dynamically
- Provide clear development guidance

### Theme Structure

Your theme should follow this structure:
```
sound-themes/your-theme-name/
├── default/              # Required: fallback sounds
├── stop/                 # Recommended: completion sounds
├── bash/                 # Optional: bash tool sounds
├── write/                # Optional: write tool sounds
├── read/                 # Optional: read tool sounds
├── edit/                 # Optional: edit tool sounds
└── README.md             # Theme documentation
```

### Sound File Requirements

#### File Naming Convention
- **Pattern**: `description-volume.extension`
- **Volume**: 0-∞ (values >100% amplify quiet sounds)
- **Examples**: 
  - `notification-75.mp3` (plays at 75% volume)
  - `completion-80.aiff` (plays at 80% volume)
  - `quiet-sound-150.wav` (amplifies quiet sound to 150%)

#### Supported Formats
- **macOS**: .aiff, .wav, .mp3, .m4a, .ogg
- **Linux**: .wav, .ogg (depends on distribution)
- **Windows**: .wav (recommended for best compatibility)

#### Volume Guidelines
- **Quiet sounds**: 50-60% (background notifications)
- **Normal sounds**: 70-80% (standard notifications)
- **Attention sounds**: 85-95% (important events)
- **Amplified sounds**: 100-200% (for normalizing quiet recordings)

### Theme Requirements

1. **Minimum Content**:
   - At least one sound file in the `default/` directory
   - Complete README.md with theme description
   - Proper volume levels for all sounds

2. **Quality Standards**:
   - Sounds should be clear and professional
   - Consistent volume levels across the theme
   - No copyrighted material without proper licensing
   - Sounds should be appropriate for all audiences

3. **Documentation**:
   - Clear theme description
   - Attribution for sound sources
   - License information
   - Volume level explanations

### Testing Your Theme

1. **Install locally**:
   ```
   /project:update-theme your-theme-name
   ```

2. **Test all event types**:
   - Trigger bash tool permissions
   - Use read, write, and edit tools
   - Check completion sounds
   - Verify volume levels are appropriate

3. **Cross-platform testing** (if possible):
   - Test on different operating systems
   - Verify sound file compatibility
   - Check volume control behavior

### Theme Submission Checklist

- [ ] Theme directory follows proper structure
- [ ] At least one sound in `default/` directory
- [ ] All sound files follow naming convention
- [ ] README.md is complete and accurate
- [ ] Volume levels are appropriate and consistent
- [ ] Sounds are original or properly licensed
- [ ] Theme tested locally with `/project:update-theme`
- [ ] All files are appropriate for all audiences

## Code Contributions

We welcome improvements to the core sound system, installation scripts, and Claude Code integration.

### Areas for Contribution

1. **Core Sound System** (`themed-sound-player.sh`):
   - Cross-platform compatibility improvements
   - New sound format support
   - Volume control enhancements
   - Performance optimizations

2. **Installation System**:
   - Settings merging improvements
   - Error handling enhancements
   - Platform-specific optimizations

3. **Claude Code Integration**:
   - New slash commands
   - Hook system improvements
   - Event type detection enhancements

4. **Documentation**:
   - User guide improvements
   - Technical documentation
   - Example themes

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow the code style guidelines
   - Add appropriate comments
   - Update documentation as needed

3. **Test thoroughly**:
   - Test on your target platform
   - Verify existing functionality still works
   - Test with multiple themes

4. **Update documentation**:
   - Update README.md if needed
   - Update CLAUDE.md for technical changes
   - Add comments to complex code

## Testing

### Manual Testing

1. **Basic Functionality**:
   ```bash
   # Test sound player directly
   bash themed-sound-player.sh notification "bash tool"
   bash themed-sound-player.sh stop
   ```

2. **Theme Switching**:
   ```
   /project:update-theme default
   /project:update-theme darth-vader
   ```

3. **Installation Testing**:
   ```
   /project:install
   /project:install theme-name
   ```

### Automated Testing

Currently, testing is primarily manual. We welcome contributions to add automated testing for:
- Sound file validation
- Settings.json merging
- Cross-platform compatibility
- Volume control accuracy

### Testing Environments

Test your contributions on:
- **macOS**: Primary development platform
- **Linux**: Various distributions if possible
- **Windows**: Basic compatibility testing

## Pull Request Process

### Before Submitting

1. **Fork the repository** and create a feature branch
2. **Test your changes** thoroughly
3. **Update documentation** as needed
4. **Follow the code style guidelines**
5. **Ensure your changes don't break existing functionality**

### Pull Request Guidelines

1. **Title**: Use a clear, descriptive title
   - Good: "Add retro gaming sound theme"
   - Good: "Fix volume control on Linux systems"
   - Bad: "Update files"

2. **Description**: Include:
   - What changes were made
   - Why the changes were needed
   - How to test the changes
   - Any breaking changes or migration notes

3. **Commit Messages**: Follow the existing pattern:
   - Use present tense ("Add feature" not "Added feature")
   - Be descriptive but concise
   - Reference issues when applicable

### Review Process

1. **Automated checks**: Ensure your PR passes any automated checks
2. **Maintainer review**: A maintainer will review your changes
3. **Community feedback**: Other contributors may provide feedback
4. **Iteration**: Make requested changes promptly
5. **Merge**: Once approved, your PR will be merged

### What to Expect

- **Response time**: Initial review within 1-2 weeks
- **Feedback**: Constructive suggestions for improvement
- **Collaboration**: Work together to make the best contribution possible

## Code Style Guidelines

### Bash Scripting

1. **Use proper shebang**: `#!/bin/bash`
2. **Quote variables**: Use `"$variable"` not `$variable`
3. **Error handling**: Check command success with `|| return 1`
4. **Functions**: Use descriptive names and document parameters
5. **Comments**: Explain complex logic and non-obvious code

### Example Code Style

```bash
#!/bin/bash

# Get theme from settings.json with fallback
get_theme() {
  local settings_file="$HOME/.claude/settings.json"
  if [[ -f "$settings_file" ]] && command -v jq >/dev/null 2>&1; then
    jq -r '.soundTheme // "default"' "$settings_file" 2>/dev/null || echo "default"
  else
    echo "default"
  fi
}
```

### File Organization

1. **Directory structure**: Follow the established pattern
2. **File naming**: Use descriptive names with appropriate extensions
3. **Documentation**: Include README.md files for complex directories
4. **Configuration**: Use JSON for settings, not custom formats

### JSON and Markdown

1. **JSON**: Use proper formatting with consistent indentation
2. **Markdown**: Follow standard conventions
3. **Documentation**: Keep it clear and user-focused

## Issue Reporting

### Bug Reports

When reporting bugs, include:

1. **Environment Information**:
   - Operating system and version
   - Claude Code version
   - Current theme name
   - Relevant settings.json configuration

2. **Steps to Reproduce**:
   - Exact commands or actions taken
   - Expected behavior
   - Actual behavior

3. **Error Messages**:
   - Complete error messages
   - Relevant log entries from `~/.claude/sound-log.txt`

4. **Additional Context**:
   - When the issue started
   - Any recent changes to configuration
   - Workarounds you've tried

### Feature Requests

For new features:

1. **Use Case**: Describe the problem you're trying to solve
2. **Proposed Solution**: Your idea for how to address it
3. **Alternatives**: Other approaches you've considered
4. **Examples**: Concrete examples of how it would work

### Theme Requests

For new theme ideas:

1. **Theme Concept**: Describe the theme idea
2. **Sound Sources**: Potential sources for sounds
3. **Use Case**: When/why someone would use this theme
4. **Licensing**: Ensure sounds can be legally distributed

## Community Guidelines

### Our Values

- **Inclusive**: Welcome contributors of all backgrounds and skill levels
- **Respectful**: Treat everyone with kindness and professionalism
- **Collaborative**: Work together to create the best possible project
- **Quality-focused**: Strive for excellence in all contributions

### Communication

1. **Be respectful**: Assume good intentions and be kind
2. **Be constructive**: Provide helpful feedback and suggestions
3. **Be patient**: Remember that everyone is learning
4. **Be professional**: Maintain appropriate language and tone

### Conflict Resolution

If you experience or witness inappropriate behavior:

1. **Document the incident**: Keep records of what happened
2. **Report to maintainers**: Contact project maintainers privately
3. **Follow up**: Work with maintainers to resolve the issue
4. **Escalate if needed**: Seek additional help if necessary

### Recognition

We appreciate all contributions and will:
- Credit contributors in release notes
- Highlight significant contributions
- Provide feedback and encouragement
- Help new contributors get started

## Getting Help

### Resources

- **README.md**: User-facing documentation and quick start
- **CLAUDE.md**: Technical implementation details
- **Sound Log**: `~/.claude/sound-log.txt` for debugging
- **Example Themes**: Study existing themes for patterns

### Where to Ask Questions

1. **GitHub Issues**: For bugs, feature requests, and general questions
2. **Pull Request Comments**: For questions about specific changes
3. **Documentation**: Check existing docs before asking

### Common Questions

**Q: How do I test my theme?**
A: Use `/project:update-theme your-theme-name` to install it locally.

**Q: What sound formats work best?**
A: .wav files provide the best cross-platform compatibility.

**Q: How do I handle volume levels?**
A: Use the filename pattern `name-volume.extension` (e.g. `sound-75.mp3`).

**Q: Can I contribute sounds I found online?**
A: Only if they're properly licensed for redistribution. Original sounds are preferred.

**Q: How do I know what event types are available?**
A: Use `/project:create-theme` which will show you all available event types.

## License

By contributing to this project, you agree that your contributions will be licensed under the same MIT License that covers this project.

Thank you for contributing to Claude Code Sound Themes! Your efforts help make coding with Claude Code a more delightful experience for everyone.