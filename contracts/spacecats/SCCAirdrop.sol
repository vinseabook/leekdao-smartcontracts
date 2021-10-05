//SPDX-License-Identifier: MIT
// Ropsten: 0xd02c628c4827acE942e4B6CA4BD465A1aC0e449a
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SCCAirDrop is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    mapping(address => bool) public airdropSuccess;

    uint public airdropAmount;
    ERC20 public token;

    constructor(ERC20 token_, uint airdropAmount_) {
        token = token_;
        airdropAmount = airdropAmount_ * 10 ** (token.decimals());
    }

    function airdrop(address[] memory addr_, uint[] memory qty_) external onlyOwner {
        for(uint i = 0; i < addr_.length; i++) {
            address airdropAddr = addr_[i];
            uint amount = airdropAmount.mul(qty_[i]);
            require(airdropSuccess[airdropAddr] == false, "It's already airdropped");
            airdropSuccess[airdropAddr] = true;
            token.safeTransfer(airdropAddr, amount);
        }
    }
}