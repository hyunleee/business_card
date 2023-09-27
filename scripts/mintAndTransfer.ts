import { ethers } from "ethers";
import { SimpleCardNFTFactory } from "../typechain-types";
import { readFileSync } from "fs";
import { join } from "path";
const hre = require("hardhat");

const abiPath = join(
    __dirname,
    "../artifacts/contracts/SimpleCardNFTFactory.sol/SimpleCardNFTFactory.json"
  );

const abiJson = JSON.parse(readFileSync(abiPath, "utf8"));

const abi = abiJson.abi;

const contractAddress = "0x806E846858E752eb9f709e9EB3803b9217fbe4d0"; //

async function main() {
    const provider = hre.ethers.provider; 
    const privateKey = process.env.METAMASK_PRIVATE_KEY;
  
    if (!privateKey) {
      console.error("Please set the METAMASK_PRIVATE_KEY environment variable");
      process.exit(1);
    }
  
    const wallet = new hre.ethers.Wallet(privateKey, provider); 
    const currentGasPrice = await provider.getGasPrice();
  
    const contract = new ethers.Contract(contractAddress, abi, provider).connect(
      wallet
    ) as SimpleCardNFTFactory;
  
    await contract.registerSimpleCardInfo(
      "Hyunlee",
      "gusdle794@gmail.com",
      "Blockchain Valley",
      "Seoul Women's University",
      "Information Security",
      "010-3936-7938",
      "https://github.com/hyunleee"
    );
    console.log("Simple Card Info Registered");
  
    await contract.mintSimpleCardNFT(
      {value: ethers.parseEther("0.01"),});
    console.log("New SimpleCardNFT Minted");
  
    const recipientAddress = "0x1b0BC52b647e3244e42cA4147c8622F249f6Dad9"; 
    await contract.transferSimpleCardNFT(recipientAddress);
    console.log(`SimpleCardNFT Transferred to ${recipientAddress}`);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });