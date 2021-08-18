// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./WorldMapBillBoard.sol";

contract WorldMapBillBoardCollection is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    WorldMapBillBoard public worldMapBillBoard;

    constructor(WorldMapBillBoard worldMapBillBoard_) ERC721("WorldMap BillBoard Collection", "WMBBC") {
        worldMapBillBoard = worldMapBillBoard_;
    }

    function mint(uint boardId, string memory tokenURI) public nonReentrant returns (uint256) {
        WorldMapBillBoard.BillBoard memory billBoard = findBillBoard(boardId);

        require(billBoard.owner == msg.sender, "You are not the owner of this billboard!");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function findBillBoard(uint billBoadId) internal view returns (WorldMapBillBoard.BillBoard memory)  {
        WorldMapBillBoard.BillBoard[] memory _billBoards_ = worldMapBillBoard.getAllBillBoards();

        WorldMapBillBoard.BillBoard memory found;
        for (uint i = 0; i < _billBoards_.length; i++) {
            WorldMapBillBoard.BillBoard memory tempBoard = _billBoards_[i];
            if (tempBoard.id == billBoadId) {
                found = tempBoard;
                break;
            }
        }

        return found;
    }


    function updateTokenURI(uint tokenId, string memory newTokenURI) public onlyOwner {
        _setTokenURI(tokenId, newTokenURI);
    }
}