---
name: context7-driven-development
description: Use when implementing features or debugging issues that involve external libraries, frameworks, or APIs. Always verify with Context7 before writing code.
---

# Context7-Driven Development

## Overview

**Never assume you know the API. Always verify with Context7 before writing code.**

Context7 provides up-to-date documentation for libraries and frameworks. Using it prevents hallucinated APIs, deprecated patterns, and version mismatches.

## When to Use

Use Context7-Driven Development when:
- Writing code that uses external libraries/frameworks
- Fixing bugs involving external code
- Integrating with third-party services
- Upgrading library versions
- Debugging library-specific errors

## Core Workflow

### Implementation Workflow

1. **Identify Dependencies**
   - Check package.json, Cargo.toml, imports
   - List all external libraries being used

2. **Resolve Library IDs**
   ```
   context7_resolve-library-id(libraryName, query)
   ```
   - Get exact Context7-compatible library ID
   - Include version if known: `/org/project/v1.2.3`

3. **Query Documentation**
   ```
   context7_query-docs(libraryId, "How to [specific operation]")
   ```
   - Query BEFORE writing code
   - Query AFTER writing code to verify
   - Be specific: "How to authenticate with OAuth in NextAuth.js" not "auth"

4. **Apply to Implementation**
   - Follow documentation patterns exactly
   - Check version compatibility
   - Note breaking changes

### Debugging Workflow

1. **Reproduce & Isolate**
   - Understand error message
   - Identify which library is involved

2. **Query Context7**
   ```
   context7_query-docs(libraryId, "fix Error X in [library]")
   ```
   - Search for error patterns
   - Look for troubleshooting guides

3. **Verify Fix**
   - Apply suggested fix
   - Test thoroughly
   - Check for related issues

## Query Best Practices

| Bad Query | Good Query |
|-----------|------------|
| "auth" | "How to authenticate users with JWT in Express.js" |
| "hooks" | "React useEffect cleanup function examples" |
| "database" | "How to connect to PostgreSQL with Prisma ORM" |
| "error" | "Fix ECONNREFUSED in node-fetch retry logic" |

## Red Flags - STOP and Query

- "I know how this works" → You don't. Query Context7.
- "This is a common pattern" → Patterns change. Verify.
- "I've used this before" → Memory fails. Check docs.
- "The API is intuitive" → Assumptions cause bugs. Look it up.
- "I'll check after writing" → No. Query first. Always.

## Verification Checklist

Before submitting code:
- [ ] Resolved library ID via `context7_resolve-library-id`
- [ ] Queried Context7 with specific question
- [ ] Followed documentation patterns exactly
- [ ] Checked version compatibility
- [ ] Queried again after implementation to verify

## Maximum Queries

**Call context7_query-docs max 3 times per question.** If you can't find what you need after 3 queries, use the best information available and note the uncertainty.

## Examples

### Before (Hallucination Risk)
```typescript
// Assuming API from memory - WRONG
const client = new SomeClient({ apiKey: process.env.KEY });
await client.doSomething({ option: "value" }); // Might not exist!
```

### After (Context7-Driven)
```typescript
// After querying Context7 for SomeClient API
// Learned: v2.0 changed constructor signature
const client = SomeClient.create({ 
  apiKey: process.env.KEY,
  region: "us-east-1" // Required in v2.0+
});
await client.executeAction({ option: "value" }); // Correct method name
```