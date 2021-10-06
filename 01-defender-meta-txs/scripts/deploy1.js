const { ethers } = require('hardhat');
const { writeFileSync } = require('fs');

async function deploy(name, ...params) {
  const Contract = await ethers.getContractFactory(name);
  return await Contract.deploy(...params).then(f => f.deployed());
}

async function main() {
  const forwarder = await deploy('MinimalForwarder');
  const space_station = await deploy("SpaceStationV1Meta", forwarder.address);

  writeFileSync('deploy.json', JSON.stringify({
    MinimalForwarder: forwarder.address,
    SpaceStation: space_station.address,
  }, null, 2));

  console.log(`MinimalForwarder: ${forwarder.address}\nSpaceStation: ${space_station.address}`);
}

if (require.main === module) {
  main().then(() => process.exit(0))
    .catch(error => { console.error(error); process.exit(1); });
}
