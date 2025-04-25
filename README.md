# Ethena on Base blockchain

This repository demonstrates the integration of Base Blockchain with Ethena protocol, focusing specifically on USDe minting flows.


## Quick start

1. Clone this repository
2. Install dependencies:

```bash
cd contracts
forge install
```

3. Set up your environment variables

```bash
cp .env.example .env
# modify .env
source .env
```

4. Run local node that copies Base mainnet's state (contracts, balances) for realistic testing

```bash
anvil --fork-url https://mainnet.base.org --chain-id 8453
```

5. Deploy bunch of smart contracts to the local network

```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --chain 8453 --broadcast
```

6. Mint USDe

```bash
forge script script/Mint.s.sol --rpc-url $RPC_URL --chain 8453
```


## Theory

### Base Blockchain

Base is built as an Ethereum L2, decentralized with the Optimism Superchain.

- Developed in partnership with **Optimism** (another Ethereum L2) using the [OP Stack](https://github.com/ethereum-optimism/optimism) - an open-source framework for building L2 solutions developed by Optimism
- **no-network-token** approach (ETH used for transactions)
- Utilizes **optimistic rollups** to batch transactions off-chain before submitting to Ethereum mainnet
- Blockchain Explorer: [https://basescan.org/](https://basescan.org/)


### Ethena protocl

Ethena's USDe is a synthetic dollar, backed with a combination of crypto collateral/assets (e.g., ETH, stETH, BTC) and corresponding [short futures positions](https://www.investopedia.com/terms/s/short.asp). It's **not** the same as a fiat-backed stablecoin like USDC or USDT.

- Minting USDe is the process of sending backing assets (such as USDC & USDT) to the Ethena protocol in exchange for USDe (only KYC’d & whitelisted users can do that, actually). The protocol doesn’t require overcollateralization, instead, USDe maintains a 1:1 collateral ratio.

- Redeeming USDe is the process of burning USDe in exchange for backing assets.

Ethena's solution has both **Onchain** and **Offchain** composite components & services.

![](https://docs.ethena.fi/~gitbook/image?url=https%3A%2F%2F596495599-files.gitbook.io%2F%7E%2Ffiles%2Fv0%2Fb%2Fgitbook-x-prod.appspot.com%2Fo%2Fspaces%252FsBsPyff5ft3inFy9jyjt%252Fuploads%252FuVAV5EN5BufxVzHdQ7o1%252FMechanics%2520of%2520Creating%2520USDe.png%3Falt%3Dmedia%26token%3D27ca116e-61cd-4471-8e3d-a7edf35b7110&width=768&dpr=1&quality=100&sign=dafb9c09&sv=2)
