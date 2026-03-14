# My OpenCode Setup

This is my personal OpenCode configuration—tweaked over time to get the right balance of speed, cost, and quality. It uses a mix of free models (Kilo, Cline, OpenRouter) and paid ones (OpenAI, Modal) depending on the task.

## What's Inside

- **opencode.json** — Core agent definitions and provider configs
- **oh-my-opencode-slim.json** — Dynamic presets with fallback chains for when models hiccup

## The Agents

### Subagents (defined in opencode.json)

These are the specialist agents I call for specific jobs:

| Agent | Model | What It Does |
|-------|-------|--------------|
| planner | hunter-alpha (OpenRouter) | Breaks down complex features into actionable steps |
| architect | GLM-5-FP8 (Modal) | Big-picture system design and technical decisions |
| brainstormer | healer-alpha (OpenRouter) | Creative ideation and exploring alternatives |
| code-reviewer | GPT-5.4 | General code quality and maintainability checks |
| security-reviewer | GPT-5.4 | Catches security issues in auth, APIs, sensitive data |
| tdd-guide | GPT-5.3-codex | Enforces test-first development, coverage checks |
| build-error-resolver | GPT-5.3-codex-spark | Fast fixes for build/type errors |
| e2e-runner | GPT-5.3-codex | Playwright test generation and maintenance |
| doc-updater | GPT-5.4 | Keeps documentation and codemaps current |
| refactor-cleaner | MiniMax M2.5 Free (Kilo) | Removes dead code and consolidates duplicates |
| go-reviewer | GPT-5.4 | Go-specific idioms, concurrency, performance |
| go-build-resolver | GPT-5.3-codex-spark | Quick Go compilation fixes |
| database-reviewer | GPT-5.4 | PostgreSQL query optimization and schema review |
| rust-reviewer | GPT-5.4 | Rust ownership, lifetimes, safety patterns |
| rust-clippy-fmt-check-tester | GPT-5.3-codex-spark | Rust tooling error resolution |

### Dynamic Presets (oh-my-opencode-slim.json)

These are the orchestrator-level agents that manage the workflow:

| Agent | Primary Model | Key Skills |
|-------|---------------|------------|
| oracle | GPT-5.4 (high) | context7-base-code-review, visual-explainer |
| orchestrator | hunter-alpha | dispatching-parallel-agents, cartography, writing-plans, git-worktrees, verification |
| fixer | GPT-5.3-codex (low) | systematic-debugging, context7-driven-dev |
| designer | GPT-5.4 (medium) | visual-explainer, agent-browser |
| librarian | healer-alpha (low) | context7-base-code-review, cartography, visual-explainer |
| explorer | MiniMax M2.5 Free (Kilo, low) | cartography, context7-base-code-review, systematic-debugging |

## Providers I'm Using

- **Kilo** — OpenCode's gateway to free models (MiniMax M2.5 Free)
- **Cline** — Another free tier with MiniMax, GLM-5, and KAT Coder Pro
- **Modal** — For GLM-5-FP8 (the 744B parameter architecture beast)
- **OpenAI** — GPT-5.4, GPT-5.3-codex, GPT-5.3-codex-spark (business plan)
- **OpenRouter** — Free access to hunter-alpha and healer-alpha
- **Kimi** — Moonshot's kimi-k2.5 for orchestration fallback

## Fallback Chains

When a model times out (15s) or fails, it tries the next one in line:

| Agent | Fallback Order |
|-------|----------------|
| oracle | GPT-5.4 → hunter-alpha → kimi-k2.5 → GPT-5.3-codex → healer-alpha → GPT-5.3-codex-spark |
| orchestrator | hunter-alpha → kimi-k2.5 → GPT-5.4 → healer-alpha → GPT-5.3-codex → GPT-5.3-codex-spark |
| fixer | GPT-5.3-codex → GPT-5.3-codex-spark → kimi-k2.5 → GPT-5.4 → hunter-alpha → healer-alpha |
| designer | GPT-5.4 → healer-alpha → hunter-alpha → kimi-k2.5 → GPT-5.3-codex → GPT-5.3-codex-spark |
| librarian | healer-alpha → GPT-5.4 → hunter-alpha → kimi-k2.5 → GPT-5.3-codex → GPT-5.3-codex-spark |
| explorer | MiniMax M2.5 Free (Kilo) → GPT-5.3-codex → GPT-5.3-codex-spark → kimi-k2.5 → healer-alpha → hunter-alpha → GPT-5.4 |
| refactor-cleaner | MiniMax M2.5 Free (Kilo) → MiniMax M2.5 Free (Cline) |

Notice explorer and refactor-cleaner start with free models—that's intentional since they're used heavily for file searches and cleanup.

## Setup

Drop these into your OpenCode config:

```bash
git clone git@github.com:luckielordie/opencode-setup.git ~/.config/opencode/
```

Then add your API keys to `~/.local/share/opencode/auth.json`:

