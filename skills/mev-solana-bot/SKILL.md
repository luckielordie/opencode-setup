---
name: mev-solana-bot
description: Solana MEV bot development CLI. Atomic arbitrage, DEX integration, flash loans, Jito bundles. Run `mev-solana-bot skill` to read full documentation.
---

# Solana MEV Bot Development

CLI for the Scavenger MEV bot - a production Solana atomic arbitrage system.

## Quick Start

```bash
mev-solana-bot skill              # Show full documentation
mev-solana-bot run                # Run in searcher mode (TUI)
mev-solana-bot run --execute      # Run in execute mode
mev-solana-bot test               # Run tests
mev-solana-bot build              # Build release binary
```

If `mev-solana-bot` is not found, use `npx ~/.npm-global/lib/node_modules/kimaki/skills/mev-solana-bot/mev-solana-bot`.

## Environment

Set `MEV_BOT_PATH` to override the default project path (`~/Projects/MEVbots/ScavengerMEVbot`).

## Project Architecture

### Module Structure
```
src/
├── dex_api/           # DEX API clients (Raydium, Orca, Meteora, Pump.fun)
├── dex_integration/   # Multi-DEX pool discovery and management
├── token_monitor/     # Token discovery via RPC
├── laserstream/       # Helius WebSocket streaming
├── verifier_engine/   # Cross-DEX price comparison
├── transaction_builder/  # Flash loan + swaps + tips
├── jito_client/       # Bundle submission via Jito
├── executor/          # Transaction execution engine
├── liquidity_manager/ # WSOL wrapping and balance management
├── lut_manager/       # Address Lookup Table management
├── state_machine/     # Bot state management
├── cache/             # TTL-based caching
└── config/            # Environment-based configuration
```

## Commit Patterns

From git history analysis, this project follows these patterns:

### Commit Message Conventions
- `feat:` - New features (DEX integrations, WebSocket clients)
- `fix:` - Bug fixes (API parsing, conversion errors)
- `refactor:` - Code restructuring (error handling, simplification)
- `docs:` - Documentation updates (codemaps, README, ARCHITECTURE)
- `cleanup:` - Maintenance (directory removal, organization)

### Hot Files (Most Changed)
1. `src/dex_api/mod.rs` (21 changes) - Main API integration point
2. `src/main.rs` (12 changes) - Entry point, CLI args
3. `src/laserstream/mod.rs` (10 changes) - Helius streaming
4. `src/token_monitor/mod.rs` (9 changes) - Token discovery
5. `src/constants/mod.rs` (9 changes) - Program IDs

## Solana-Specific Patterns

### Program ID Management
```rust
// constants/mod.rs
pub const SOLEND_PROGRAM_ID: &str = "So1endDq2ZkqG2M2F9f1Y1r6Y3e1z2x3c4v5b6n7m8";
pub const JUPITER_PROGRAM_ID: &str = "JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4";
pub const JITO_PROGRAM_ID: &str = "Vau1t6sLNxnzB7ZDsef8TLbPLfyZMYXH8WTNqUdm9g8";

// Usage - always verify against official mainnet deployments
if program_id != solana_sdk::pubkey::Pubkey::from_str(SOLEND_PROGRAM_ID).unwrap() {
    return Err(BotError::InvalidProgramId(program_id));
}
```

### Pubkey Handling
- Use `Pubkey` type for all addresses, never strings
- Convert once at boundaries (config/env) then use `Pubkey` throughout
- Use `from_str()` with `expect()` only for compile-time constants

### Token Amounts
```rust
// Use u64 for lamports/amounts
let amount_lamports: u64 = 1_000_000_000; // 1 SOL

// Use Decimal for financial calculations
use rust_decimal::Decimal;
let price: Decimal = Decimal::from(reserve_base) / Decimal::from(reserve_quote);

// Never use f64 for money
// BAD: let price = reserve_base as f64 / reserve_quote as f64;
```

## DEX Integration Patterns

### API Client Structure
```rust
// Raydium example pattern
pub struct RaydiumApiClient {
    client: reqwest::Client,
    base_url: String,
}

impl RaydiumApiClient {
    pub async fn get_pairs(&self) -> Result<Vec<RaydiumPair>> {
        // Fetches from /v2/main/pairs endpoint
        // Returns structured data with validation
    }
    
    pub async fn get_pool_info(&self, pool_id: &str) -> Result<PoolInfo> {
        // Error handling with custom error types
    }
}
```

### Pool Data Structures
```rust
// Unified pool representation across DEXes
pub struct PoolData {
    pub address: Pubkey,
    pub token_a: Pubkey,
    pub token_b: Pubkey,
    pub reserve_a: u64,
    pub reserve_b: u64,
    pub dex_type: DexType,  // Raydium, Orca, Meteora, etc.
    pub fee_rate: u16,      // Basis points
}

// Price calculation with proper decimal handling
impl PoolData {
    pub fn price(&self) -> Decimal {
        Decimal::from(self.reserve_b) / Decimal::from(self.reserve_a)
    }
    
    pub fn output_amount(&self, input_amount: u64, input_is_a: bool) -> u64 {
        // AMM formula: x * y = k
        // Account for fees and slippage
    }
}
```

## Arbitrage Detection

### Two-Hop Arbitrage
```rust
pub struct ArbitrageOpportunity {
    pub token_pair: (Pubkey, Pubkey),
    pub buy_pool: PoolData,    // Lower price
    pub sell_pool: PoolData,   // Higher price
    pub profit_percent: f64,
    pub profit_usd: f64,
    pub route: Vec<Pubkey>,    // Token hop sequence
}

// Detection algorithm
pub fn find_two_hop_arbitrage(pools: &[PoolData]) -> Vec<ArbitrageOpportunity> {
    let mut opportunities = Vec::new();
    
    // Find pools sharing common tokens
    for pool_a in pools {
        for pool_b in pools {
            if pool_a.address == pool_b.address { continue; }
            
            // Check for shared tokens
            if let Some(common_token) = find_common_token(pool_a, pool_b) {
                if let Some(opp) = calculate_arbitrage(pool_a, pool_b, common_token) {
                    opportunities.push(opp);
                }
            }
        }
    }
    
    opportunities.sort_by(|a, b| b.profit_usd.partial_cmp(&a.profit_usd).unwrap());
    opportunities
}
```

### Profit Calculation
```rust
pub fn calculate_profit(
    input_amount: u64,
    buy_price: Decimal,
    sell_price: Decimal,
    flash_loan_fee_bps: u16,
    jito_tip_bps: u16,
) -> Option<Profit> {
    let gross_output = Decimal::from(input_amount) * (sell_price / buy_price);
    
    // Fees
    let flash_loan_fee = gross_output * Decimal::from(flash_loan_fee_bps) / Decimal::from(10_000);
    let jito_tip = gross_output * Decimal::from(jito_tip_bps) / Decimal::from(10_000);
    let network_fee = Decimal::from(5_000); // ~0.005 SOL
    
    let net_profit = gross_output - flash_loan_fee - jito_tip - network_fee;
    let net_profit_percent = (net_profit / Decimal::from(input_amount)) * Decimal::from(100);
    
    if net_profit > Decimal::from(0) {
        Some(Profit {
            gross: gross_output,
            net: net_profit,
            percent: net_profit_percent,
        })
    } else {
        None
    }
}
```

## Transaction Building

### Flash Loan Pattern
```rust
pub fn build_flash_loan_arbitrage(
    &self,
    opportunity: &ArbitrageOpportunity,
    wallet: &Keypair,
) -> Result<VersionedTransaction> {
    let mut instructions = Vec::new();
    
    // 1. Flash loan borrow
    instructions.push(self.build_flash_loan_borrow(
        opportunity.input_token,
        opportunity.input_amount,
    )?);
    
    // 2. Swap sequence (2-5 hops)
    for (i, hop) in opportunity.route.iter().enumerate() {
        let swap_ix = if i == 0 {
            // First swap uses flash loaned tokens
            self.build_swap(hop, opportunity.input_token, true)?
        } else {
            // Subsequent swaps use output from previous
            self.build_swap(hop, intermediate_token, false)?
        };
        instructions.push(swap_ix);
    }
    
    // 3. Flash loan repay
    instructions.push(self.build_flash_loan_repay(
        opportunity.input_token,
        opportunity.repay_amount,
    )?);
    
    // 4. Jito tip
    instructions.push(self.build_jito_tip(jito_tip_amount)?);
    
    // Compile with address lookup tables
    self.compile_transaction(instructions, wallet)
}
```

### Safety Checks
```rust
pub fn verify_transaction(&self, tx: &VersionedTransaction) -> Result<()> {
    // 1. Verify all program IDs
    for ix in &tx.message.instructions() {
        let program_id = ix.program_id(&tx.message.static_account_keys());
        if !VERIFIED_PROGRAM_IDS.contains(&program_id) {
            return Err(BotError::UnverifiedProgram(program_id));
        }
    }
    
    // 2. Verify simulation succeeds
    let simulation = self.rpc_client.simulate_transaction(tx)?;
    if simulation.err.is_some() {
        return Err(BotError::SimulationFailed(simulation.err.unwrap()));
    }
    
    // 3. Verify balances
    let balance = self.rpc_client.get_balance(&wallet.pubkey())?;
    if balance < min_rent + estimated_fees {
        return Err(BotError::InsufficientBalance);
    }
    
    Ok(())
}
```

## WebSocket Streaming

### Helius LaserStream Pattern
```rust
pub struct LaserStreamClient {
    ws: WebSocketStream<MaybeTlsStream<TcpStream>>,
    api_key: String,
}

impl LaserStreamClient {
    pub async fn connect(api_key: &str) -> Result<Self> {
        let url = format!("wss://mainnet.helius-rpc.com/?api-key={}", api_key);
        let (ws, _) = connect_async(url).await?;
        Ok(Self { ws, api_key: api_key.to_string() })
    }
    
    pub async fn subscribe_transactions(
        &mut self,
        accounts: Vec<Pubkey>,
    ) -> Result<()> {
        let subscribe_msg = json!({
            "jsonrpc": "2.0",
            "id": 1,
            "method": "transactionSubscribe",
            "params": [
                {
                    "mentionsAccountOrProgram": accounts.iter().map(|p| p.to_string()).collect::<Vec<_>>(),
                },
                {
                    "commitment": "confirmed",
                    "encoding": "jsonParsed",
                }
            ]
        });
        
        self.ws.send(Message::Text(subscribe_msg.to_string())).await?;
        Ok(())
    }
    
    pub async fn next_transaction(&mut self) -> Result<TransactionUpdate> {
        let msg = self.ws.next().await.ok_or(BotError::StreamClosed)??;
        // Parse and return transaction data
    }
}
```

## Error Handling Patterns

### Custom Error Types
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum BotError {
    #[error("RPC connection failed: {0}")]
    RpcError(#[from] solana_client::client_error::ClientError),
    
    #[error("Invalid program ID: {0}")]
    InvalidProgramId(Pubkey),
    
    #[error("Transaction simulation failed: {0:?}")]
    SimulationFailed(TransactionError),
    
    #[error("Insufficient balance for fees")]
    InsufficientBalance,
    
    #[error("WebSocket stream closed")]
    StreamClosed,
    
    #[error("DEX API error: {0}")]
    DexApiError(String),
}

pub type BotResult<T> = Result<T, BotError>;
```

### Never Unwrap in Production
```rust
// BAD - Production crash
let result = risky_operation().unwrap();

// GOOD - Proper error propagation
let result = risky_operation()?;

// GOOD - Explicit error handling
match risky_operation() {
    Ok(result) => result,
    Err(e) => {
        log::error!("Operation failed: {}", e);
        return Err(e.into());
    }
}
```

## Configuration Patterns

### Environment Variables
```rust
use std::env;

pub struct Config {
    pub rpc_url: String,
    pub jito_url: String,
    pub trade_amount_sol: u64,
    pub execution_enabled: bool,
    pub min_profit_threshold_bps: u16,
    pub jito_tip_lamports: u64,
}

impl Config {
    pub fn from_env() -> Result<Self> {
        Ok(Self {
            rpc_url: env::var("RPC_URL")?,
            jito_url: env::var("JITO_URL")?,
            trade_amount_sol: env::var("TRADE_AMOUNT_SOL")?.parse()?, // 1-50 SOL
            execution_enabled: env::var("EXECUTION_ENABLED")?.parse()?, // DANGEROUS
            min_profit_threshold_bps: env::var("MIN_PROFIT_THRESHOLD_BPS")?.parse()?,
            jito_tip_lamports: env::var("JITO_TIP_LAMPORTS")?.parse()?, // Default: 1000000
        })
    }
}
```

### DANGEROUS Flags
```rust
// These must be explicitly enabled and warn users
if config.execution_enabled {
    log::warn!("⚠️  LIVE EXECUTION ENABLED - REAL FUNDS AT RISK ⚠️");
    if config.auto_execute {
        log::error!("☠️  AUTO-EXECUTE ENABLED - NO CONFIRMATION ☠️");
    }
}
```

## Testing Patterns

### Mock External Services
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    struct MockRpcClient;
    impl RpcClientTrait for MockRpcClient {
        fn get_balance(&self, _pubkey: &Pubkey) -> Result<u64> {
            Ok(1_000_000_000) // 1 SOL
        }
    }
    
    #[tokio::test]
    async fn test_arbitrage_calculation() {
        let mock_rpc = MockRpcClient;
        let result = calculate_opportunity(&mock_rpc, test_pool_data()).await;
        assert!(result.is_some());
        assert!(result.unwrap().profit_percent > 0.0);
    }
}
```

### Integration Tests
```rust
// tests/integration_test.rs
#[tokio::test]
#[ignore] // Requires network
async fn test_raydium_api_integration() {
    let client = RaydiumApiClient::new();
    let pairs = client.get_pairs().await.expect("Should fetch pairs");
    assert!(!pairs.is_empty());
}
```

## Common Mistakes to Avoid

1. **Using f64 for financial calculations** → Use `Decimal` or `u64`
2. **Hardcoding program IDs** → Use constants from verified source
3. **Not verifying transactions before submission** → Always simulate first
4. **Using unwrap/expect in production** → Always handle errors
5. **Mutating state without locks** → Use `RwLock` or channels
6. **Not accounting for slippage** → Include slippage buffers
7. **Ignoring fee impact** → Calculate all fees before deciding
8. **Not checking rate limits** → Implement backoff and rotation

## Verification Checklist

Before submitting to mainnet:
- [ ] All program IDs verified against official deployments
- [ ] Transaction simulation succeeds
- [ ] Balance check for fees + rent
- [ ] Slippage tolerance set appropriately
- [ ] Jito tip calculated and included
- [ ] No unwrap/expect in production paths
- [ ] RPC failover configured
- [ ] Rate limits respected
- [ ] Execution mode confirmed (simulation vs live)

## Resources

- Solend Program ID: `So1endDq2ZkqG2M2F9f1Y1r6Y3e1z2x3c4v5b6n7m8`
- Jupiter Program ID: `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4`
- Jito Program ID: `Vau1t6sLNxnzB7ZDsef8TLbPLfyZMYXH8WTNqUdm9g8`
- Raydium Program ID: `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8`
- Orca Whirlpools: `whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc`

## Helius V2 API Patterns

### getProgramAccountsV2 Pagination
```rust
// Helius V2 supports cursor-based pagination for large datasets
// CRITICAL: Enable gzip and handle pagination correctly

async fn fetch_with_pagination_v2(
    rpc_url: &str,
    program_id: &Pubkey,
    data_size: Option<u64>,
    limit: u32,
) -> anyhow::Result<Vec<(Pubkey, Vec<u8>)>> {
    // MUST enable gzip for large responses
    let client = reqwest::Client::builder()
        .timeout(Duration::from_secs(60))
        .gzip(true)  // CRITICAL: Without this, "error decoding response body" after ~20k accounts
        .build()?;
    
    let mut all_accounts = Vec::new();
    let mut pagination_key: Option<String> = None;
    let max_total = 50_000; // Safety limit
    
    loop {
        let request_body = serde_json::json!({
            "jsonrpc": "2.0",
            "id": "1",
            "method": "getProgramAccountsV2",
            "params": [
                program_id.to_string(),
                {
                    "encoding": "base64",
                    "filters": data_size.map(|s| serde_json::json!([{"dataSize": s}])).unwrap_or(serde::json::json!([])),
                    "limit": limit,
                    "paginationKey": pagination_key
                }
            ]
        });
        
        // Get text first for better error messages
        let response = client.post(rpc_url).json(&request_body).send().await?;
        let text = response.text().await?;
        let json: Value = serde_json::from_str(&text)?;
        
        // Check for method not found (-32601)
        if let Some(error) = json.get("error") {
            let error_code = error.get("code").and_then(|c| c.as_i64()).unwrap_or(-1);
            if error_code == -32601 {
                // Fall back to standard getProgramAccounts
                return fetch_with_standard_gpa(rpc_url, program_id, data_size).await;
            }
            return Err(anyhow!("RPC error: {:?}", error));
        }
        
        let result = json.get("result")
            .ok_or_else(|| anyhow!("No result in response"))?;
        
        // V2 format: result.accounts array
        // Some providers return: result directly as array
        let accounts = result.get("accounts")
            .and_then(|a| a.as_array())
            .or_else(|| result.as_array())
            .ok_or_else(|| anyhow!("No accounts array"))?;
        
        // End of pagination: when accounts is EMPTY (not when paginationKey is null)
        if accounts.is_empty() {
            // If first request returns 0, V2 may not have indexed this program
            if all_accounts.is_empty() {
                return fetch_with_standard_gpa(rpc_url, program_id, data_size).await;
            }
            break;
        }
        
        for account in accounts {
            let pubkey_str = account.get("pubkey")
                .and_then(|p| p.as_str())
                .ok_or_else(|| anyhow!("Missing pubkey"))?;
            let pubkey = Pubkey::from_str(pubkey_str)?;
            
            let data = account.get("account")
                .and_then(|a| a.get("data"))
                .ok_or_else(|| anyhow!("Missing account data"))?;
            
            // Helius V2 returns ["base64String", "base64"] format
            let data_b64 = if let Some(arr) = data.as_array() {
                arr.first().and_then(|v| v.as_str())
            } else {
                data.as_str()
            }.ok_or_else(|| anyhow!("Invalid data format"))?;
            
            let decoded = base64::Engine::decode(&base64::engine::general_purpose::STANDARD, data_b64)?;
            all_accounts.push((pubkey, decoded));
        }
        
        if all_accounts.len() >= max_total {
            warn!("Reached safety limit of {} accounts", max_total);
            break;
        }
        
        // Get next pagination key
        pagination_key = result.get("paginationKey")
            .and_then(|k| k.as_str())
            .map(|s| s.to_string());
        
        // Add delay between requests to avoid rate limiting
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    
    Ok(all_accounts)
}

// Fallback to standard getProgramAccounts
async fn fetch_with_standard_gpa(
    rpc_url: &str,
    program_id: &Pubkey,
    data_size: Option<u64>,
) -> anyhow::Result<Vec<(Pubkey, Vec<u8>)>> {
    // Use solana_client RpcClient or build manual JSON-RPC request
    // Note: Standard GPA may be deprioritized for large datasets
    // ...
}
```

### V2 API Response Format
```json
// Success response
{
  "jsonrpc": "2.0",
  "id": "1",
  "result": {
    "accounts": [
      {
        "pubkey": "Base58Pubkey...",
        "account": {
          "lamports": 123456,
          "data": ["base64EncodedData", "base64"],
          "owner": "ProgramId...",
          "executable": false,
          "rentEpoch": 0
        }
      }
    ],
    "paginationKey": "NextPageCursorOrNullOrMissing"
  }
}

// Error response (method not found)
{
  "jsonrpc": "2.0",
  "id": "1",
  "error": {
    "code": -32601,
    "message": "Method not found"
  }
}

// Rate limit / deprioritized
{
  "jsonrpc": "2.0",
  "id": "1", 
  "error": {
    "code": -32600,
    "message": "Request deprioritized due to number of accounts requested..."
  }
}
```

### Key V2 API Rules

1. **End of pagination**: When `accounts` array is EMPTY, not when `paginationKey` is null
2. **Method not found**: Error code `-32601` - fall back to standard GPA
3. **Gzip required**: Enable `.gzip(true)` on HTTP client
4. **Rate limiting**: Add 100ms delays between pagination requests
5. **Program not indexed**: V2 may return 0 accounts for newly deployed programs - always implement fallback

## Raydium V4 Pool Layout

### Account Structure (752 bytes)
```rust
// Raydium V4 AMM pool account layout
// CRITICAL: Reserves are NOT in pool account!
// They're stored in separate vault token accounts

struct RaydiumV4Layout {
    // Offsets in pool account:
    // 0-8: Discriminator
    // 8-72: Status, nonce, orderNum, depth, coinDecimals, pcDecimals, state fields
    // 72-320: Various config fields
    
    // Vault pubkeys (fetch balances separately):
    base_vault: Pubkey,   // offset 328-360
    quote_vault: Pubkey,  // offset 360-392
    
    // Token mints:
    base_mint: Pubkey,    // offset 392-424
    quote_mint: Pubkey,    // offset 424-456
    lp_mint: Pubkey,       // offset 456-488
    
    // ... more fields up to 752 bytes
}

// To get reserves, fetch vault token accounts via getMultipleAccounts
async fn fetch_vault_balances(
    client: &RpcClient,
    pools: &mut [DiscoveredPool],
    pool_data: &[Vec<u8>],
) {
    let mut vault_pubkeys = Vec::new();
    
    for (i, data) in pool_data.iter().enumerate() {
        if data.len() >= 392 {
            let base_vault = Pubkey::try_from(&data[328..360]).ok();
            let quote_vault = Pubkey::try_from(&data[360..392]).ok();
            // Store for batch fetch
        }
    }
    
    // Batch fetch via getMultipleAccounts (100 at a time)
    for chunk in vault_pubkeys.chunks(100) {
        let accounts = client.get_multiple_accounts(chunk)?;
        for (i, account_opt) in accounts.into_iter().enumerate() {
            if let Some(account) = account_opt {
                // Token account: amount at bytes 64-72
                if account.data.len() >= 72 {
                    let amount = u64::from_le_bytes(account.data[64..72].try_into().unwrap_or([0;8]));
                    // Update pool reserve
                }
            }
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
}
```

### Token Account Layout
```rust
// SPL Token Account (AccountLayout from spl-token)
// 0-8: Discriminator (for ATA) or 0 for regular token account
// 8-40: Mint pubkey (optional in some layouts)
// 40-72: Owner pubkey
// 64-72: Amount (u64) - THIS IS WHERE BALANCE IS
// 72+: Delegated amount, close authority, etc.

fn extract_token_balance(account_data: &[u8]) -> Option<u64> {
    if account_data.len() >= 72 {
        Some(u64::from_le_bytes(account_data[64..72].try_into().ok()?))
    } else {
        None
    }
}
```

## Jupiter Cross-DEX Arbitrage

### Jupiter v6 API for Price Discrepancies
```rust
// Use Jupiter to find price differences between DEXes for same token

pub struct JupiterArbitrageFinder {
    client: JupiterClient,
    min_profit_pct: f64,
}

impl JupiterArbitrageFinder {
    /// Scan token for price discrepancies between DEXes
    pub async fn scan_token(
        &self,
        token_mint: &str,
        sol_amount: u64,
    ) -> Result<Vec<ArbitrageOpportunity>> {
        let sol_mint = "So11111111111111111111111111111111111111112";
        
        // Get SOL -> TOKEN quotes from different DEXes
        let mut buy_quotes: Vec<(&str, QuoteRoute)> = Vec::new();
        
        for dex in &["Raydium", "Orca", "Whirlpool", "Meteora", "Meteora DLMM"] {
            let route = self.client.get_best_route_with_dexes(
                sol_mint,
                token_mint,
                sol_amount,
                Some(50), // 0.5% slippage
                Some(dex.to_string()),
            ).await?;
            
            if let Some(route) = route {
                buy_quotes.push((dex, route));
            }
        }
        
        // Find price discrepancies
        if buy_quotes.len() >= 2 {
            // Sort by output amount (best price first)
            buy_quotes.sort_by(|a, b| b.1.out_amount.cmp(&a.1.out_amount));
            
            let best = &buy_quotes[0];
            let worst = &buy_quotes[buy_quotes.len() - 1];
            
            let price_diff_pct = ((best.1.out_amount - worst.1.out_amount) as f64 
                / worst.1.out_amount as f64) * 100.0;
            
            if price_diff_pct >= self.min_profit_pct {
                // Found arbitrage opportunity!
                // Buy on worst DEX (cheaper), sell on best DEX (more expensive)
            }
        }
        
        Ok(opportunities)
    }
}

// Jupiter API client
impl JupiterClient {
    pub async fn get_best_route_with_dexes(
        &self,
        input_mint: &str,
        output_mint: &str,
        amount: u64,
        slippage_bps: Option<i32>,
        dexes: Option<String>,
    ) -> Result<Option<QuoteRoute>> {
        let url = format!("{}/quote", self.base_url);
        
        let request = QuoteRequest {
            input_mint: input_mint.to_string(),
            output_mint: output_mint.to_string(),
            amount,
            slippage_bps: slippage_bps.unwrap_or(50),
            dexes, // Filter by DEX: "Raydium,Orca,Whirlpool"
            ..Default::default()
        };
        
        let response = self.client.get(&url).query(&request).send().await?;
        
        if !response.status().is_success() {
            return Ok(None);
        }
        
        let quote: QuoteResponse = response.json().await?;
        Ok(quote.data.and_then(|routes| routes.into_iter().next()))
    }
}
```

### DEX Labels for Jupiter
```rust
// DEX labels supported by Jupiter v6 API
pub const DEX_LABELS: &[&str] = &[
    "Raydium",
    "Raydium CLMM",
    "Orca",
    "Whirlpool", 
    "Meteora",
    "Meteora DLMM",
    "Lifinity",
    // Note: pump.fun uses bonding curve, Jupiter routes through it automatically
];
```

## Common Mistakes to Avoid

1. **Using f64 for financial calculations** → Use `Decimal` or `u64`
2. **Hardcoding program IDs** → Use constants from verified source
3. **Not verifying transactions before submission** → Always simulate first
4. **Using unwrap/expect in production** → Always handle errors
5. **Mutating state without locks** → Use `RwLock` or channels
6. **Not accounting for slippage** → Include slippage buffers
7. **Ignoring fee impact** → Calculate all fees before deciding
8. **Not checking rate limits** → Implement backoff and rotation
9. **V2 API without gzip** → MUST enable `.gzip(true)` for large responses
10. **Wrong Raydium offsets** → Reserves are in vault accounts, not pool account
11. **V2 pagination confusion** → End when accounts array is EMPTY, not when key is null
12. **HTTP client timeouts** → Set 60s timeout, get text before parsing

## Verification Checklist

Before submitting to mainnet:
- [ ] All program IDs verified against official deployments
- [ ] Transaction simulation succeeds
- [ ] Balance check for fees + rent
- [ ] Slippage tolerance set appropriately
- [ ] Jito tip calculated and included
- [ ] No unwrap/expect in production paths
- [ ] RPC failover configured
- [ ] Rate limits respected
- [ ] Execution mode confirmed (simulation vs live)
- [ ] V2 API has gzip enabled
- [ ] Pagination handles empty accounts array correctly
- [ ] Fallback to standard GPA when V2 not supported
