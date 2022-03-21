// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { ethers } = require("hardhat");
const BoredApeNFTHolder = "0x4548d498460599286ce29baf9e6b775c19385227";
const BoredApeTokenAddress = "0x4bf010f1b9beDA5450a8dD702ED602A104ff65EE";
const stakingContractAddress = "0x4bf010f1b9beDA5450a8dD702ED602A104ff65EE";

async function main() {
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [BoredApeNFTHolder],
  });
  const BoredAppSigner = await await ethers.provider.getSigner(
    BoredApeNFTHolder
  );
  const stakingContract = await ethers.getContractAt(
    "StakingAutoBalancingContract",
    stakingContractAddress,
    BoredAppSigner
  );
  const stakes = await stakingContract.Stake(ethers.utils.parseUnits("2", 18));
  console.log("logs:", await stakes.wait());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
