// SPDX-License-Identifier: MIT
// ftm mainnet 0x33f8B87839cb8AE43D7565a08920A078A32043A6
//[611207,611440,611758,611910,612017,612496,612679,612830,613042,613211,613291]
//[969483,1010108,1010109,1010110,1010111,1010112,1010113,1010114,1010115,1010116,1010117, 1010118]
pragma solidity ^0.8.0;

import "./Rarity.sol";
import "./StatusLevel.sol";
import "./interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RMToolBox is IERC721Receiver, AccessControl, Ownable {
  Rarity public rm;
  StatusLevel public sl;

  mapping(address => uint[]) private rarityTokenIds; // level up inside contracts
  mapping(address => uint[]) private rarityTokenIdsExtended; // If you minted already, set this

  bytes32 public constant SUPPORTER_ROLE = keccak256("EARLY SUPPORTERS");


  constructor(Rarity _rm, StatusLevel _sl) {
    rm = _rm;
    sl = _sl;
  }

  function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
      return this.onERC721Received.selector;
  }

  function whitelist(address[] memory addresses) public onlyOwner {
      for(uint i = 0; i < addresses.length; i++) {
        _setupRole(SUPPORTER_ROLE, addresses[i]);
      }
  }

  function summon(uint classId) external {
    require(hasRole(SUPPORTER_ROLE, msg.sender)
      || sl.hasPrivileges(msg.sender, sl.BRONZE()), "You are not eligible!");

    uint[] storage heros = rarityTokenIds[msg.sender];
    uint tokenId = rm.next_summoner();
    heros.push(tokenId);
    rm.summon(classId);
  }

  function bulkSummon() external {
    require(hasRole(SUPPORTER_ROLE, msg.sender)
      || sl.hasPrivileges(msg.sender, sl.BRONZE()), "You are not eligible!");

    uint[] storage heros = rarityTokenIds[msg.sender];
    for (uint i = 1; i <= 11; i++) {
      uint tokenId = rm.next_summoner();
      heros.push(tokenId);
      rm.summon(i);
    }
  }

  function adventure(uint tokenId) external {
    require(hasRole(SUPPORTER_ROLE, msg.sender)
      || sl.hasPrivileges(msg.sender, sl.BRONZE()), "You are not eligible!");

    rm.adventure(tokenId);
  }

  function bulkAdventure() external {
    require(hasRole(SUPPORTER_ROLE, msg.sender)
      || sl.hasPrivileges(msg.sender, sl.BRONZE()), "You are not eligible!");

    uint[] storage heros = rarityTokenIds[msg.sender];
    for (uint i = 0; i < heros.length; i++) {
      uint tokenId = heros[i];

      if (tokenId == 0) {
        continue;
      }

      rm.adventure(tokenId);
    }
  }

  function setRarityTokenIdsExtended(uint[] memory tokenIds) external {
    uint[] storage heros = rarityTokenIdsExtended[msg.sender];
    for (uint i = 0; i < tokenIds.length; i++) {
      uint tokenId = tokenIds[i];
      if (tokenId == 0) {
        continue;
      }
      heros.push(tokenId);
    }
  }

  function bulkAdventureEx() external {
    require(hasRole(SUPPORTER_ROLE, msg.sender)
      || sl.hasPrivileges(msg.sender, sl.BRONZE()), "You are not eligible!");

    uint[] memory heros = rarityTokenIdsExtended[msg.sender];
    for (uint i = 0; i < heros.length; i++) {
      uint tokenId = heros[i];

      if (tokenId == 0) {
        continue;
      }

      rm.adventure(tokenId);
    }

  }

  function withDraw(uint tokenId) external {
    uint[] storage heros = rarityTokenIds[msg.sender];
    for (uint i = 0; i < heros.length; i++) {
      if (tokenId == heros[i]) {
        delete heros[i];
        rm.safeTransferFrom(address(this), msg.sender, tokenId);
        break;
      }
    }
  }

  function withDrawAll() external {
    uint[] storage heros = rarityTokenIds[msg.sender];
    for (uint i = 0; i < heros.length; i++) {
      uint tokenId = heros[i];
      if (tokenId == 0) {
        continue;
      }
      delete heros[i];
      rm.safeTransferFrom(address(this), msg.sender, tokenId);
    }
  }

  function getRarityTokenIds() external view returns (uint[] memory) {
      return rarityTokenIds[msg.sender];
  }

  function getRarityTokenIdsExtended() external view returns (uint[] memory) {
      return rarityTokenIdsExtended[msg.sender];
  }

}