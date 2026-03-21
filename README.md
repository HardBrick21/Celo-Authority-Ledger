# Celo Authority Ledger

> Authority Ledger deployed on Celo - fast, low-cost, stablecoin-native permission management for AI agents

## Overview

This is a Celo deployment of Authority Ledger, leveraging Celo's stablecoin infrastructure for real-world micro-lending and payment scenarios.

## Why Celo?

- **Near-zero gas fees** - Perfect for micro-transactions
- **Stablecoin-native** - cUSD for real-world payments
- **Mobile-first** - Accessible to underbanked users globally
- **Fast finality** - 5-second block times

## Deployed Contracts

| Contract | Address | Network |
|----------|---------|---------|
| CeloAuthorityState | TBD | Celo Alfajores Testnet |

## Key Features for Celo

1. **Micro-Lending Agent** - Loans $1-$100 with automatic repayment
2. **Stablecoin Payments** - cUSD-denominated authority grants
3. **Mobile Integration** - SMS-based authority verification

## Quick Start

```bash
# Install dependencies
npm install

# Compile
npx hardhat compile

# Deploy to Celo Alfajores
npx hardhat run scripts/deploy.js --network celo-alfajores
```

---

*Authority Ledger on Celo - Permission management for the real world.*