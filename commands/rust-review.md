---
description: Rust code review for idiomatic patterns
agent: rust-reviewer
subtask: true
---

# Rust Review Command

Review Rust code for idiomatic patterns and best practices: $ARGUMENTS

## Your Task

1. **Analyze Rust code** for ownership, borrowing, lifetimes
2. **Check memory safety** - no use-after-free, double-free, leaks
3. **Review error handling** - proper Result usage, no expect/unwrap abuse
4. **Verify concurrency** - Arc, Mutex, Send/Sync traits
5. **Check performance** - allocations, iterators, capacity

## Review Checklist

### Ownership & Borrowing
- [ ] No ownership violations
- [ ] No mutable/immutable borrow conflicts
- [ ] Lifetime annotations correct
- [ ] No use-after-free

### Memory Safety
- [ ] No unsafe code without justification
- [ ] No memory leaks (Box::leak, Rc cycles)
- [ ] Proper drop order

### Error Handling
- [ ] No unwrap/expect on Option/Result
- [ ] ? operator used for propagation
- [ ] Custom error types where appropriate

### Concurrency
- [ ] Thread-safe types (Arc, Mutex, RwLock)
- [ ] Send/Sync implemented correctly
- [ ] No data races

### Performance
- [ ] No unnecessary clones
- [ ] Iterator methods used
- [ ] Capacity hints for Vec

### Code Quality
- [ ] Clippy clean (`cargo clippy -- -D warnings`)
- [ ] Fmt clean (`cargo fmt -- --check`)
- [ ] Documentation on public APIs
- [ ] Proper naming conventions

### Security
- [ ] Input validation
- [ ] No command injection risks
- [ ] No hardcoded secrets

## Report Format

### Critical Issues
- [file:line] Issue description
  Suggestion: How to fix

### High Issues
- [file:line] Issue description
  Suggestion: How to fix

### Medium Issues
- [file:line] Issue description
  Suggestion: How to fix

---

**TIP**: Run `cargo clippy -- -D warnings` and `cargo fmt -- --check` for automated checks.
