// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./WorldMapBillBoard.sol";

contract WorldMapBillBoardCollection is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    WorldMapBillBoard public worldMapBillBoard;

    uint public mintPrice;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    constructor(WorldMapBillBoard worldMapBillBoard_) ERC721("WorldMapBillBoardCollection", "WMBB") {
        worldMapBillBoard = worldMapBillBoard_;
        mintPrice = 1 ether;
    }

    function mint(uint boardId, string memory _tokenURI) public payable nonReentrant returns (uint256) {

        require(boardId >= 0, "Board id doesnt exists!");
        require(bytes(_tokenURI).length > 28, "Token URI format is wrong!");
        require(msg.value >= mintPrice, "You need to pay a little to avoid spam!");

        WorldMapBillBoard.BillBoard memory billBoard = findBillBoard(boardId);

        require(billBoard.owner == msg.sender, "You are not the owner of this billboard!");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI);

        return newItemId;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
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


    function updateTokenURI(uint tokenId, string memory newTokenURI) external onlyOwner {
        _setTokenURI(tokenId, newTokenURI);
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");

        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function tokensOfOwner(address _owner) external view returns(uint256[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }

    function withdraw() external onlyOwner {
        uint amount = address(this).balance;
        address payable _owner = payable(owner());
        bool result = _owner.send(amount);
        require(result, "Withdraw failed!");
    }

    function setMintPrice(uint _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

}