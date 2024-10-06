// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title FreezeBalance
 * @dev Abstract contract for managing frozen balances, not implementing access control.
 * @notice This contract allows freezing and unfreezing of account balances. It does not include access control mechanisms.
 */
abstract contract FreezeBalance {
    mapping(address => uint256) private _frozenBalance;

    /**
     * @notice Error thrown when an operation causes a balance overflow.
     */
    error BalanceOverflow();

    /**
     * @notice Error thrown when a frozen balance restriction is violated.
     * @param balance The total balance of the account.
     * @param frozenBalance The frozen balance of the account.
     */
    error BalanceFrozen(uint256 balance, uint256 frozenBalance);

    /**
     * @notice Event emitted when an account's balance is frozen or unfrozen.
     * @param account The address of the account.
     * @param value The amount of balance that is frozen.
     */
    event FrozenBalance(address indexed account, uint256 value);

    /**
     * @notice Modifier to check if an account's balance can be spent, considering the frozen balance.
     * @param account The address of the account.
     * @param balance The total balance of the account.
     * @param value The amount of balance to be spent.
     */
    modifier checkFrozenBalance(address account, uint256 balance, uint256 value) {
        if (balance < value) {
            revert BalanceOverflow();
        }
        uint256 frozenBalance = _frozenBalance[account];
        if (frozenBalance > balance - value) {
            revert BalanceFrozen(balance, frozenBalance);
        }
        _;
    }

    /**
     * @notice Sets the frozen balance of an account.
     * @param account The address of the account.
     * @param amount The amount to be frozen. Pass 0 to clear the frozen balance.
     */
    function setFreezeBalance(address account, uint256 amount) public {
        _frozenBalance[account] = amount;
        emit FrozenBalance(account, amount);
    }

    /**
     * @notice Gets the frozen balance of an account.
     * @param account The address of the account.
     * @return The frozen balance of the account.
     */
    function getFrozenBalance(address account) public view returns (uint256) {
        return _frozenBalance[account];
    }
}
