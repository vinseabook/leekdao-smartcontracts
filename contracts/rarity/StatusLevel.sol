// SPDX-License-Identifier: MIT
// ftm mainnet 0x53aD2089E3973EbcA40BfBcf236f1397C091D639
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StatusLevel is ERC1155, Ownable {
    uint256 public constant BRONZE = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant GOLD = 2;
    uint256 public constant DIAMOND = 3;


    uint public constant BRONZE_FEE = 10 ether;
    uint public constant SILVER_FEE = 100 ether;
    uint public constant GOLD_FEE = 1000 ether;
    uint public constant DIAMOND_FEE = 5000 ether;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, BRONZE, 200, "");
        _mint(msg.sender, SILVER, 10, "");
        _mint(msg.sender, GOLD, 5, "");
        _mint(msg.sender, DIAMOND, 1, "");
    }

    function mintStatusCard(uint level) external payable {
        if (level == BRONZE) {
            require(msg.value >= BRONZE_FEE, "Fees are not enough for Bronze.");
            _mint(msg.sender, BRONZE, 1, "");
        } else if (level == SILVER) {
            require(msg.value >= SILVER_FEE, "Fees are not enough for Silver.");
            _mint(msg.sender, SILVER, 1, "");
        } else if (level == GOLD) {
            require(msg.value >= GOLD_FEE, "Fees are not enough for Gold.");
            _mint(msg.sender, GOLD, 1, "");
        } else if (level == DIAMOND) {
            require(msg.value >= DIAMOND_FEE, "Fees are not enough for Diamond.");
            _mint(msg.sender, DIAMOND, 1, "");
        }
    }

    function hasPrivileges(address owner, uint level) public view returns (bool) {
        uint bronzeCount = balanceOf(owner, BRONZE);
        uint silverCount = balanceOf(owner, SILVER);
        uint goldCount = balanceOf(owner, GOLD);
        uint diamondCount = balanceOf(owner, DIAMOND);

        if (level == BRONZE) {
            return (bronzeCount > 0 || silverCount >0 || goldCount > 0 || diamondCount >0);
        } else if (level == SILVER) {
            return (silverCount > 0 || goldCount > 0 || diamondCount >0);
        } else if (level == GOLD) {
            return (goldCount > 0 || diamondCount >0);
        } else if (level == DIAMOND) {
            return (diamondCount > 0);
        } else {
            return false;
        }
    }

    function burn(uint level, uint amount) external {
        _burn(msg.sender, level, amount);
    }

    function isBronze() external view returns (bool) {
        return hasPrivileges(msg.sender, BRONZE);
    }

    function isSilver() external view returns (bool) {
        return hasPrivileges(msg.sender, SILVER);
    }

    function isGold() external view returns (bool) {
        return hasPrivileges(msg.sender, GOLD);
    }

    function isDimond() external view returns (bool) {
        return hasPrivileges(msg.sender, DIAMOND);
    }

}