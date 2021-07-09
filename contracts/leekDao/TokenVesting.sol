//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenVesting is TokenTimelock, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  uint public linearReleaseInterval;
  uint public releaseTotalCount;
  uint public nextReleaseTime;
  uint public releaseCount = 0;
  uint public releaseAmount = 0;
  uint public finalTime = 0;
  uint public cliff = 0;
  bool public isCalculated = false;

  constructor(IERC20 token_,
        address beneficiary_,
        uint256 cliff_,
        uint linearReleaseInterval_, uint releaseTotalCount_) TokenTimelock(token_, beneficiary_, block.timestamp.add(cliff_)) {
    linearReleaseInterval = linearReleaseInterval_;
    releaseTotalCount = releaseTotalCount_;
    nextReleaseTime = block.timestamp.add(cliff_);
    cliff = cliff_;
    finalTime = nextReleaseTime.add(linearReleaseInterval.mul(releaseTotalCount));
  }

  /**
    Calculate Once before hand to understand how much amount to release every time
    and only calculate once
  */
  function calculateReleaseAmount() public {
    require(!isCalculated, "You calculated release amount already!");
    isCalculated = true;

    uint256 amount = token().balanceOf(address(this));
    require(amount > 0, "TokenTimelock: no tokens to release");

    releaseAmount = amount.div(releaseTotalCount);
  }

  function release() public override nonReentrant() {
    require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");
    require(isCalculated, "Need to cacluate the release amount first");
    require(releaseCount < releaseTotalCount, "Release count exceeds total");
    require(block.timestamp >= nextReleaseTime, "Token next release time are not reached");

    uint256 remaining = token().balanceOf(address(this));
    require(remaining > 0, "TokenTimelock: no tokens to release");

    if (block.timestamp >= finalTime) {
      token().safeTransfer(beneficiary(), remaining);
    } else {
      token().safeTransfer(beneficiary(), releaseAmount);
    }

    releaseCount ++;
    nextReleaseTime = nextReleaseTime.add(linearReleaseInterval);
  }

  function remainingTokens() public view returns (uint) {
    return token().balanceOf(address(this));
  }
}