# Favorite OpenCode Setup

Backup of my OpenCode configuration across different contexts.

## Structure

```
config-opencode/   # ~/.config/opencode/ - Global OpenCode config
├── AGENTS.md      # Agent instructions
├── opencode.json  # Main config
├── plugins/       # Installed plugins
├── skills/        # Custom skills
└── superpowers/   # Superpower skills

user-opencode/     # ~/.opencode/ - User-level config
├── bin/           # Custom binaries/scripts
└── opencode.jsonc # User settings

project-opencode/  # .opencode/ - Project-level config (example)
└── skills/        # Project-specific skills
```

## Sync

```bash
./sync.sh pull   # Pull changes from active configs to this repo
./sync.sh push   # Push changes from this repo to active configs (dangerous!)
./sync.sh check  # Check for differences
```

## Restore on New Machine

1. Clone this repo
2. Run `./sync.sh push` to copy configs to their destinations
3. Install dependencies: `cd ~/.config/opencode && bun install`

## Sources

- `~/.config/opencode/` → Global config, skills, superpowers
- `~/.opencode/` → User-level settings and scripts
- `<project>/.opencode/` → Project-specific skills (example: obsidian-research)
