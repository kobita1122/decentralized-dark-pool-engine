# Decentralized Dark Pool Engine

This repository provides a high-level implementation of a "Dark Pool" on-chain. It is designed to mitigate front-running and market impact for large-scale institutional trades by keeping the order details encrypted until a match is found.

### Mechanism
* **Commitment Phase:** Users submit a cryptographic commitment (hash) of their order (token, side, amount, price).
* **Encrypted Matching:** An off-chain matching engine identifies overlapping orders without decrypting the full intent.
* **On-chain Settlement:** Matched orders are settled on-chain by revealing the original data and proving it matches the initial commitment.
* **Fairness:** Prevents MEV bots from seeing pending large orders in the mempool, as only the hash is visible.

### Privacy Features
* **Order Obfuscation:** Volume and price are hidden from the public ledger until the trade is finalized.
* **Anti-Slippage:** Direct peer-to-peer matching avoids the slippage typical of public AMMs.
