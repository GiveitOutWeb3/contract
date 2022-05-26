import { HardhatRuntimeEnvironment, Network } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { utils } from "ethers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("GiveitOutWeb3", {
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
