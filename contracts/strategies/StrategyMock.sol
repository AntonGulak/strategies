//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../interfaces/IStrategy.sol";

error OnlyContractAddress();

contract StrategyMockUpgradeable is
    IStrategy,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public tokenToStaking;
    address public swapHelper;

    //MOCK
    uint256 public depositReturn;
    uint256 public compoundReturn;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializes the contract.
     */
    function __StrategyUpgradeable_init(
        address strategiesRoot,
        address tokenToStakingInit,
        address swapHelperInit
    ) external initializer {
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __StrategyUpgradeable_init_unchained(
            strategiesRoot,
            tokenToStakingInit,
            swapHelperInit
        );
    }

    function deposit(
        IStrategy.DepositParams memory params,
        address user
    ) external nonReentrant onlyOwner returns (uint256) {
        IERC20Upgradeable(params.token).safeTransferFrom(
            user,
            address(this),
            params.amount
        );

        bytes memory data = abi.encodeWithSelector(
            bytes4(params.data[0]), //selector (ex, uniswap2 or uniswap3 swap)
            _bytesToAddress(params.data[1]), //pool address
            params.token,
            tokenToStaking,
            params.amount,
            params.amountsOutMin[0],
            params.data[2]
        );

        abi.decode(_delegateCall(swapHelper, data), (uint256));

        //TODO: additional swaps, checks, adding liquidity staking and else
        //TODO: IStaking(stakingAddress).stake(amountTokenForStaking);

        return depositReturn;
    }

    function withdraw(
        IStrategy.WithdrawParams memory /*params*/,
        address /*user*/
    ) external nonReentrant onlyOwner {
        //TODO: unstake
        //TODO: swap for required token
        //TODO: transfer tokens
    }

    function compound(
        uint256[] memory /*amountsOutMin*/
    ) external nonReentrant onlyOwner returns (uint256) {
        //TODO: claim
        //TODO: swap for strategy tokens, adding liquidity
        //TODO: stake new lp tokens

        return compoundReturn;
    }

    //Just for test, no modifiers
    function setDepositReturn(uint256 amount) external {
        depositReturn = amount;
    }

    //Just for test, no modifiers
    function setCompoundReturn(uint256 amount) external {
        compoundReturn = amount;
    }

    /**
     * @dev Initializes the contract (unchained).
     */
    function __StrategyUpgradeable_init_unchained(
        address strategiesRoot,
        address tokenToStakingInit,
        address swapHelperInit
    ) internal onlyInitializing {
        _transferOwnership(strategiesRoot);

        tokenToStaking = tokenToStakingInit;
        swapHelperInit = swapHelperInit;
    }

    function _bytesToAddress(
        bytes memory data
    ) private pure returns (address addr) {
        assembly {
            addr := mload(add(data, 20))
        }
    }

    function _delegateCall(
        address target,
        bytes memory data
    ) private returns (bytes memory) {
        if (!AddressUpgradeable.isContract(target)) {
            revert OnlyContractAddress();
        }

        (bool success, bytes memory returnData) = target.delegatecall(data);
        if (success == false) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }
        return returnData;
    }
}
