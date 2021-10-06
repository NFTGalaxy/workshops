const { ethers } = require('hardhat');
const { signMetaTxRequest } = require('../src/signer');
const { readFileSync, writeFileSync } = require('fs');

function getInstance(name) {
  const address = JSON.parse(readFileSync('deploy.json'))[name];
  if (!address) throw new Error(`Contract ${name} not found in deploy.json`);
  return ethers.getContractFactory(name).then(f => f.attach(address));
}

async function main() {
  const forwarder = await getInstance('MinimalForwarder');
  const space_station = await getInstance("SpaceStationV1Meta");

  const { PRIVATE_KEY: signer } = process.env;
  const from = new ethers.Wallet(signer).address;
  console.log(`Signing claim as ${from}...`);
  // read json input
  let jsonfile = require('./input.json')
  let ss = jsonfile["SpaceStation"]   
  let cid = jsonfile["cid"]   
  let nft = jsonfile["StartNFT"]   
  let id = jsonfile["dummyId"]   
  let pow = jsonfile["powah"]   
  let sig = jsonfile["signature"]   
  let sig2 = jsonfile["sig2"]   
  const data = space_station.interface.encodeFunctionData('claim', [ss, cid, nft, id, pow, sig, sig2]);
  const result = await signMetaTxRequest(signer, forwarder, {
    to: space_station.address, from, data
  });

  writeFileSync('tmp/request.json', JSON.stringify(result, null, 2));
  console.log(`Signature: `, result.signature);
  console.log(`Request: `, result.request);
}

if (require.main === module) {
  main().then(() => process.exit(0))
    .catch(error => { console.error(error); process.exit(1); });
}
