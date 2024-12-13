# INA Token Private Sale & Content Creator Economy

## Introduction

The purpose of this project is to showcase the development and testing of smart contracts using Solidity. The goal is to create an INA token, set up a private sale for fundraising, and establish a system for managing creator credit shares. The project is designed to test engineering skills, problem-solving abilities, and code quality.

## Exercise Objective

### 1. Token Creation and Private Sale

Develop the INA token with the following features:

- **Name**: INANI token  
- **Symbol**: INA  
- **Total Supply**: 1,000,000,000  

#### Private Sale Features

- **Price**: 0.16 USD per token.  
- **Acceptable payment methods**: ETH, USDT, and MATIC.  
- **Fundraising goal**: $15 million (or equivalent in accepted currencies).  
- **Minimum and maximum caps** enforced for investments.  
- **Private sale duration**: Up to 6 months, with the option for the owner to end it early.  
- Automatic token distribution upon reaching fundraising goals or end of sale.  
- Fund transfer to a specified wallet.  
- Tokens for the team are locked for one year and can be withdrawn afterward.  
- The owner can lock tokens of any wallet to prevent manipulation.  

### 2. Creator Credit Management

Implement a system where creators can:

- Mint videos and other media as NFTs.  
- Have credit shares determined by metrics such as followers, likes, comments, NFTs, etc.  
- Allow other users to buy and sell credit shares using INA tokens.  

#### Credit Share Features

- **User scores** are calculated based on engagement metrics.  
- Scores are converted into INA tokens (e.g., 1 million points = 2000 tokens).  
- Total credit share value is determined using a formula involving the token’s market price.  
- Users can sell portions of their credit shares in a marketplace.  

## Solution Overview

### Contracts Implemented

1. **INAToken.sol**  
   - Implements the INA token with ERC20 standards.  
   - Handles token minting and transfers.  
   - Includes mechanisms for locking team tokens for one year.  

2. **ETHToken.sol and USDTToken.sol**  
   - Supports payments with ETH and USDT during the private sale.  
   - Ensures compatibility with multiple payment methods.  

3. **CreatorCredit.sol**  
   - Defines the core logic for managing creator credit shares.  
   - Calculates scores based on engagement metrics.  
   - Facilitates buying and selling of credit shares using INA tokens.  

4. **Stock.sol**  
   - Handles stock issuance and trading for creators.  
   - Integrates with CreatorCredit.sol for managing stock prices and transactions.  

5. **NFT.sol**  
   - Provides functionality for creators to mint media (videos, images, etc.) as NFTs.  
   - Ensures NFTs contribute to the creator’s credibility score.  

## Deployment

- The contracts are deployed on the Polygon testnet.  
- Private sale funds and locked tokens are transferred to designated wallets.  

## How to Use

### Setup

1. Install dependencies with `npm install` or `yarn`.  
2. Compile the contracts using Hardhat.  

### Testing

- Run unit tests with `npm test` or `yarn test`.  

### Deployment

- Deploy the contracts to the Polygon testnet using the provided deployment scripts.  

## Key Features

- **Private Sale**: Fundraising using ETH, USDT, and MATIC with strict caps and automatic token distribution.  
- **Token Locking**: Prevents manipulation and secures team tokens for one year.  
- **Creator Economy**: Allows users to trade credit shares based on a creator’s metrics.  
- **NFT Integration**: Creators can mint videos as NFTs to enhance their scores.  

## Next Steps

1. Listing the INA token on centralized and decentralized exchanges after the private sale.  
2. Extending marketplace features to include more advanced trading options.  
3. Enhancing the scoring algorithm for creator credits with additional metrics.  
