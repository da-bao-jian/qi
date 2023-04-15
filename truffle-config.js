const HDWalletProvider = require("@truffle/hdwallet-provider");
const privateKey = process.env.PRIVATE_KEY;
const scrollTestnetRpcUrl = process.env.SCROLL_TESTNET_RPC;

module.exports = {
  networks: {
    scrollTestnet: {
      provider: () => new HDWalletProvider(privateKey, scrollTestnetRpcUrl),
      network_id: "NETWORK_ID", // Replace with the Scroll testnet network ID
      gas: 6000000,
      gasPrice: 20000000000, // 20 gwei
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    // ... (other network configurations)
  },
  // ... (other configurations)
};
