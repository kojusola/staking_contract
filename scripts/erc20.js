// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const BoredApiNFTHolder = "0x4548d498460599286ce29baf9e6b775c19385227";
async function main() {
  const erc20 = await hre.ethers.getContractFactory("ERC20Token");
  const Erc = await erc20.deploy("boredApeToken", "BAT", 18, 100);
  await Erc.deployed();
  console.log("Contract Address", Erc.address);
  console.log(
    "Bored Ape Token Initial Balance",
    await Erc.balanceOf(BoredApiNFTHolder)
  );
  balanceAddress = await Erc.transfer(
    BoredApiNFTHolder,
    ethers.utils.parseUnits("2", 18)
  );
  // console.log(balanceAddress);
  console.log(
    "Bored Ape Token After Balance",
    await Erc.balanceOf(BoredApiNFTHolder)
  );
  // balanceAddress = await Erc.getTotalSupplyAddress(100);
  // console.log(balanceAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
