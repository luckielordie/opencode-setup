---
name: context7-tdd
description: Use when implementing features with external libraries. Combines test-driven development with Context7 documentation lookup for accurate, up-to-date API references.
---

# Context7-Driven TDD

This skill combines test-driven development with Context7 documentation lookup to ensure accurate implementation using current library APIs.

## When to Activate

- Writing new features using external libraries or frameworks
- Debugging issues with third-party SDKs
- Adding API integrations
- Any work involving unfamiliar or external libraries
- Implementing blockchain/crypto features (DEX integrations, etc.)

## Core Principles

### 1. Always Verify Before Implementing
Never assume API behavior - check Context7 for current documentation.

### 2. Tests BEFORE Code
Follow TDD methodology: write tests first, then implement code to make tests pass.

### 3. Use Context7 for External Libraries
For any external dependency, always query Context7 to get accurate, version-specific patterns.

## Workflow

### Step 1: Identify Dependencies
- Check package.json, go.mod, Cargo.toml, imports
- List all external libraries, frameworks, and APIs being used
- Note specific versions if known

### Step 2: Resolve Context7 Library IDs
For each external dependency, resolve the Context7 library ID:

```typescript
// Example: Resolve library ID
await context7_resolve-library-id({
  libraryName: "ethers",
  query: "Ethereum wallet connection and contract interaction"
})
```

### Step 3: Query Context7 Documentation
Query Context7 for relevant documentation on each library:

```typescript
// Example: Query ethers.js documentation
await context7_query-docs({
  libraryId: "/ethers-project/ethers.js", // resolved library ID
  query: "How to connect wallet and call smart contract function"
})
```

**Be specific in queries:**
- Good: "How to authenticate users with OAuth in NextAuth.js"
- Bad: "auth"

### Step 4: Write Tests First (TDD)
Following tdd-workflow principles:

1. **Write User Journeys**
```
As a [role], I want to [action], so that [benefit]

Example:
As a developer, I want to swap tokens on Raydium,
so that I can execute atomic arbitrage trades.
```

2. **Generate Test Cases**
- Test happy paths
- Test edge cases
- Test error scenarios
- Test boundary conditions

3. **Write Minimal Implementation**
- Use Context7 patterns exactly
- Follow documented best practices
- Include proper error handling

4. **Refactor**
- Keep tests green
- Improve code quality
- Optimize performance

## Context7 + TDD Integration Examples

### Example: Implementing a DEX Swap

**1. Identify dependencies:**
- @solana/web3.js
- @raydium-io/raydium-sdk

**2. Resolve Context7 IDs:**
```
context7_resolve-library-id for "@solana/web3.js"
context7_resolve-library-id for "raydium-sdk"
```

**3. Query documentation:**
```
context7_query-docs: "How to create and send a transaction in Solana"
context7_query-docs: "How to swap tokens on Raydium"
```

**4. Write tests:**
```typescript
describe('Raydium Swap', () => {
  it('executes swap successfully', async () => {
    // Test implementation
  });

  it('handles insufficient balance', async () => {
    // Test error handling
  });
});
```

**5. Implement using Context7 patterns**

### Example: Debugging a Web3 Issue

**1. Identify the library:** ethers.js

**2. Query Context7 for error:**
```
context7_query-docs: "fix Error: insufficient funds in ethers.js"
```

**3. Apply fix from documentation**

**4. Write test for the fix**

## Best Practices

- **Version matters** - Specify versions for accurate docs (e.g., `/vercel/next.js/v14.3.0-canary.87`)
- **Be specific** - Ask "how to" questions, not vague queries
- **Cross-reference** - Check multiple sources if results seem unclear
- **Update docs queries** - Libraries evolve; prefer recent Context7 data over cached knowledge
- **Never skip Context7** - For external libraries, always verify before implementing

## When NOT to Use

- Standard language features (use MDN for JavaScript, Rust docs for Rust)
- Built-in Node.js modules (use Node.js official docs)
- Already familiar libraries with known behavior
- Very recent releases (< 1 week) that may not be indexed yet

## Tools

You have access to:
- `context7_resolve-library-id` - Resolve SDK name to Context7 library ID
- `context7_query-docs` - Query official documentation
- All standard development tools (Read, Write, Edit, Bash, Grep, Glob)

## Success Metrics

- All external library usage verified against Context7
- Tests written before implementation
- 80%+ test coverage achieved
- No deprecated API usage
- Implementation matches current library patterns
