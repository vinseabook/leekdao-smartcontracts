// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./UniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract PriceFeed {
    function getLPTotalValue(UniswapV2Pair _uniswapV2Pair) view external returns (address [2] memory, uint [2] memory, uint) {
        address _token0 = _uniswapV2Pair.token0();
        address _token1 = _uniswapV2Pair.token1();

        (uint token0Amount, uint token1Amount, ) = _uniswapV2Pair.getReserves();
        uint totalSupply = _uniswapV2Pair.totalSupply();

        address[2] memory tokens = [_token0, _token1];

        IERC20Uniswap token0 = IERC20Uniswap(_token0);
        IERC20Uniswap token1 = IERC20Uniswap(_token1);

        string memory token0Symbol = token0.symbol();
        string memory token1Symbol = token1.symbol();

        uint[2] memory amount = [token0Amount, token1Amount];
        return (tokens, amount, totalSupply);
    }

}