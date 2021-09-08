// SPDX-License-Identifier: MIT
// SpaceCatsOpenDesign live smart contract 0xB8f746Dde4eCD814C282f5377c9F837203Fb3b44
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpaceCatsOpenDesign is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor() ERC721("SpaceCatsOpenDesign", "SCOD") {}

    function mintSpaceCatOpenDesign(string memory tokenURI) public onlyOwner returns (uint256)
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
            uint id = mintSpaceCatOpenDesign(tokenURI);
            allIds[index] = id;
        }

        return allIds;
    }

    function updateTokenURI(uint tokenId, string memory newTokenURI) public onlyOwner {
        _setTokenURI(tokenId, newTokenURI);
    }
}