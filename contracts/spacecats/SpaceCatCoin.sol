// contracts/SpaceCatCoin.sol
// SPDX-License-Identifier: MIT
// SCC polygon 0x29640079a29dee1A53846f2e9aB9D8d070034CE7
// SCC ropsten 0xB2cbdc22D0fc9dA42954d9D06bb946e8D77Dbf70
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SpaceCatCoin is ERC20 {
    constructor(uint256 initialSupply) ERC20("SpaceCatCoin", "SCC") {
        _mint(msg.sender, initialSupply);
    }
}