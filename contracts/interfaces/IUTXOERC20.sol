// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Interface for UTXO-based ERC20 Token
 * @notice This interface defines methods for handling ERC20 token transfers using the Unspent Transaction Output (UTXO) model.
 */
interface IUTXOERC20 {
    /**
     * @notice Error thrown when direct ERC20 transfer is not supported.
     */
    error ERC20TransferNotSupported();

    /**
     * @notice Error thrown when ERC20 transfer from is not supported.
     */
    error ERC20TransferFromNotSupported();

    /**
     * @notice Error thrown when the spending value exceeds the transaction value.
     * @param transactionValue The value of the transaction.
     * @param spendingValue The amount being spent.
     */
    error UTXOERC20TransferOverTransactionValue(uint256 transactionValue, uint256 spendingValue);

    /**
     * @notice Transfers tokens using the UTXO model.
     * @param to The recipient address.
     * @param tokenId The identifier of the token transaction.
     * @param value The amount of tokens to transfer.
     * @param signature The signature associated with the transaction.
     * @return true if the transfer is successful, otherwise false.
     */
    function transfer(address to, bytes32 tokenId, uint256 value, bytes memory signature) external returns (bool);

    /**
     * @notice Transfers tokens from one address to another using the UTXO model.
     * @param from The sender address.
     * @param to The recipient address.
     * @param tokenId The identifier of the token transaction.
     * @param value The amount of tokens to transfer.
     * @param signature The signature associated with the transaction.
     * @return true if the transfer is successful, otherwise false.
     */
    function transferFrom(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) external returns (bool);
}
