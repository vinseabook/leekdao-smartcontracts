/* eslint-disable no-undef */
const LeekToken = artifacts.require("LeekToken");

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(LeekToken, 18, 10000000);
  let leekToken = await LeekToken.deployed()
  console.log(leekToken.address)
};
