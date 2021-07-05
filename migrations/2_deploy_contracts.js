/* eslint-disable no-undef */
const LeekToken = artifacts.require("LeekToken");
const TokenVesting = artifacts.require('TokenVesting');

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(LeekToken, 18, 10000000);
  let leekToken = await LeekToken.deployed()
  console.log(leekToken.address)

  await deployer.deploy(TokenVesting, leekToken.address, accounts[0], 10000000000, 1000, 6);
};
