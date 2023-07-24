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
