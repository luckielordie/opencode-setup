# Agent Workflow Rules

This file defines workflow rules for agents in this OpenCode configuration.

## Context7 Driven Development

When implementing features or debugging issues that involve external libraries or frameworks, ALWAYS use Context7 to drive the implementation.

### Implementation Workflow

1. **Identify Dependencies**
   - Before writing any code, identify all external libraries, frameworks, and APIs being used
   - Check package.json, imports, and dependencies

2. **Resolve Library IDs**
   - Use `context7_resolve-library-id` to get the correct Context7 library ID for each dependency
   - Include the specific version if known (e.g., `/vercel/next.js/v14.3.0-canary.87`)

3. **Query Documentation**
   - Use `context7_query-docs` to get accurate, up-to-date API references
   - Ask specific "how to" questions rather than vague queries
   - Query Context7 BEFORE writing any code
   - Query Context7 AFTER writing code to verify correctness

4. **Apply to Implementation**
   - Follow the documentation patterns exactly
   - Verify version compatibility
   - Check for breaking changes in major version upgrades

### Debugging Workflow

1. **Reproduce & Isolate**
   - Understand the error message and stack trace
   - Identify which library/framework is involved

2. **Query Context7**
   - Resolve the library ID first
   - Search for common error patterns: "fix Error X in [library]"
   - Look for version-specific troubleshooting guides

3. **Verify Fix**
   - Apply the suggested fix from documentation
   - Test the fix thoroughly
   - Check for related issues in the same codebase

### Best Practices

- **Always verify before implementing** - Never assume API behavior; check Context7
- **Version matters** - Specify versions for accurate docs
- **Be specific** - "How to authenticate users with OAuth in NextAuth.js" vs. "auth"
- **Cross-reference** - Check multiple sources if results seem unclear
- **Update docs queries** - Libraries evolve; prefer recent Context7 data over cached knowledge

### When NOT to Use Context7

- Standard language features (use MDN for JavaScript, Rust docs for Rust)
- Built-in Node.js modules (use Node.js official docs)
- Already familiar libraries with known behavior
- Very recent releases (< 1 week) that may not be indexed yet

### Context7 Based Integration

When integrating third-party services or APIs (payments, auth, databases, etc.), use Context7 to ensure correct implementation.

#### Integration Workflow

1. **Research First**
   - Identify the library/SDK needed for the integration
   - Check if Context7 has documentation for it
   - Note: Some services may not have Context7 coverage yet

2. **Verify Authentication**
   - Query: "How to authenticate with [service] API in [language/framework]"
   - Check for official SDKs vs REST API usage
   - Verify token handling (API keys, OAuth, JWT)

3. **Check Implementation Patterns**
   - Query: "How to [specific operation] with [service] SDK"
   - Look for official examples and best practices
   - Verify error handling patterns

4. **Security Review**
   - Query: "security best practices [service] API"
   - Verify no hardcoded secrets
   - Check rate

#### Common Integration Examples (Go & limiting and quota handling Rust)

| Service Type | Go Query Pattern | Rust Query Pattern |
|--------------|-----------------|-------------------|
| Database | "How to connect to PostgreSQL with GORM" | "How to use SQLx with PostgreSQL" |
| Redis | "How to use Go-Redis for caching" | "How to use redis-rs for caching" |
| Auth | "How to implement JWT auth in Go with Gin" | "How to implement JWT auth in Axum" |
| HTTP Client | "How to make HTTP requests with Go net/http" | "How to use reqwest for HTTP client" |
| WebSocket | "How to handle WebSockets with Gorilla" | "How to use tokio-tungstenite for WebSockets" |
| gRPC | "How to implement gRPC in Go" | "How to implement gRPC in Rust with Tonic" |

#### When Integration Is Not Covered

If Context7 doesn't have the library:
1. Check official documentation first
2. Search the web for recent tutorials
3. Verify with official SDK examples
4. Proceed with caution and extra testing

### Borsh Serialization Development

When working with Solana/Anchor programs and Borsh serialization:

1. **No SDK Dependencies**
   - Avoid pulling in full SDKs (e.g., `@solana/web3.js`, `solana-program`)
   - Use standalone Borsh libraries directly
   - Go: `github.com/near/borsh-go`
   - Rust: `borsh` crate

2. **Take Only What's Needed**
   - Extract only required account types from on-chain programs
   - Reimplement serialization logic when needed
   - Reference Anchor IDL for type definitions
   - Use `borsh` schema directly without Anchor bindings

3. **Query Borsh Directly**
   - Query: "How to serialize with borsh-go"
   - Query: "How to use borsh derive macro in Rust"
   - Query: "Borsh schema definition examples"

## Crypto RPC Library Development

When testing RPC endpoints for different chains:

1. **Chain-Specific Methods**
   - Always check for different RPC methods if TPS doesn't return
   - EVM: `eth_blockNumber`, `eth_getBlockByNumber`
   - Solana: `getRecentPerformanceSamples`, `getSlot`, `getHealth`
   - Different chains have different APIs - don't assume one method works everywhere

2. **Auth Header Testing**
   - Always test with and without auth headers
   - Common patterns: `Authorization: Bearer <key>`, `Origin`, `X-API-Key`
   - Mark status as `needs-key` if auth is required

3. **Record All Data**
   - RPS (Requests Per Second)
   - TPS (Transactions Per Second)
   - Mempool availability (yes/no)
   - Safe TX (no mempool = safe for sending)
   - Source (which DEX/provider the RPC came from)
   - Status (working/rate-limited/needs-key/dead)
