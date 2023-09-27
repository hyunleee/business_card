require("dotenv").config();
import { ethers } from "hardhat";
import { SimpleCardNFTFactory } from "../typechain-types";

async function main() {
  const SimpleCardNFTFactoryFactory = await ethers.getContractFactory(
    "SimpleCardNFTFactory"
  );
  const simpleCardNFTFactory: SimpleCardNFTFactory =
    (await SimpleCardNFTFactoryFactory.deploy()) as SimpleCardNFTFactory;

  console.log(
    "SimpleCardNFTFactory deployed to:",
    await simpleCardNFTFactory.getAddress
  );
}

main()
  .then(() => (process.exitCode = 0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
