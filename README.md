# Project description

Summary:
The Decentralized Finance (DeFi) Smart Contract System is designed to offer a versatile and scalable solution for interacting with various DeFi protocols, staking platforms, and more. The system comprises a main contract called "StrategiesRootUpgradeable," which acts as the central hub, facilitating interaction with all strategies, managing user balances, and handling essential data. Each individual strategy within the system is responsible for implementing interactions with specific DeFi protocols or staking mechanisms.

Key Components:

1. StrategiesRootUpgradeable: This is the main contract that serves as the core of the system. It acts as the gateway for all interactions between users and various DeFi protocols. StrategiesRootUpgradeable oversees user balances, and it is responsible for coordinating communication with different strategies.

2. Strategies: Each strategy is an independent contract responsible for interfacing with a specific DeFi protocol, staking platform, or similar services. Strategies handle protocol-specific operations, such as swapping tokens, executing stake transactions, and optimizing user rewards.

User Control and Flexibility:
The system empowers users by giving them control over certain parameters. Users have the freedom to specify the acceptable slippage during swaps, allowing for a more customized trading experience. Additionally, users can choose their preferred Automated Market Maker (AMM) when interacting with strategies. This approach enables seamless delegation through delegate calls to the SwapHelper contract from within the strategies, facilitating efficient and optimized execution of DeFi operations.

The Decentralized Finance Smart Contract System offers a flexible and extensible architecture, making it adaptable to integrate with any other decentralized exchange (DEX) or DeFi protocol. This versatility allows developers to create a wide array of DeFi applications while providing users with a seamless and personalized DeFi experience.

![tests_strategies](https://github.com/AntonGulak/strategies/assets/55970327/912b7f63-a287-445d-9103-8c8ff9d057a2)

## Requirements

- The treasury smart contract should be able to receive USDC or any other stable coin
  Requirement fulfilled, I can accept any stablecoin or ERC-20 token for deposit.

- The funds (eg:USDC) are to be distributed among the different protocols and swapped for either USDT or DAI (in case of a liquidity pool).
  Each strategy will implement its own swapping logic to achieve the desired outcomes. Additionally, every user will have the option to choose an Automated Market Maker (AMM) and set the maximum allowable slippage for their exchanges.

- The ratio of these funds to be distributed can be set in the smart contract by the owner of the smart contract and can be changed dynamically after the deployment to the test/mainnet chains.
  Hardcoding the allocation proportions is not practical as it significantly limits the functionality of our service and prevents users from customizing portfolio diversification. Instead, we anticipate that the primary interaction will occur through the frontend, allowing users to independently configure their portfolio distribution. By default or based on user settings, the frontend will divide the deposit into required segments as needed.
- The contract should be able to withdraw the funds in the liquidity pools or DeFi protocols fully or partially.
  The shares logic on Parallax enables operations based on liquidity provider token formulas, making both partial and complete asset withdrawals available. Additionally, users will have the flexibility to perform swaps to the chosen token or any other logic, as each strategy will have its own contract, allowing for diverse and customized functionalities
- We should be able to calculate the aggregated percentage yield of all the protocols.
  By calculating the APY for each strategy and the overall Total Value Locked (TVL) per user or across all users, we will be able to determine these values on the backend/frontend.

## Dependencies installation

Development dependencies are used for contracts compilation, deployment,
verification and testing.

To install development dependencies execute the next command in your command
line (terminal):

```bash
npm i
```

Also, you can use `yarn` to install development dependencies:

```bash
yarn
```

## Compilation

To execute a compilation, you need to run the next command in your command line
(terminal):

```bash
yarn compile
```

An ABI and bytecode will be generated as the result of command execution. See
`artifacts/contracts/` directory.

## Testing

All contracts are covered with unit tests.

To run tests execute the next command in your command line (terminal):

```bash
yarn test
```

Before testing update your `.env` file like in `.env.example`.
