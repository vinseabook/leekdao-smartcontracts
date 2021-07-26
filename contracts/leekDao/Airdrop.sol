//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Airdrop is Ownable, AccessControl, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // Create a new role identifier for the airdrop role
    bytes32 public constant AIRDROP_ROLE = keccak256("AIRDROP_ROLE");
    bytes32 public constant AIRDROP_VIP_ROLE = keccak256("AIRDROP_VIP_ROLE");

    mapping(address => bool) private airdropSuccess;

    uint public airdropAmount;
    uint public vipAirdropAmount;
    uint public startBlockNumber;
    uint public finishBlockNumber;

    event AirdropEvent(bytes32 indexed requestId, uint roundNumber, address[] winners);

    ERC20 public token;

    constructor(ERC20 token_, uint startBlockNumber_, uint finishBlockNumber_)
    {
        token = token_;
        airdropAmount = 10 * 10 ** (token.decimals());
        vipAirdropAmount = 100 * 10 ** (token.decimals());
        startBlockNumber = startBlockNumber_;
        finishBlockNumber = finishBlockNumber_;
    }

    function setStartBlockNumber(uint startBlockNumber_) public onlyOwner {
        startBlockNumber = startBlockNumber_;
    }

    function setFinishBlockNumber(uint finishBlockNumber_) public onlyOwner {
        finishBlockNumber = finishBlockNumber_;
    }

    function setAirdropAmount(uint amount_) public onlyOwner {
        airdropAmount = amount_ * 10 ** (token.decimals());
    }

    function setVipAirdropAmount(uint amount_) public onlyOwner {
        vipAirdropAmount = amount_ * 10 ** (token.decimals());
    }

    function whitelist(address[] memory addresses) public onlyOwner {
        for(uint i = 0; i < addresses.length; i++) {
          _setupRole(AIRDROP_ROLE, addresses[i]);
        }
    }

    function whitelistVIP(address[] memory vipAddresses) public onlyOwner {
        for(uint i = 0; i < vipAddresses.length; i++) {
          _setupRole(AIRDROP_VIP_ROLE, vipAddresses[i]);
        }
    }

    function getAirdrop() public nonReentrant {
      require(block.number > startBlockNumber, "The airdrop event has not started yet!");
      require(block.number < finishBlockNumber, "The airdrop event has finished!");
      require(hasRole(AIRDROP_ROLE, msg.sender) || hasRole(AIRDROP_VIP_ROLE, msg.sender), "You must be whitelisted or VIP!");
      require(airdropSuccess[msg.sender] == false, "You have already collected airdrop!");

      if (hasRole(AIRDROP_VIP_ROLE, msg.sender)) {
        token.safeTransfer(msg.sender, vipAirdropAmount);
      } else {
        token.safeTransfer(msg.sender, airdropAmount);
      }

      airdropSuccess[msg.sender] = true;
    }

    function isWhitelisted(address user) public view returns (bool) {
      return hasRole(AIRDROP_ROLE, user);
    }

    function isVIP(address user) public view returns (bool) {
      return hasRole(AIRDROP_VIP_ROLE, user);
    }

    function remainingTokens() public view returns (uint) {
      return token.balanceOf(address(this));
    }

}