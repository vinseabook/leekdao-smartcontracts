// contracts/PenguinEvolution.sol
// SPDX-License-Identifier: MIT
// RINKBEY： 0xc7433e8D70980c51FEbca1F62a28a90e2293A455

pragma solidity ^0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/access/AccessControl.sol";

contract PenguinEvolution is ERC721, AccessControl, Ownable {
    using SafeMath for uint256;
    // Create a new role identifier for the airdrop role
    bytes32 public constant AIRDROP_ROLE = keccak256("AIRDROP_ROLE");
    uint public constant MAX_PENGUINS = 10000;
    uint public constant MAX_ADOPTION = 20;
    uint public constant RESERVE_PENGUINS = 30;
    uint public constant FLAT_PRICE = 0.04 ether;

    bool public hasSaleStarted;
    mapping(address => bool) public airdropSuccess;

    constructor(string memory baseURI) ERC721("Penguin Evolution","PE")  {
        setBaseURI(baseURI);
        hasSaleStarted = false;
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

   function adopt(uint256 num) public payable {
        require(hasSaleStarted == true, "Sale hasn't started");
        require(totalSupply() <= MAX_PENGUINS, "Sale has already ended");
        require(num >= 1 && num <= MAX_ADOPTION, "You can adopt minimum 1, maximum 50 dumb ducks");
        require(totalSupply().add(num) <= MAX_PENGUINS, "Exceeds MAX_DUMBDUCKS 10000");
        require(msg.value >= FLAT_PRICE.mul(num), "BNB value sent is below the price");

        for (uint i = 0; i < num; i++) {
            uint mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex + 1);
        }
    }

    function whitelist(address[] memory addresses) public onlyOwner {
        for(uint i = 0; i < addresses.length; i++) {
          _setupRole(AIRDROP_ROLE, addresses[i]);
        }
    }

    function claim() public {
        require(totalSupply() <= MAX_PENGUINS, "Sale has already ended");
        require(hasRole(AIRDROP_ROLE, msg.sender), "You must be whitelisted!");
        require(airdropSuccess[msg.sender] == false, "You have already collected airdrop!");

        airdropSuccess[msg.sender] = true;

        uint mintIndex = totalSupply();
        _safeMint(msg.sender, mintIndex + 1);
    }


    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function startSale() public onlyOwner {
        hasSaleStarted = true;
    }
    function pauseSale() public onlyOwner {
        hasSaleStarted = false;
    }

    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function reserveGiveaway(uint256 num) public onlyOwner {
        uint currentSupply = totalSupply();
        require(hasSaleStarted == false, "Sale has already started");
        require(totalSupply().add(num) <= RESERVE_PENGUINS, "Exceeded giveaway supply");
        uint256 index;
        // Reserved for people who helped this project and community giveaways
        for (index = 1; index <= num; index++) {
            _safeMint(owner(), currentSupply + index);
        }
    }
}
