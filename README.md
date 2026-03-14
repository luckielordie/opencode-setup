# My OpenCode Setup

This is my personal OpenCode configuration—built specifically for **Golang Backend Development**. It uses Google's Gemini models (2.5 Pro and 3.1 Pro Preview) to power an arsenal of specialized coding agents via the OpenCode CLI.

## What's Inside

- **opencode.json** — Core agent definitions, tools, commands, and provider configs.
- **commands/** — Pre-built executable task templates for the agents.
- **prompts/** — System prompts strictly tuned for Go backend patterns.
- **skills/** — Reusable SKILL.md documents auto-loaded by OpenCode to give agents domain-specific knowledge (e.g., Go testing, PostgreSQL patterns).

## The Agents

### Subagents (defined in opencode.json)

These are the specialist agents I call for specific jobs. They are strictly tuned to adhere to Go standards (e.g., `go fmt`, `go test`, avoiding `console.log` in favor of `slog`, etc.):

| Agent | What It Does |
|-------|--------------|
| `planner` | Breaks down complex features into actionable steps. Modifies `internal/` packages. |
| `architect` | Big-picture system design, Go package boundaries, and technical decisions. |
| `code-reviewer` | General Go code quality, performance, and maintainability checks. |
| `tdd-guide` | Enforces test-first development using Go's `testing` and `net/http/httptest` packages. |
| `doc-updater` | Keeps documentation, `go.mod` dependencies, and codemaps current. |
| `go-reviewer` | Go-specific idioms, concurrency (goroutines/channels), error handling, and performance. |
| `go-build-resolver` | Quick Go compilation and `go vet` error fixes. |
| `database-reviewer` | PostgreSQL query optimization, transactions, and schema review. |

## Providers I'm Using

- **Google** — Utilizing Gemini 2.5 Pro and Gemini 3.1 Pro Preview directly via the Gemini CLI integration.

## Setup

Drop these into your OpenCode config directory:

```bash
git clone git@github.com:luckielordie/opencode-setup.git ~/.config/opencode/
```

Then add your Google API key to your environment or OpenCode configuration.
