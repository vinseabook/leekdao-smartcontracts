// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Crowdsale.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedAllowanceCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public _openingTime;
    uint256 public _closingTime;

    address public _tokenWallet;

    /**
     * Event for crowdsale extending
     * @param newClosingTime new closing time
     * @param prevClosingTime old closing time
     */
    event TimedCrowdsaleExtended(
        uint256 prevClosingTime,
        uint256 newClosingTime
    );

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    /**
     * @dev Constructor, takes crowdsale opening and closing times.
     * @param openingTime Crowdsale opening time
     * @param closingTime Crowdsale closing time
     */
    constructor(
        uint256 openingTime,
        uint256 closingTime,
        uint256 rate,
        address payable wallet,
        IERC20 token,
        address tokenWallet
    ) Crowdsale(rate, wallet, token) {
        // solhint-disable-next-line not-rely-on-time
        require(
            openingTime >= block.timestamp,
            "TimedCrowdsale: opening time is before current time"
        );
        // solhint-disable-next-line max-line-length
        require(
            closingTime > openingTime,
            "TimedCrowdsale: opening time is not before closing time"
        );
        require(
            tokenWallet != address(0),
            "AllowanceCrowdsale: token wallet is the zero address"
        );

        _tokenWallet = tokenWallet;
        _openingTime = openingTime;
        _closingTime = closingTime;
    }

    function setOpeningTime(uint256 _openingTime_) external onlyOwner {
        _openingTime = _openingTime_;
    }

    function setClosingTime(uint256 _closingTime_) external onlyOwner {
        _closingTime = _closingTime_;
    }

    /**
     * @return true if the crowdsale is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return
            block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp > _closingTime;
    }

    /**
     * @dev Extend parent behavior requiring to be within contributing period.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
        override
        onlyWhileOpen
    {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    /**
     * @dev Extend crowdsale.
     * @param newClosingTime Crowdsale closing time
     */
    function _extendTime(uint256 newClosingTime) internal {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        // solhint-disable-next-line max-line-length
        require(
            newClosingTime > _closingTime,
            "TimedCrowdsale: new closing time is before current closing time"
        );

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }

    /**
     * @dev Checks the amount of tokens left in the allowance.
     * @return Amount of tokens left in the allowance
     */
    function remainingTokens() public view returns (uint256) {
        return
            Math.min(
                _token.balanceOf(_tokenWallet),
                _token.allowance(_tokenWallet, address(this))
            );
    }

    /**
     * @dev Overrides parent behavior by transferring tokens from wallet.
     * @param beneficiary Token purchaser
     * @param tokenAmount Amount of tokens purchased
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount)
        internal
        override
    {
        _token.safeTransferFrom(_tokenWallet, beneficiary, tokenAmount);
    }
}
