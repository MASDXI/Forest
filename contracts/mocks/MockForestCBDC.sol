// // SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/ForestToken.sol";
import "../abstracts/extensions/FreezeAddress.sol";
import "../abstracts/extensions/FreezeBalance.sol";
import "../abstracts/extensions/FreezeToken.sol";

contract MockForestCBDC is ForestToken, FreezeAddress, FreezeBalance, FreezeToken {
    /// @custom:event for keep tracking token from root.
    event Transfer(address from, address to, bytes32 indexed root, bytes32 indexed parent, uint256 value);

    constructor(string memory name_, string memory symbol_) ForestToken(name_, symbol_) {}

    modifier checkFrozenRootOrParent(address account, bytes32 tokenId) {
        Forest.Transaction memory transaction = _transaction(account, tokenId);
        if (isTokenFrozen(transaction.root) || isTokenFrozen(transaction.parent)) {
            revert TokenFrozen();
        }
        _;
    }

    function _transfer(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value
    )
        internal
        virtual
        override
        checkFrozenBalance(msg.sender, balanceOf(msg.sender), value)
        checkFrozenAddress(msg.sender, to)
        checkFrozenRootOrParent(msg.sender, tokenId)
        checkFrozenToken(tokenId)
    {
        /// @notice ERC20 Transfer also emit.
        super._transfer(from, to, tokenId, value);
        Forest.Transaction memory txn = _transaction(from, tokenId);
        emit Transfer(from, to, txn.root, txn.parent, value);
    }

    function mint(address account, uint256 value) public {
        _mintTransaction(account, value);
    }

    function burn(address account, bytes32 tokenId, uint256 value) public {
        _burnTransaction(account, tokenId, value);
    }
}
