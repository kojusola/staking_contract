const hre = require("hardhat");
const { ethers } = require("hardhat");
const BoredApeNFTHolder = "0x4548d498460599286ce29baf9e6b775c19385227";
const BoredApeTokenAddress = "0x4bf010f1b9beDA5450a8dD702ED602A104ff65EE";
const stakingContractAddress = "0x96F3Ce39Ad2BfDCf92C0F6E2C2CAbF83874660Fc";

async function main() {
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [BoredApeNFTHolder],
  });
  const BoredAppSigner = await await ethers.provider.getSigner(
    BoredApeNFTHolder
  );
  await hre.network.provider.send("hardhat_setBalance", [
    BoredApeNFTHolder,
    "0x1000000000000000000",
  ]);

  const BoredApeTokenContract = await ethers.getContractAt(
    "IERC20",
    BoredApeTokenAddress,
    BoredAppSigner
  );

  console.log(
    `BoredApeToken balance before ${await BoredApeTokenContract.balanceOf(
      BoredApeNFTHolder
    )}`
  );
  //approve some boredAppTokens
  const see = await BoredApeTokenContract.approve(
    stakingContractAddress,
    ethers.utils.parseUnits("0.0001", 18)
  );
  const event = await see.wait();
  console.log(event.events[0].args.value);

  console.log(
    `BoredApeToken balance After ${await BoredApeTokenContract.balanceOf(
      BoredApeNFTHolder
    )}`
  );

  const stakingContract = await ethers.getContractAt(
    "StakingAutoBalancingContract",
    stakingContractAddress,
    BoredAppSigner
  );

  const stakes = await stakingContract.Stake(
    ethers.utils.parseUnits("0.0001", 18)
  );
  const event2 = await stakes.wait();
  console.log(event2.events[0].args);
  console.log("logs:", event2.events[0].args.value);

  const viewStakes = await stakingContract.viewStake();
  const eventViewStakes = await viewStakes.wait();
  console.log(eventViewStakes.events[0].args);

  const viewInterests = await await stakingContract.viewInterest();
  console.log(viewInterests);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
