//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WorldMapBillBoard is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ERC20 public token;
    uint public basePrice;
    uint public splitRatio;
    uint public minimumTokenAmountToCreate;

    bool public paused;

    struct BillBoard {
        uint id;
        string city;
        string ipfsHash;
        string twitter;
        string desc;
        uint bidLevel;
        address owner;
        bool init;
    }

    mapping(uint => BillBoard) public billBoards;

    uint[] private allBillBoards;

    constructor(ERC20 token_, uint basePrice_, uint ratio_, uint minimum_) {
        token = token_;
        require (basePrice_ >= 1 && basePrice_ <= 10000, "Base Price must be between 1 to 100");
        basePrice = basePrice_ * 10 ** (token.decimals());
        require (ratio_ >= 1 && ratio_ <= 100, "Split ratio must be between 1 to 100");
        splitRatio = ratio_;
        minimumTokenAmountToCreate = minimum_ * 10 ** (token.decimals());
        paused = true;
    }

    function bid(uint id_, string memory city_, string memory ipfsHash_, string memory desc_, string memory twitter_) public nonReentrant {
        require(!paused, "The game is paused!");

        require(msg.sender != address(0), "Please input valid msg sender address!");
        require(bytes(city_).length > 3, "Please input valid city!");
        require(bytes(ipfsHash_).length > 3, "Please input valid ipfs hash!");
        require(bytes(desc_).length > 0, "Please input valid desc!");

        BillBoard storage billBoard = billBoards[id_];
        uint tokenBalance = token.balanceOf(msg.sender);
        require(tokenBalance > 0, "You dont have enough fund!");

        if (billBoard.init == true) {
            uint prevBidLevel = billBoard.bidLevel;
            uint requiredFund = basePrice.mul(prevBidLevel);
            require(tokenBalance > requiredFund, "You dont have enough fund!");
            billBoard.ipfsHash = ipfsHash_;
            billBoard.desc = desc_;
            billBoard.twitter = twitter_;
            billBoard.bidLevel = prevBidLevel.mul(2);
            address prevOwner = billBoard.owner;
            billBoard.owner = msg.sender;

            uint amount4Previous = requiredFund.mul(splitRatio).div(100);
            token.transferFrom(msg.sender, prevOwner, amount4Previous);

            uint remainingAmount = requiredFund.sub(amount4Previous);
            token.transferFrom(msg.sender, address(this), remainingAmount);
        } else {
            require(tokenBalance > minimumTokenAmountToCreate, "You dont meet the minimum token amount requirement.");
            require(tokenBalance > basePrice, "You dont have enough fund!");
            BillBoard memory newBillBoard;
            newBillBoard.id = id_;
            newBillBoard.city = city_;
            newBillBoard.ipfsHash = ipfsHash_;
            newBillBoard.desc = desc_;
            newBillBoard.twitter = twitter_;
            newBillBoard.bidLevel = 2;
            newBillBoard.owner = msg.sender;
            newBillBoard.init = true;
            billBoards[id_] = newBillBoard;
            token.transferFrom(msg.sender, address(this), basePrice);
            allBillBoards.push(id_);
        }
    }

    function setBasePrice(uint basePrice_) public onlyOwner {
        require (basePrice_ >= 1 && basePrice_ <= 10000, "Base Price must be between 1 to 100");
        basePrice = basePrice_ * 10 ** (token.decimals());
    }

    function setSplitRatio(uint ratio_) public onlyOwner {
        require (ratio_ >= 1 && ratio_ <= 100, "Split ratio must be between 1 to 100");
        splitRatio = ratio_;
    }

    function withDraw() public onlyOwner {
        uint tokenBal = token.balanceOf(address(this));
        require (tokenBal > 0, "There is no token left in the contract");
        token.transfer(msg.sender, tokenBal);
    }

    function setMinimumTokenAmount(uint minimum_) public onlyOwner {
        require (minimum_ > minimumTokenAmountToCreate, "Split ratio must be between 1 to 100");
        minimumTokenAmountToCreate = minimum_ * 10 ** (token.decimals());
    }

    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    function getAllBillBoards() public view returns (BillBoard[] memory) {
        BillBoard[] memory _billBoards_ = new BillBoard[](allBillBoards.length);

        for (uint i = 0; i < allBillBoards.length; i++) {
            _billBoards_[i] = billBoards[allBillBoards[i]];
        }

        return _billBoards_;
    }
 }