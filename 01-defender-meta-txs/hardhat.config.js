require('dotenv').config();

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  networks: {
    local: {
      url: 'http://localhost:8545'
    },
    xdai: {
      url: 'https://dai.poa.network',
      accounts: [process.env.PRIVATE_KEY],
    },
    polygon: {
      url: 'https://matic-mainnet.chainstacklabs.com',
      accounts: [process.env.PRIVATE_KEY],
    },
    rinkeby: {
      url: 'https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
      accounts: [process.env.PRIVATE_KEY],
    }

  }
};
