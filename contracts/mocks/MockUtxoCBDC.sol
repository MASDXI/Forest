// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/UTXOToken.sol";
import "../abstracts/extensions/FreezeAddress.sol";
import "../abstracts/extensions/FreezeBalance.sol";
import "../abstracts/extensions/FreezeToken.sol";

contract MockUtxoCBDC is UTXOToken, FreezeAddress, FreezeBalance, FreezeToken {
    constructor(string memory name_, string memory symbol_) UTXOToken(name_, symbol_) {}

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
        checkFrozenToken(tokenId)
    {
        super._transfer(from, to, tokenId, value, signature);
    }

    function mint(address account, uint256 value) public {
        _mintTransaction(account, value);
    }

    function burn(address account, bytes32 tokenId, uint256 value) public {
        _burnTransaction(account, tokenId, value);
    }
}
