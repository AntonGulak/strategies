//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/ISwapHelper.sol";

error IncorrectTokenOut();

contract SwapHelper is ISwapHelper {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function swapUniswapV3(
        address poolAddress,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bytes memory data
    ) external returns (uint256) {
        IERC20Upgradeable(tokenIn).safeIncreaseAllowance(poolAddress, amountIn);

        if (_extractLastAddress(data) != tokenOut) {
            revert IncorrectTokenOut();
        }

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams(
                data,
                address(this),
                type(uint256).max,
                amountIn,
                amountOutMin
            );

        return ISwapRouter(poolAddress).exactInput(params);
    }

    function swapUniswapV2(
        address poolAddress,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bytes memory data
    ) external returns (uint256) {
        IERC20Upgradeable(tokenIn).safeIncreaseAllowance(poolAddress, amountIn);

        address[] memory path = _bytesToAddressArray(data);
        if (path[path.length - 1] != tokenOut) {
            revert IncorrectTokenOut();
        }

        uint256[] memory amounts = IUniswapV2Router02(poolAddress)
            .swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                type(uint256).max
            );

        return amounts[amounts.length - 1];
    }

    //TODO: Integration with any other dex is also possible.

    //need to test
    function _bytesToAddressArray(
        bytes memory data
    ) private pure returns (address[] memory) {
        require(data.length % 20 == 0, "Invalid data length"); // An address occupies 20 bytes

        uint256 numAddresses = data.length / 20;
        address[] memory addresses = new address[](numAddresses);

        assembly {
            // Get the pointer to the start of data in the array
            let dataPointer := add(data, 0x20)

            for {
                let i := 0
            } lt(i, numAddresses) {
                i := add(i, 1)
            } {
                // Copy 20 bytes (size of address) from the data array to a temporary variable
                let addressData := mload(dataPointer)
                // Convert the temporary variable to an address and add it to the addresses array
                mstore(add(addresses, mul(i, 0x20)), addressData)

                // Move the pointer to the next address in the data array
                dataPointer := add(dataPointer, 0x20)
            }
        }

        return addresses;
    }

    //need to test
    function _extractLastAddress(
        bytes memory data
    ) internal pure returns (address) {
        require(data.length % 20 == 0, "Invalid data length"); // An address occupies 20 bytes

        uint256 numAddresses = data.length / 20;
        require(numAddresses > 0, "No addresses in the data");

        // Calculate the starting position of the last address in the data
        uint256 lastAddressPosition = data.length - 20;

        address lastAddress;
        assembly {
            // Load the last address from the data into a temporary variable
            lastAddress := mload(add(data, lastAddressPosition))
        }

        return lastAddress;
    }
}
