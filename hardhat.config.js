require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

const privateKey = process.env.PRIVATE_KEY;
const mantleTestnetRpcUrl = process.env.MANTLE_TESTNET_RPC;
const polygonMumbaiRpcUrl = `https://rpc-mumbai.maticvigil.com/v1/${process.env.POLYGON_MUMBAI_API_KEY}`;
const taikoTestnetRpcUrl = `https://rpc.taiko.testnet/api/v1/${process.env.TAIKO_TESTNET_API_KEY}`;

module.exports = {
  solidity: "0.8.4",
  networks: {
    mantleTestnet: {
        url: mantleTestnetRpcUrl,
        accounts: [privateKey],
        gas: 6000000,
        gasPrice: 20000000000, // 20 gwei
      },
    polygonMumbai: {
      url: polygonMumbaiRpcUrl,
      accounts: [privateKey],
      gas: 6000000,
      gasPrice: 20000000000, // 20 gwei
    },
    taikoTestnet: {
      url: taikoTestnetRpcUrl,
      accounts: [privateKey],
      gas: 6000000,
      gasPrice: 20000000000, // 20 gwei
    },
    // ... (other network configurations)
  },
};
