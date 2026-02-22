---
description: Fix Rust clippy, fmt, and test errors
agent: rust-clippy-fmt-check-tester
subtask: true
---

# Rust Clippy, Fmt & Test Fix Command

Fix Rust build errors, clippy warnings, fmt issues, and test failures: $ARGUMENTS

## Your Task

1. **Diagnose** the errors by running cargo commands
2. **Fix** the issues with minimal changes
3. **Verify** by re-running the checks

## Diagnostic Commands

Run these to find issues:

```bash
# Build errors
cargo build 2>&1

# Clippy warnings
cargo clippy -- -D warnings 2>&1

# Format check
cargo fmt -- --check 2>&1

# Test failures
cargo test 2>&1
```

## Fix Priority

1. **Build errors** - Must fix first
2. **Clippy warnings** - Clean code required
3. **Format issues** - Run `cargo fmt`
4. **Test failures** - All tests must pass

## Common Fixes

### Borrow Checker
- Borrow sequentially instead of simultaneously
- Use clones for multiple owners

### Ownership
- Clone values that need multiple owners
- Borrow instead of move

### Type Errors
- Add proper type annotations
- Implement required traits

### Clippy
- Remove unnecessary mut
- Use appropriate iterators
- Fix clone_on_copy issues

### Format
- Run `cargo fmt`
- Fix indentation
- Add trailing commas

## Output Format

### Fixed Issues
- [file:line] Error description → Fixed

### Remaining Issues
- [file:line] Issue description (if any)

---

**Goal**: Clean build, zero clippy warnings, formatted code, all tests pass.
