async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const Auction = await ethers.getContractFactory("Auction");
    const auction = await Auction.deploy();
    await auction.deployed();
    console.log("MyContract1 deployed to:", auction.address);
  
    const Vault = await ethers.getContractFactory("Vault");
    const vault = await Vault.deploy();
    await vault.deployed();
    console.log("MyContract2 deployed to:", vault.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  
// command:
// npx hardhat run --network mantleTestnet scripts/deploy.js
// npx hardhat run --network polygonMumbai scripts/deploy.js
// npx hardhat run --network taikoTestnet scripts/deploy.js