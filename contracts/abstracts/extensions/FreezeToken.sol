// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title FreezeToken
 * @dev Abstract contract for managing frozen tokens, not implementing access control.
 * @notice This contract allows tokens to be frozen and unfrozen. It does not include access control mechanisms.
 */
abstract contract FreezeToken {
    mapping(bytes32 => bool) private _frozenToken;

    /**
     * @notice Error thrown when a token operation is attempted on a frozen token.
     */
    error TokenFrozen();

    /**
     * @notice Error thrown when an operation is attempted to unfreeze a token that is not frozen.
     */
    error TokenNotFrozen();

    /**
     * @notice Event emitted when a token is frozen or unfrozen.
     * @param tokenId The identifier of the token.
     * @param auth The status of the token, true if frozen, false if unfrozen.
     */
    event frozenToken(bytes32 indexed tokenId, bool indexed auth);

    /**
     * @notice Modifier to check if a token is frozen.
     * @param tokenId The identifier of the token.
     */
    modifier checkFrozenToken(bytes32 tokenId) {
        if (_frozenToken[tokenId]) {
            revert TokenFrozen();
        }
        _;
    }

    /**
     * @notice Internal function to update the frozen status of a token.
     * @param tokenId The identifier of the token.
     * @param auth The status to set for the token, true to freeze, false to unfreeze.
     */
    function _updateSuspendToken(bytes32 tokenId, bool auth) private {
        _frozenToken[tokenId] = auth;
        emit frozenToken(tokenId, auth);
    }

    /**
     * @notice Public function to freeze a token.
     * @param tokenId The identifier of the token to be frozen.
     * @dev Throws a TokenFrozen error if the token is already frozen.
     */
    function freezeToken(bytes32 tokenId) public {
        if (_frozenToken[tokenId]) {
            revert TokenFrozen();
        }
        _updateSuspendToken(tokenId, true);
    }

    /**
     * @notice Public function to unfreeze a token.
     * @param tokenId The identifier of the token to be unfrozen.
     * @dev Throws a TokenNotFrozen error if the token is not frozen.
     */
    function unsfreezeToken(bytes32 tokenId) public {
        if (!_frozenToken[tokenId]) {
            revert TokenNotFrozen();
        }
        _updateSuspendToken(tokenId, false);
    }

    /**
     * @notice Public function to check if a token is frozen.
     * @param tokenId The identifier of the token.
     * @return True if the token is frozen, false otherwise.
     */
    function isTokenFrozen(bytes32 tokenId) public view returns (bool) {
        return _frozenToken[tokenId];
    }
}
