



# 🌉 WormHole Token Bridge

A cross-chain token bridge solution built on Ethereum using Wormhole protocol for seamless token transfers between different blockchain networks.

## 🚀 Overview

This project implements a cross-chain token bridge system that allows users to transfer ERC20 tokens between different blockchain networks using the Wormhole protocol. The bridge consists of two main components: a sender contract and a receiver contract that work together to facilitate secure and efficient cross-chain token transfers.

## ✨ Features

- **Cross-Chain Token Transfers**: Seamlessly transfer ERC20 tokens between supported blockchain networks
- **Wormhole Integration**: Built on top of the Wormhole protocol for secure cross-chain communication
- **Multi-Chain Support**: Supports multiple blockchain networks including Ethereum, Base, Arbitrum, and more
- **ERC20 Compatibility**: Works with any ERC20 token

## 🏗️ Architecture

The bridge system consists of three main contracts:

### 1. CrossChainSender
- Handles token transfers from the source chain
- Calculates cross-chain transfer costs
- Integrates with Wormhole relayer for message passing
- Manages gas limits and transaction parameters

### 2. CrossChainReceiver
- Receives tokens and payloads on the destination chain
- Validates incoming transfers
- Distributes tokens to intended recipients
- Implements security checks and sender validation

### 3. Worm Token (WRH)
- Custom ERC20 token with additional features
- Mintable, burnable, and pausable functionality
- Owned by contract administrator
- Supports ERC20Permit for gasless approvals

## 🛠️ Technology Stack

- **Solidity**: Smart contract development
- **Foundry**: Development framework and testing
- **Wormhole SDK**: Cross-chain communication


## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/WormHole-Token-Bridge.git
   cd WormHole-Token-Bridge
   ```

2. **Install dependencies**
   ```bash
   # Install Foundry dependencies
   forge install
   
   # Install Node.js dependencies
   npm install
   ```

3. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```env
   PRIVATE_KEY=your_private_key_here
   ETHERSCAN_API_KEY=your_etherscan_api_key
   ```

## 📦 Deployment

### Deploy Cross-Chain Receiver
```bash
# Deploy to Target Chain
forge script script/CrossChainReciever.s.sol:DeployCrossChainReceiver \
  --rpc-url TARGET_CHAIN_RPC_URL \
  --broadcast --verify
```

### Deploy Cross-Chain Sender
```bash
# Deploy to Source Chain
forge script script/CrossChainSender.s.sol:DeployCrossChainSender \
  --rpc-url SOURCE_CHAIN_RPC_URL \
  --broadcast --verify
```

### Deploy Worm Token
```bash
# Deploy to SOURCE CHAIN
forge script script/DeployToken.s.sol:DeployToken \
  --rpc-url SOURCE_CHAIN_RPC_URL \
  --broadcast --verify
```

### Deploy WhiteList (to white list the sender in receiver)
```bash
forge script script/WhiteListSender.s.sol:DeployWhiteList \
  --rpc-url TARGET_CHAIN_RPC \
  --broadcast --verify
```

### Bridge Tokens
```bash
forge script script/BridgeTokens.s.sol:DeployBridgeTokens \
  --rpc-url TARGET_CHAIN_RPC \
  --broadcast --verify
```

## 🧪 Testing



## 📊 Deployed Contracts


## 🔄 Usage

### Transferring Tokens

1. **Approve tokens** for the CrossChainSender contract
2. **Get quote** for cross-chain transfer cost
3. **Execute transfer** with the required fee



This software is provided as-is. Please conduct thorough testing and auditing before using in production environments.