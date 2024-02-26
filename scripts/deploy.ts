import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  const lockedAmount = ethers.parseEther("0.001");

  const initialOwner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

  const NFTMarket = await ethers.deployContract("VickishNFTMarketplace", [
    initialOwner,
  ]);

  await NFTMarket.waitForDeployment();

  console.log(`NFTMarket deployed to ${NFTMarket.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
