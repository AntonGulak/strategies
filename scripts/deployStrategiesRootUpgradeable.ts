import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import { ContractFactory, Contract } from "ethers";

import hre, { ethers, upgrades } from "hardhat";

import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const RootFactory: ContractFactory = await ethers.getContractFactory("StrategiesRootUpgradeable");
  const root: Contract = await upgrades.deployProxy(RootFactory, [], {
    initializer: "__StrategiesRootUpgradeable_init",
  });

  await root.deployed();

  console.log("Root proxy address: ", root.address);

  // Verify implementation
  try {
    await hre.run("verify:verify", {
      address: await hre.upgrades.erc1967.getImplementationAddress(root.address),
      constructorArguments: [],
    });
  } catch (err: any) {
    console.error(err.message);
  }

  console.log("\n*********************************************************\n");

  // Verify proxy
  try {
    await hre.run("verify:verify", {
      address: root.address,
      constructorArguments: [],
    });
  } catch (err: any) {
    console.error(err.message);
  }
}

main().catch((error) => {
  console.error(error);

  process.exitCode = 1;
});
