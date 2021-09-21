// SPDX-License-Identifier: MIT
// spacecats live smart contract 0xdb6430D05AbFD71ccE56cE7F95E76D3F2FCa4A36
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./SpaceCats.sol";

contract SpaceCatsTool is Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    SpaceCats private spaceCats;

    constructor (SpaceCats _spaceCats) {
        spaceCats = _spaceCats;
    }

    function bulkUpdateURI(uint startTokenId, uint number, string memory ipfsHash) external onlyOwner {
        uint upto = startTokenId.add(number);

        for (uint tokenId = startTokenId; tokenId < upto; tokenId++) {
            string memory newTokenURI = spaceCats.buildTokenURI(ipfsHash, tokenId);
            spaceCats.updateTokenURI(tokenId, newTokenURI);
        }
    }

    function transferSpaceCatsOwnership(address newOwner) external onlyOwner {
        spaceCats.transferOwnership(newOwner);
    }
}