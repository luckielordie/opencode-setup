---
name: verification-loop
description: "A comprehensive verification system for Claude Code sessions."
---

# Verification Loop Skill

A comprehensive verification system for Claude Code sessions.

## When to Use

Invoke this skill:
- After completing a feature or significant code change
- Before creating a PR
- When you want to ensure quality gates pass
- After refactoring

## Verification Phases

### Phase 1: Build Verification
```bash
# Check if project builds
go build ./... 2>&1 | tail -20
```

If build fails, STOP and fix before continuing.

### Phase 2: Type Check
```bash
# Go projects type check natively with build, but we can run vet
go vet ./... 2>&1 | head -30
```

Report all vet errors. Fix critical ones before continuing.

### Phase 3: Lint Check
```bash
# Go projects
golangci-lint run 2>&1 | head -30
```

### Phase 4: Test Suite
```bash
# Run tests with coverage
go test -coverprofile=coverage.out ./... 2>&1 | tail -50
go tool cover -func=coverage.out | grep total
```

Report:
- Passed/Failed tests
- Coverage: X%

### Phase 5: Security Scan
```bash
# Check for secrets
grep -rn "sk-" --include="*.go" . 2>/dev/null | head -10
grep -rn "api_key" --include="*.go" . 2>/dev/null | head -10

# Check for debug print statements
grep -rn "fmt.Print" --include="*.go" . 2>/dev/null | head -10
```

### Phase 6: Diff Review
```bash
# Show what changed
git diff --stat
git diff HEAD~1 --name-only
```

Review each changed file for:
- Unintended changes
- Missing error handling
- Potential edge cases

## Output Format

After running all phases, produce a verification report:

```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
2. ...
```

## Continuous Mode

For long sessions, run verification every 15 minutes or after major changes:

```markdown
Set a mental checkpoint:
- After completing each function
- After finishing a component
- Before moving to next task

Run: /verify
```

## Integration with Hooks

This skill complements PostToolUse hooks but provides deeper verification.
Hooks catch issues immediately; this skill provides comprehensive review.
