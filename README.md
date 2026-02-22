# OpenCode Custom Configuration

Personal OpenCode setup with curated skills, agents, and configurations.

## Overview

This repository contains a customized OpenCode configuration combining:
- **47 skills** from various sources (ECC, custom, and project-specific)
- **16 agents** for specialized tasks
- **Custom commands** and hooks
- **Personal configurations**

## Structure

```
.
├── commands/           # Custom OpenCode commands
├── config/            # Configuration backups
├── instructions/      # Base instruction files
├── plugins/           # OpenCode plugins
├── prompts/           # Agent prompts and system prompts
│   └── agents/       # 16 specialized agents
├── skills/           # 47 skills for various domains
└── tools/            # Custom tools
```

## Skills (47 total)

### Security & Testing
- `hack-scope` - VDP scope analysis
- `hacker` - Grayhat security testing
- `security-review` - Security code review
- `security-scan` - Automated security scanning
- `tdd-workflow` - Test-driven development
- `e2e-testing` - End-to-end testing

### Development Patterns
- `api-design` - API design patterns
- `backend-patterns` - Backend development
- `frontend-patterns` - Frontend development
- `coding-standards` - Code quality standards
- `database-migrations` - Database migration patterns
- `deployment-patterns` - Deployment strategies
- `docker-patterns` - Docker best practices

### Language-Specific
- `golang-patterns` / `golang-testing` - Go development
- `python-patterns` / `python-testing` - Python development
- `django-patterns` / `django-security` / `django-tdd` - Django
- `springboot-patterns` / `springboot-security` / `springboot-tdd` - Spring Boot
- `cpp-testing` - C++ testing

### Tools & Utilities
- `browser-automation-agent` - Web browser automation
- `context7-base-code-review` - Context7 integration
- `humanizer` - Text humanization
- `mev-solana-bot` - Solana MEV bot CLI
- `mev-bot-development` - MEV bot development
- `planning-with-files` - File-based planning
- `using-web-scraping` - Web scraping
- `web-search-api` - Web search utilities

### Specialized
- `clickhouse-io` - ClickHouse database
- `postgres-patterns` - PostgreSQL patterns
- `jpa-patterns` - JPA/Hibernate patterns
- `java-coding-standards` - Java standards
- `continuous-learning` / `continuous-learning-v2` - Learning workflows
- `eval-harness` - Evaluation framework
- `verification-loop` - Verification workflows
- `strategic-compact` - Strategic planning
- `iterative-retrieval` - Information retrieval
- `nutrient-document-processing` - Document processing
- `configure-ecc` - ECC configuration
- `project-guidelines-example` - Project guidelines

## Agents (16 total)

### Core Agents
- `architect` - System architecture design
- `planner` - Implementation planning
- `code-reviewer` - Code review specialist
- `security-reviewer` - Security analysis
- `tdd-guide` - Test-driven development

### Language Specialists
- `go-reviewer` / `go-build-resolver` - Go specialist
- `python-reviewer` - Python specialist
- `rust-reviewer` / `rust-clippy-fmt-check-tester` - Rust specialist
- `database-reviewer` - Database optimization

### Specialized Agents
- `build-error-resolver` - Build error fixing
- `e2e-runner` - E2E testing
- `doc-updater` - Documentation updates
- `refactor-cleaner` - Dead code cleanup
- `context7-sdk-compliance` - Context7 SDK compliance

## Installation

1. Clone this repository:
```bash
git clone https://github.com/VenTheZone/favorite-opencode-setup.git
cd favorite-opencode-setup
```

2. Copy to your OpenCode config location:
```bash
# Option 1: Global config
cp -r * ~/.config/opencode/

# Option 2: Project-specific
cp -r * /path/to/your/project/.opencode/
```

3. Restart OpenCode to load the new configuration.

## Usage

### Using Skills
```bash
# Load a skill
skill: hacker

# Or reference in conversation
"Use the hack-scope skill to analyze this VDP"
```

### Using Agents
```bash
# Reference an agent with @
@architect design a microservice architecture for...

# Or use in Task tool
Task(description: "Review this code", subagent_type: "code-reviewer")
```

## Customization

### Adding New Skills
1. Create a new folder in `skills/<skill-name>/`
2. Add `SKILL.md` with frontmatter:
```yaml
---
name: skill-name
description: What this skill does
---
```
3. Restart OpenCode

### Adding New Agents
1. Add agent definition to `prompts/agents/<agent-name>.txt`
2. Reference in `opencode.json` or use directly

## Configuration

Main configuration in `opencode.json`:
- Model settings
- Agent definitions
- Command mappings
- Plugin configuration

## Sources

This configuration includes content from:
- [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code)
- Custom skills (hacker, hack-scope)
- Project-specific skills (mev-solana-bot, browser-automation-agent)
- OpenCode community skills

## License

MIT

## Contributing

This is a personal configuration repository. Feel free to fork and customize for your own use.
