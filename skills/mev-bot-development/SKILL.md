---
name: mev-bot-development
description: Patterns and best practices for building crypto MEV bots (sandwich, arbitrage, front-running). Based on TheBigSandwich project patterns.
---

# MEV Bot Development

Patterns and best practices for building cryptocurrency MEV (Maximal Extractable Value) bots derived from TheBigSandwich project git history.

## Core Architecture

### Component Structure
```
internal/
├── scanner/      # Mempool monitoring, transaction detection
├── executor/     # Transaction execution, MEV strategies
├── verifier/     # Pool reserves, profit validation
├── config/       # YAML configuration management
├── pools/        # DEX pool data fetching
├── tokens/       # Token registry, price feeds
├── opportunity/ # Profit calculation, strategy detection
├── decoder/      # Transaction data decoding
├── gas/          # Gas price estimation
├── ipc/          # Go-Rust inter-process communication
└── crypto/       # Key management, signing

tui/              # Rust terminal UI
cmd/              # Entry points (main, CLI, live_test)
```

## Patterns

### Pattern 1: RPC Failover with Rate Limiting

Multiple RPC endpoints with automatic failover and per-endpoint rate limit tracking.

```go
type Scanner struct {
    rpcIndex     int
    rateLimits   map[string]time.Time
    muRateLimits sync.RWMutex
}

func (s *Scanner) callRPC(ctx context.Context, method string, params interface{}) (*RPCResult, error) {
    for attempts := 0; attempts < len(s.cfg.RPCs.Mempool); attempts++ {
        rpc := s.cfg.RPCs.Mempool[s.rpcIndex]
        s.rpcIndex = (s.rpcIndex + 1) % len(s.cfg.RPCs.Mempool)
        
        // Check rate limit
        if s.isRateLimited(rpc.URL) {
            continue
        }
        
        resp, err := s.doRequest(ctx, rpc.URL, method, params)
        if err != nil {
            continue
        }
        
        if resp.Error != nil && resp.Error.Code == -32005 {
            // Rate limited - track it
            s.setRateLimit(rpc.URL)
            continue
        }
        
        return resp, nil
    }
    return nil, errors.New("all RPCs failed")
}
```

### Pattern 2: Multi-Source Pool Resolution

Aggregate pool data from multiple DEX APIs for reliability.

```go
type PoolResolver struct {
    sources []PoolSource
}

type PoolSource interface {
    GetPoolData(tokenA, tokenB string) (*PoolData, error)
}

// Sources: DexScreener, DexPaprika, direct RPC calls
func (r *PoolResolver) ResolvePool(tokenA, tokenB string) (*PoolData, error) {
    var lastErr error
    
    for _, source := range r.sources {
        data, err := source.GetPoolData(tokenA, tokenB)
        if err == nil && data != nil {
            return data, nil
        }
        lastErr = err
    }
    
    return nil, lastErr
}
```

### Pattern 3: Sandwich Attack Execution

Detect pending swap, calculate optimal front/back run sizes, execute atomically.

```go
type SandwichOpportunity struct {
    FrontRunTx   *types.Transaction
    BackRunTx    *types.Transaction
    TargetTx     *Tx
    ProfitUSD    float64
    GasCostUSD   float64
    NetProfitUSD float64
}

func (d *Detector) DetectSandwich(tx *Tx) (*SandwichOpportunity, error) {
    // Decode target transaction
    decoded := d.decoder.Decode(tx.Data)
    if decoded.Function != "swap" {
        return nil, nil
    }
    
    // Get pool reserves before execution
    reserves := d.pools.GetReserves(decoded.Pool)
    
    // Calculate optimal front-run amount
    amountIn := d.calculateOptimalAmount(reserves)
    
    // Create front-run transaction
    frontRun := d.createFrontRun(amountIn, tx)
    
    return &SandwichOpportunity{
        TargetTx:  tx,
        ProfitUSD: d.calculateProfit(frontRun, reserves),
    }, nil
}
```

### Pattern 4: YAML Configuration with Strong Typing

Use Go structs with YAML tags for type-safe config.

```go
type Config struct {
    Network     NetworkConfig   `yaml:"network"`
    Flashloan   FlashloanConfig `yaml:"flashloan"`
    MEV         MEVConfig       `yaml:"mev"`
    RPCs        RPCConfig       `yaml:"rpcs"`
    Filters     FilterConfig    `yaml:"filters"`
    Execution   ExecutionConfig `yaml:"execution"`
    Scanner     ScannerConfig   `yaml:"scanner"`
}

type MEVMode string

const (
    MEVModeFrontrun MEVMode = "frontrun"
    MEVModeSandwich MEVMode = "sandwich"
)

func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, err
    }
    
    var cfg Config
    if err := yaml.Unmarshal(data, &cfg); err != nil {
        return nil, err
    }
    
    return &cfg, nil
}
```

### Pattern 5: Go-Rust IPC Communication

Use Unix sockets or stdin/stdout for Go-Rust communication.

```go
// Go server
type Server struct {
    conn *net.UnixConn
}

func (s *Server) SendUpdate(update Update) error {
    data, _ := json.Marshal(update)
    _, err := s.conn.WriteToUnix(data)
    return err
}

// Rust client
fn read_updates() {
    let stdin = std::io::stdin();
    let mut reader = BufReader::new(stdin);
    loop {
        let mut line = String::new();
        reader.read_line(&mut line).unwrap();
        // Parse and handle update
    }
}
```

### Pattern 6: Dynamic Token Registry

Load token data from external APIs with caching.

```go
type Registry struct {
    tokens   map[string]*Token
    mu       sync.RWMutex
    fetcher  TokenFetcher
}

func (r *Registry) GetToken(symbol string) (*Token, error) {
    r.mu.RLock()
    if token, ok := r.tokens[symbol]; ok {
        r.mu.RUnlock()
        return token, nil
    }
    r.mu.RUnlock()
    
    // Fetch from API
    token, err := r.fetcher.Fetch(symbol)
    if err != nil {
        return nil, err
    }
    
    r.mu.Lock()
    r.tokens[symbol] = token
    r.mu.Unlock()
    
    return token, nil
}
```

## Best Practices

1. **Multi-RPC Architecture**
   - Separate RPCs for mempool reading vs transaction sending
   - Implement per-endpoint rate limiting
   - Automatic failover on failure

2. **Profit Calculation**
   - Account for gas costs in profit calculations
   - Use on-chain reserves for accurate pricing
   - Set minimum profit thresholds

3. **Transaction Execution**
   - Use nonce management to prevent collisions
   - Implement smart gas pricing (EIP-1559)
   - Add deadline/retry logic

4. **Security**
   - Never expose private keys in config files
   - Use encrypted keystores
   - Validate all external data

5. **Monitoring**
   - Real-time TUI for status monitoring
   - Structured logging
   - Profit/loss tracking

## Common Mistakes

1. **Ignoring Gas Costs** - Calculate net profit after gas, not gross
2. **Single RPC Dependency** - Always have fallbacks
3. **No Slippage Protection** - Set appropriate slippage tolerances
4. **Race Conditions** - Use proper mutex/locking for shared state
5. **Hardcoded Values** - Use configuration for all tunable parameters

## Examples

### Good: Configurable DEX Support
```go
type DEXConfig struct {
    Name         string   `yaml:"name"`
    Router       string   `yaml:"router"`
    Factory      string   `yaml:"factory"`
    SupportedPools []string `yaml:"supported_pools"`
    MinLiquidity float64  `yaml:"min_liquidity"`
}

func LoadDEXConfigs() ([]DEXConfig, error) {
    // Load from config file
}
```

### Anti-pattern: Hardcoded RPC
```go
// BAD: Single RPC, no fallback
const RPC_URL = "https://bsc-dataseed.binance.org"
```

### Good: RPC Pool with Failover
```go
// GOOD: Multiple RPCs with failover
RPCs:
  mempool:
    - url: "https://bsc-dataseed.binance.org"
      weight: 100
    - url: "https://public.rpc.binance.org"
      weight: 50
    - url: "https://rpc.ankr.com/bsc"
      weight: 30
```

## DEX Integration Patterns

| DEX | Factory | Router | Signature |
|-----|---------|--------|-----------|
| PancakeSwap | 0xcA143Ce32Fe78f1f7019d7d551a6402aC1c0be8a | 0x10ED43C718714eb63d5aA6B0F1E0fA5a1c2A3B8 | swapExactETHForTokens |
| Uniswap V2 | 0x5C69bEe701ef814a2B6fe3b4B6f0fB7E57b0d9b2 | 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D | swapExactETHForTokens |
| SushiSwap | 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2AC | 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F | swapExactETHForTokens |
