//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IStrategy {
    struct DepositParams {
        uint256[] amountsOutMin;
        address[][] paths;
        uint256 strategyId;
        uint256 amount;
        address token;
        bytes[] data;
    }

    struct WithdrawParams {
        uint256[] amountsOutMin;
        address[][] paths;
        uint256 strategyId;
        uint256 amount;
        address token;
        bytes[] data;
    }

    function deposit(
        DepositParams memory params,
        address user
    ) external returns (uint256);

    function withdraw(WithdrawParams memory params, address user) external;

    function compound(
        uint256[] memory amountsOutMin
    ) external returns (uint256);
}
