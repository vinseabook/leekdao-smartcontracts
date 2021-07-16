//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract LuckyDraw is Ownable, VRFConsumerBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 internal keyHash;
    uint256 internal fee;

    address[] public participants;

    mapping(uint => address[]) public roundWinners;
    mapping(uint => RoundInfo) public roundInfoMapping;

    uint public currentRound = 1;
    uint public rewards = 10 * 10 ** 18;

    event LuckyDrawRequest(bytes32 indexed requestId, uint roundNumber, uint drawNumber);

    // The token being sold
    IERC20 public _token;

    struct RoundInfo {
        bytes32 requestId;
        uint drawNumber;
    }

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Polygon (Matic) Mumbai Testnet
     * Chainlink VRF Coordinator address: 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Key Hash: 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
     */
    constructor(IERC20 token_)
        VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        )
    {
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001 * 10 ** 18; // 0.0001 LINK (Varies by network)
        _token = token_;
    }

    function participate(address[] memory addresses) onlyOwner public {
        for(uint i = 0; i < addresses.length; i++) {
            participants.push(addresses[i]);
        }
    }

    function luckyDraw(uint number) onlyOwner public {
        bytes32 _requestId = getRandomNumber();
        roundInfoMapping[currentRound] = RoundInfo({
            requestId: _requestId,
            drawNumber: number
        });

        emit LuckyDrawRequest(_requestId, currentRound, number);
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() onlyOwner public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        RoundInfo storage roundInfo = roundInfoMapping[currentRound];
        bytes32 _requestId = roundInfo.requestId;
        uint drawNo = roundInfo.drawNumber;
        require(_requestId == requestId, "The oracle requestId is not matched");

        address[] storage winners = roundWinners[currentRound];

        for (uint i = 0; i < drawNo; i++) {
            uint randomNumber = uint(keccak256(abi.encode(randomness, i)));
            uint randomIndex = (randomNumber % participants.length);
            address luckyPerson = participants[randomIndex];

            participants[randomIndex] = participants[participants.length - 1];
            participants.pop();

            _token.safeTransfer(luckyPerson, rewards);
            winners.push(luckyPerson);
        }
        currentRound++;
    }

}