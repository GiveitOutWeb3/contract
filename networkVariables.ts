import { ethers } from "ethers";

interface ChainAddresses {
  [contractName: string]: string;
}

const chainIds = {
  ganache: 5777,
  goerli: 5,
  hardhat: 7545,
  kovan: 42,
  mainnet: 1,
  rinkeby: 4,
  bscTestnet: 97,
  bscMainnet: 56,
  MaticTestnet: 80001,
  MaticMainnet: 137,
  ropsten: 3,
};

export const KovanTestnet: ChainAddresses = {
  keeperRegistryAddress: "0x4Cb093f226983713164A62138C3F718A5b595F73",
  vrfCoordinatorAddress: "0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9",
  linkTokenAddress: "0xa36085F69e2889c224210F603D836748e7dC0088",
  VRFKeyHash:
    "0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4",
  VRFFee: ethers.utils.parseEther("0.1").toString(),
};

export const BNBTestnet: ChainAddresses = {
  keeperRegistryAddress: "0xA3E3026562a3ADAF7A761B10a45217c400a4054A",
  vrfCoordinatorAddress: "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C",
  linkTokenAddress: "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06",
  VRFKeyHash:
    "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186",
  VRFFee: ethers.utils.parseEther("0.1").toString(),
};

export const chainIdToAddresses: {
  [id: number]: { [contractName: string]: string };
} = {
  [chainIds.kovan]: { ...KovanTestnet },
  [chainIds.bscTestnet]: { ...BNBTestnet },
};
