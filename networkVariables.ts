interface ChainAddresses {
  [contractName: string]: string;
}

export const KovanTestnet: ChainAddresses = {
  keeperRegistryAddress: "0x4Cb093f226983713164A62138C3F718A5b595F73",
  vrfCoordinatorAddress: "0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9",
  linkTokenAddress: "0xa36085F69e2889c224210F603D836748e7dC0088",
  VRFKeyHash:
    "0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4",
};

export const chainIdToAddresses: {
  [id: number]: { [contractName: string]: string };
} = {
  42: { ...KovanTestnet },
};
