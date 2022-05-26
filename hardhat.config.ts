import dotenv from "dotenv";
dotenv.config();
import { parseEther } from "@ethersproject/units";

import { HardhatUserConfig } from "hardhat/types";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "hardhat-abi-exporter";
import "hardhat-tracer";

const infuraApiKey = process.env.INFURA_API_KEY;
const privateKey = process.env.DEPLOYER_PRIVATE_KEY!;
const forkChainId: any = process.env.FORK_CHAINID;

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

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  namedAccounts: {
    deployer: 0,
  },
  defaultNetwork: "hardhat",
  networks: {
    local: {
      url: "http://127.0.0.1:8545",
      accounts: [privateKey],
    },
    hardhat: {
      forking: {
        url: process.env.POLYGON_NODE_URL!,
      },
      accounts: [
        {
          privateKey: privateKey,
          balance: parseEther("100").toString(),
        },
      ],
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${infuraApiKey}`,
      accounts: [privateKey],
    },
    polygon: {
      url: process.env.POLYGON_NODE_URL!,
      accounts: [privateKey],
    },
    bscTestnet: {
      accounts: [privateKey],
      chainId: chainIds["bscTestnet"],
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
    },
    bscMainnet: {
      accounts: [privateKey],
      chainId: chainIds["bscMainnet"],
      url: "https://bsc-dataseed.binance.org/",
    },
    MaticTestnet: {
      accounts: [privateKey],
      // chainId: chainIds["MaticTestnet"],
      chainId: 80001,
      allowUnlimitedContractSize: true,
      url:
        "https://speedy-nodes-nyc.moralis.io/" +
        infuraApiKey +
        "/polygon/mumbai",
    },
    MaticMainnet: {
      accounts: [privateKey],
      chainId: chainIds["MaticMainnet"],
      allowUnlimitedContractSize: true,
      url: "https://rpc-mainnet.maticvigil.com/",
    },
  },
  mocha: {
    timeout: 200000,
  },
};

export default config;
