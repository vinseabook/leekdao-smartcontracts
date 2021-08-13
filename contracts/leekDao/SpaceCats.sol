// SPDX-License-Identifier: MIT
// spacecats live smart contract 0xB2cbdc22D0fc9dA42954d9D06bb946e8D77Dbf70
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpaceCats is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor() ERC721("SpaceCats", "SPACECATS") {}

    function mintSpaceCat(string memory tokenURI) public onlyOwner returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(owner(), newItemId);
        string memory _tokenURI = buildTokenURI(tokenURI, newItemId);
        _setTokenURI(newItemId, _tokenURI);

        return newItemId;
    }

    function buildTokenURI(string memory ipfsHash, uint256 tokenId) public pure returns (string memory) {
        return string(abi.encodePacked(ipfsHash, '/', tokenId.toString()));
    }

    function bulkMint(uint256 numCats, string memory tokenURI) public onlyOwner returns (uint[] memory) {
        require(numCats > 1 && numCats <= 200, "You cant bulk mint more than 200 cats due to gas limitations");
        uint[] memory allIds = new uint[](numCats);

        for (uint256 index = 0; index < numCats; index++) {
            uint id = mintSpaceCat(tokenURI);
            allIds[index] = id;
        }

        return allIds;
    }

    function updateTokenURI(uint tokenId, string memory newTokenURI) public onlyOwner {
        _setTokenURI(tokenId, newTokenURI);
    }
}