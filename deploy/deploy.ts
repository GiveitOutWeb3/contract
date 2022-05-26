import { HardhatRuntimeEnvironment, Network } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { utils } from "ethers";
import { chainIdToAddresses } from "../networkVariables";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();
  // get current chainId
  const chainId = parseInt(await hre.getChainId());
  const addresses = chainIdToAddresses[chainId];

  await deploy("GiveitOutWeb3", {
    args: [
      addresses.vrfCoordinatorAddress,
      addresses.linkTokenAddress,
      addresses.VRFKeyHash,
      addresses.keeperRegistryAddress,
    ],
    from: deployer,
    log: true,
  });

  await deploy("GiveOutNFT", {
    from: deployer,
    log: true,
  });
};
export default func;
func.tags = ["GiveitOutWeb3", "GiveOutNFT"];
