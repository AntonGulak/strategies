//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface ISwapHelper {
    function swapUniswapV3(
        address poolAddress,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bytes memory data
    ) external returns (uint256);

    function swapUniswapV2(
        address poolAddress,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bytes memory data
    ) external returns (uint256);
}
