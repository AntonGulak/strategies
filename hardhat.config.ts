import { HardhatUserConfig } from "hardhat/config";

import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";

import "@openzeppelin/hardhat-upgrades";

import * as dotenv from "dotenv";

import "hardhat-contract-sizer";

import "solidity-coverage";

dotenv.config();

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: `${process.env.ARBITRUM_MAINNET_RPC}${process.env.ALCHEMY_KEY_ARB}`,
        blockNumber: Number(process.env.ARB_BLOCK_NUMBER),
      },
      chainId: 42161,
    },
  },
  etherscan: {
    apiKey: {
      arbitrumOne: (process.env.ARBISCAN_API_KEY || "").trim(),
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 10000,
          },
        },
      },
    ],
  },
  mocha: {
    timeout: 100000000,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};

export default config;
