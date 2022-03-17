// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { ethers } = require("hardhat");
const whiteListAddress = "0x1F8F71673B0712B02680aD981A0D5F4f2cFF854B";
const contractAddress = "0x6cB219BA5Ed20bFFe1c5be27381DCEA19BcFc768";
async function main() {
  const erc20 = await hre.ethers.getContractAt("ERC20Token", contractAddress);
  console.log(await erc20.balanceOf(whiteListAddress));
  balanceAddress = await erc20.transfer(
    whiteListAddress,
    ethers.utils.parseUnits("2", 18)
  );
  console.log(balanceAddress);
  console.log(await erc20.balanceOf(whiteListAddress));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
