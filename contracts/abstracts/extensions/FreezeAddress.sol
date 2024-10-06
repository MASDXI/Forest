// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title FreezeAddress
 * @dev Abstract contract for managing frozen addresses, not implementing access control.
 * @notice This contract allows freezing and unfreezing of addresses. It does not include access control mechanisms.
 */
abstract contract FreezeAddress {
    mapping(address => bool) private _frozen;

    /**
     * @notice Error thrown when an operation is attempted on a frozen address.
     */
    error AddressFrozen();

    /**
     * @notice Error thrown when an operation is attempted to unfreeze an address that is not frozen.
     */
    error AddressNotFrozen();

    /**
     * @notice Event emitted when an address is frozen or unfrozen.
     * @param account The address that was frozen or unfrozen.
     * @param auth The boolean status indicating if the address is frozen (true) or unfrozen (false).
     */
    event FrozeAddress(address indexed account, bool indexed auth);

    modifier checkFrozenAddress(address from, address to) {
        if (isFrozen(from) || isFrozen(to)) {
            revert AddressFrozen();
        }
        _;
    }

    /**
     * @notice Internal function to update the frozen status of an address.
     * @param account The address to update.
     * @param auth The new frozen status. True to freeze the address, false to unfreeze.
     */
    function _updateFreezeAddress(address account, bool auth) private {
        _frozen[account] = auth;
        emit FrozeAddress(account, auth);
    }

    /**
     * @notice Freezes the specified address.
     * @param account The address to freeze.
     */
    function freezeAddress(address account) public {
        if (_frozen[account]) {
            revert AddressFrozen();
        }
        _updateFreezeAddress(account, true);
    }

    /**
     * @notice Unfreezes the specified address.
     * @param account The address to unfreeze.
     */
    function unfreezeAddress(address account) public {
        if (!_frozen[account]) {
            revert AddressNotFrozen();
        }
        _updateFreezeAddress(account, false);
    }

    /**
     * @notice Checks if the specified address is frozen.
     * @param account The address to check.
     * @return A boolean indicating if the address is frozen (true) or not (false).
     */
    function isFrozen(address account) public view returns (bool) {
        return _frozen[account];
    }
}
