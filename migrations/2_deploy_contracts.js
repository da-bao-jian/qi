const Auction = artifacts.require("Auction");
const Vault = artifacts.require("Vault");

module.exports = async function (deployer) {
  await deployer.deploy(Auction);
  await deployer.deploy(Vault);
};

// command:
// truffle migrate --network scrollTestnet
