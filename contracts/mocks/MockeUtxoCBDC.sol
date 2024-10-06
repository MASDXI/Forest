// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/eUTXOToken.sol";
import "../abstracts/extensions/FreezeAddress.sol";
import "../abstracts/extensions/FreezeBalance.sol";
import "../abstracts/extensions/FreezeToken.sol";

contract MockeUtxoCBDC is eUTXOToken, FreezeAddress, FreezeBalance, FreezeToken {
    /// @custom:event for keep tracking token from root.
    event Transfer(address indexed from, address indexed to, bytes32 indexed root, uint256 value);

    constructor(string memory name_, string memory symbol_) eUTXOToken(name_, symbol_) {}

    modifier checkFrozenRoot(bytes32 tokenId) {
        if (isTokenFrozen(_transaction(tokenId).extraData)) {
            revert TokenFrozen();
        }
        _;
    }

    function _transfer(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    )
        internal
        virtual
        override
        checkFrozenBalance(msg.sender, balanceOf(msg.sender), value)
        checkFrozenAddress(msg.sender, to)
        checkFrozenRoot(tokenId)
        checkFrozenToken(tokenId)
    {
        /// @notice ERC20 Transfer also emit.
        super._transfer(from, to, tokenId, value, signature);

        emit Transfer(from, to, _transaction(tokenId).extraData, value);
    }

    function mint(address account, uint256 value, bytes32 extraData) public {
        _mintTransaction(account, value, extraData);
    }

    function mint(address account, uint256 value) public {
        _mintTransaction(account, value);
    }

    function burn(address account, bytes32 tokenId, uint256 value) public {
        _burnTransaction(account, tokenId, value);
    }
}
