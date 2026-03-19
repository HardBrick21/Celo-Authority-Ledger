# AGENTS.md - Celo Authority Ledger

## Overview

Celo Authority Ledger is a permission state machine deployed on Celo, optimized for stablecoin-native micro-lending with near-zero gas fees.

## What It Does

- **Authority Levels**: REVOKED → OBSERVE → SUGGEST → EXECUTE
- **Micro-Lending**: cUSD-denominated loans $1-$100
- **Credit Limits**: Each agent has a USDC credit limit
- **Low Fees**: Celo's near-zero gas fees enable micro-transactions

## How to Interact

### Smart Contract Interface

**CeloAuthorityState** (deploy on Celo Alfajores or Mainnet)

```solidity
// Grant authority with cUSD credit limit
function grantAuthority(
    address agent,
    AuthorityLevel level,
    bytes32 scope,
    uint256 duration,
    uint256 creditLimit
) external onlyOwner returns (bytes32 transitionId);

// Issue micro-loan in cUSD
function issueMicroLoan(
    address borrower,
    uint256 amount
) external returns (bytes32 loanId);

// Check authority level
function checkAuthority(address agent, AuthorityLevel required) 
    external view returns (bool hasAuthority, AuthorityLevel current);
```

### Authority Levels

- `0` = REVOKED (no permissions)
- `1` = OBSERVE (read-only)
- `2` = SUGGEST (can suggest, human confirms)
- `3` = EXECUTE (full autonomous execution + lending)

## Network Information

| Network | Chain ID | RPC |
|---------|----------|-----|
| Celo Alfajores | 44787 | https://alfajores-forno.celo-testnet.org |
| Celo Mainnet | 42220 | https://forno.celo.org |

## cUSD Integration

- cUSD is Celo's native stablecoin
- 18 decimals
- Used for micro-lending credit limits

## Integration Guide

```javascript
const { ethers } = require('ethers');

// Connect to Celo
const provider = new ethers.JsonRpcProvider('https://alfajores-forno.celo-testnet.org');

// Grant authority with 100 cUSD credit limit
await contract.grantAuthority(
  agentAddress,
  3, // EXECUTE
  ethers.ZeroHash,
  86400, // 24 hours
  ethers.parseUnits('100', 18) // 100 cUSD
);
```

## Target Track

**Best Agent on Celo** ($5,000)

---

*Celo Authority Ledger - Micro-lending for the real world.*