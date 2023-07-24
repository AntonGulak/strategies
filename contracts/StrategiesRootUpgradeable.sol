//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "./interfaces/IStrategy.sol";

error OnlyActiveStrategy();
error OnlyExistStrategy();
error OnlyValidWithdrawalSharesAmount();
error OnlyContractAddress();
error StrategyAlreadyExist();

contract StrategiesRootUpgradeable is
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    struct Strategy {
        uint256 totalStaked;
        uint256 totalShares;
        address strategy;
        uint64 lastCompoundTimestamp;
        bool isActive;
    }

    struct Position {
        uint256 shares;
        uint256 deposited;
    }

    event Staked(
        uint256 indexed strategyId,
        address indexed user,
        uint256 amount,
        uint256 shares
    );

    event Withdrawn(
        uint256 indexed strategyId,
        address indexed user,
        uint256 amount,
        uint256 shares
    );

    event Compounded(
        uint256 indexed strategyId,
        address indexed user,
        uint256 amount
    );

    uint256 public strategiesCount;

    mapping(address => uint256) public strategyToId;
    mapping(uint256 => Strategy) public strategies;

    mapping(address => mapping(uint256 => Position)) public positions;

    modifier onlyContract(address addressToCheck) {
        _onlyContract(addressToCheck);
        _;
    }

    modifier onlyExistingStrategy(uint256 strategyId) {
        _onlyExistingStrategy(strategyId);
        _;
    }

    modifier isStrategyActive(uint256 strategyId) {
        _isStrategyActive(strategyId);
        _;
    }

    modifier onlyValidWithdrawalSharesAmount(
        uint256 strategyId,
        address user,
        uint256 shares
    ) {
        _onlyValidWithdrawalSharesAmount(strategyId, user, shares);
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializes the contract.
     */
    function __StrategiesRootUpgradeable_init() external initializer {
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
    }

    function addStrategy(
        address strategy
    ) external onlyOwner onlyContract(strategy) {
        if (strategyToId[strategy] != 0) {
            revert StrategyAlreadyExist();
        }

        ++strategiesCount;

        Strategy storage newStrategy = strategies[strategiesCount];
        newStrategy.strategy = strategy;
        newStrategy.isActive = true;

        strategyToId[strategy] = strategiesCount;
    }

    function setStrategyStatus(
        uint256 strategyId,
        bool flag
    ) external onlyOwner onlyExistingStrategy(strategyId) {
        strategies[strategyId].isActive = flag;
    }

    function deposit(
        IStrategy.DepositParams[] memory params
    ) external nonReentrant {
        for (uint256 i = 0; i < params.length; ++i) {
            IStrategy.DepositParams memory param = params[i];

            if (param.amount > 0) {
                _onlyExistingStrategy(param.strategyId);
                _isStrategyActive(param.strategyId);

                uint256 deposited = IStrategy(
                    strategies[param.strategyId].strategy
                ).deposit(param, _msgSender());

                _deposit(param.strategyId, deposited);
            }
        }
    }

    function withdraw(
        IStrategy.WithdrawParams[] memory params
    ) external nonReentrant {
        for (uint256 i = 0; i < params.length; ++i) {
            IStrategy.WithdrawParams memory param = params[i];

            if (param.amount > 0) {
                param.amount = _withdraw(param.strategyId, param.amount);

                IStrategy(strategies[param.strategyId].strategy).withdraw(
                    param,
                    _msgSender()
                );
            }
        }
    }

    function compound(
        uint256 strategyId,
        uint256[] memory amountsOutMin
    ) external nonReentrant onlyExistingStrategy(strategyId) {
        _compound(strategyId, amountsOutMin);
    }

    function getStakedBySharesAmount(
        uint256 strategyId,
        uint256 shares
    ) external view onlyExistingStrategy(strategyId) returns (uint256) {
        return _getStakedBySharesAmount(strategyId, shares);
    }

    /**
     * @dev Initializes the contract (unchained).
     */
    function __StrategiesRootUpgradeable_init_unchained()
        internal
        onlyInitializing
    {}

    function _deposit(uint256 strategyId, uint256 amount) private {
        uint256 totalShares = strategies[strategyId].totalShares;
        uint256 shares = totalShares == 0
            ? amount
            : (amount * totalShares) / strategies[strategyId].totalStaked;

        Position storage position = positions[_msgSender()][strategyId];

        position.shares += shares;

        strategies[strategyId].totalStaked += amount;
        strategies[strategyId].totalShares += shares;

        emit Staked(strategyId, _msgSender(), amount, shares);
    }

    function _withdraw(
        uint256 strategyId,
        uint256 shares
    ) private returns (uint256) {
        Position storage position = positions[_msgSender()][strategyId];

        uint256 stakedBySharesAmount = _getStakedBySharesAmount(
            strategyId,
            shares
        );

        position.shares -= shares;
        strategies[strategyId].totalStaked -= stakedBySharesAmount;
        strategies[strategyId].totalShares -= shares;

        emit Withdrawn(strategyId, _msgSender(), stakedBySharesAmount, shares);

        return stakedBySharesAmount;
    }

    function _compound(
        uint256 strategyId,
        uint256[] memory amountsOutMin
    ) private {
        uint256 compounded = IStrategy(strategies[strategyId].strategy)
            .compound(amountsOutMin);

        strategies[strategyId].totalStaked += compounded;
        strategies[strategyId].lastCompoundTimestamp = uint64(block.timestamp);

        emit Compounded(strategyId, _msgSender(), compounded);
    }

    function _getStakedBySharesAmount(
        uint256 strategyId,
        uint256 shares
    ) private view returns (uint256) {
        uint256 totalShares = strategies[strategyId].totalShares;

        return
            totalShares == 0
                ? 0
                : (strategies[strategyId].totalStaked * shares) / totalShares;
    }

    function _onlyContract(address addressToCheck) private view {
        if (!AddressUpgradeable.isContract(addressToCheck)) {
            revert OnlyContractAddress();
        }
    }

    function _onlyExistingStrategy(uint256 strategyId) private view {
        if (strategyId > strategiesCount || strategyId == 0) {
            revert OnlyExistStrategy();
        }
    }

    function _onlyValidWithdrawalSharesAmount(
        uint256 strategyId,
        address user,
        uint256 shares
    ) private view {
        if (shares > positions[user][strategyId].shares) {
            revert OnlyValidWithdrawalSharesAmount();
        }
    }

    function _isStrategyActive(uint256 strategyId) private view {
        if (!strategies[strategyId].isActive) {
            revert OnlyActiveStrategy();
        }
    }
}
