//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract LuckyDraw is Ownable, VRFConsumerBase {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    bytes32 internal keyHash;
    uint256 internal fee;

    address[] private participants;

    mapping(uint => address[]) private roundWinners;
    mapping(uint => RoundInfo) private roundInfoMapping;

    uint public currentRound = 1;
    uint public rewards;

    event LuckyDrawEvent(bytes32 indexed requestId, uint roundNumber, address[] winners);

    ERC20 public token;

    struct RoundInfo {
        bytes32 requestId;
        uint drawNumber;
    }

    constructor(ERC20 token_, address vrfCoordinator_, address linkToken_, bytes32 keyHash_, uint fees_)
        VRFConsumerBase(
            vrfCoordinator_,
            linkToken_
        )
    {
        keyHash = keyHash_;
        fee = fees_;
        token = token_;
        rewards = 10 * 10 ** (token.decimals());
    }

    function setRewards(uint amount_) public onlyOwner {
        rewards = amount_ * 10 ** (token.decimals());
    }

    function participate(address[] memory addresses) public onlyOwner {
        for(uint i = 0; i < addresses.length; i++) {
            participants.push(addresses[i]);
        }
    }

    function luckyDraw(uint number) public onlyOwner {
        bytes32 _requestId = getRandomNumber();
        roundInfoMapping[currentRound] = RoundInfo({
            requestId: _requestId,
            drawNumber: number
        });
    }

    function resetParticipants() public onlyOwner {
        delete participants;
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() public onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        RoundInfo storage roundInfo = roundInfoMapping[currentRound];
        bytes32 _requestId = roundInfo.requestId;
        require(_requestId == requestId, "The oracle requestId is not matched");

        uint drawNo = roundInfo.drawNumber;
        address[] storage winners = roundWinners[currentRound];

        for (uint i = 0; i < drawNo; i++) {
            uint randomNumber = uint(keccak256(abi.encode(randomness, i)));
            uint randomIndex = (randomNumber % participants.length);
            address luckyPerson = participants[randomIndex];

            participants[randomIndex] = participants[participants.length - 1];
            participants.pop();

            token.safeTransfer(luckyPerson, rewards);
            winners.push(luckyPerson);
        }
        currentRound++;
        emit LuckyDrawEvent(requestId, currentRound, winners);
    }

    function getWinners(uint round) public view returns (address[] memory) {
        require (round < currentRound, "The current round is not drawn yet!");
        return roundWinners[round];
    }

    function getParticipants() public view returns (address[] memory) {
        return participants;
    }

}