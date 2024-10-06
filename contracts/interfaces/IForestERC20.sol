// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Interface for Forest ERC20 Token
 * @notice Interface for interacting with a Forest ERC20 token, providing methods for transfer and transferFrom operations.
 */
interface IForestERC20 {
    /**
     * @notice Error thrown when direct token transfer is not supported.
     */
    error ERC20TransferNotSupported();

    /**
     * @notice Error thrown when token transferFrom operation is not supported.
     */
    error ERC20TransferFromNotSupported();

    /**
     * @notice Transfers tokens to a specified address.
     * @param to The recipient address.
     * @param tokenId The unique identifier of the token.
     * @param value The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful.
     */
    function transfer(address to, bytes32 tokenId, uint256 value) external returns (bool);

    /**
     * @notice Transfers tokens from one address to another.
     * @param from The address from which to transfer tokens.
     * @param to The address to which to transfer tokens.
     * @param tokenId The unique identifier of the token.
     * @param value The amount of tokens to transfer.
     * @return A boolean indicating whether the transferFrom was successful.
     */
    function transferFrom(address from, address to, bytes32 tokenId, uint256 value) external returns (bool);
}
