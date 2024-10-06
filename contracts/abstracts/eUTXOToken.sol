// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/eUTXO.sol";
import "../interfaces/IUTXOERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Extended UTXO Token Contract
 * @dev This contract extends ERC20 functionality with support for Extended UTXO (eUTXO) transactions.
 * It provides methods to manage token transactions using eUTXO data structures.
 * Implements the IUTXOERC20 interface.
 */
abstract contract eUTXOToken is ERC20, IUTXOERC20 {
    using ExtendedUnspentTransactionOutput for ExtendedUnspentTransactionOutput.eUTXO;

    ExtendedUnspentTransactionOutput.eUTXO private _eUTXO;

    /**
     * @dev Constructor to initialize the ERC20 token with a name and symbol.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /**
     * @dev Internal function to fetch a transaction details based on the token ID.
     * @param tokenId The identifier of the token transaction.
     * @return A `Transaction` structure containing transaction details.
     */
    function _transaction(bytes32 tokenId) internal view returns (ExtendedUnspentTransactionOutput.Transaction memory) {
        return _eUTXO.transaction(tokenId);
    }

    /**
     * @dev Internal function to execute a token transfer using an eUTXO-based approach.
     * @param from The sender address.
     * @param to The recipient address.
     * @param tokenId The identifier of the token transaction.
     * @param value The amount of tokens to transfer.
     * @param signature The signature associated with the transaction.
     */
    function _transfer(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) internal virtual {
        uint256 txvalue = _eUTXO.transactionValue(tokenId);
        if (txvalue < value) {
            revert UTXOERC20TransferOverTransactionValue(txvalue, value);
        }
        uint256 change = txvalue - value;
        _update(from, to, value);
        _eUTXO.spendTransaction(ExtendedUnspentTransactionOutput.TransactionInput(tokenId, signature), from);
        _eUTXO.createTransaction(
            ExtendedUnspentTransactionOutput.TransactionOutput(value, to),
            tokenId,
            ExtendedUnspentTransactionOutput.calculateTransactionHash(from, _eUTXO.transactionCount(from)),
            from,
            _eUTXO.transactionExtraData(tokenId)
        );
        if (change > 0) {
            _eUTXO.createTransaction(
                ExtendedUnspentTransactionOutput.TransactionOutput(change, to),
                tokenId,
                ExtendedUnspentTransactionOutput.calculateTransactionHash(from, _eUTXO.transactionCount(from)),
                from,
                _eUTXO.transactionExtraData(tokenId)
            );
        }
    }

    /**
     * @dev Internal function to mint tokens and create a transaction for the minted tokens.
     * @param account The address that will receive the minted tokens.
     * @param value The amount of tokens to mint and transfer.
     */
    function _mintTransaction(address account, uint256 value) internal {
        _mintTransaction(account, value, bytes32(0));
    }

    /**
     * @dev Internal function to mint tokens and create a transaction for the minted tokens with additional data.
     * @param account The address that will receive the minted tokens.
     * @param value The amount of tokens to mint and transfer.
     * @param data Additional data associated with the mint transaction.
     */
    function _mintTransaction(address account, uint256 value, bytes32 data) internal {
        _eUTXO.createTransaction(
            ExtendedUnspentTransactionOutput.TransactionOutput(value, account),
            bytes32(0),
            ExtendedUnspentTransactionOutput.calculateTransactionHash(address(0), _eUTXO.transactionCount(address(0))),
            address(0),
            data
        );
        _mint(account, value);
    }

    /**
     * @dev Internal function to burn tokens and handle the corresponding eUTXO transaction.
     * @param account The address from which tokens will be burned.
     * @param tokenId The identifier of the token transaction to be burned.
     * @param value The amount of tokens to burn.
     */
    function _burnTransaction(address account, bytes32 tokenId, uint256 value) internal {
        if (value == _eUTXO.transactionValue(tokenId)) {
            _eUTXO.consumeTransaction(tokenId, account);
        } else {
            _eUTXO.consumeTransaction(tokenId, account);
            _eUTXO.createTransaction(
                ExtendedUnspentTransactionOutput.TransactionOutput(value, account),
                tokenId,
                ExtendedUnspentTransactionOutput.calculateTransactionHash(account, _eUTXO.transactionCount(account)),
                account,
                _eUTXO.transactionExtraData(tokenId)
            );
        }
        _burn(account, value);
    }

    /**
     * @dev Internal function to fetch a transaction details based on the token ID.
     * @param tokenId The identifier of the token transaction.
     * @return A `Transaction` structure containing transaction details.
     */
    function transaction(bytes32 tokenId) public view returns (ExtendedUnspentTransactionOutput.Transaction memory) {
        return _transaction(tokenId);
    }

    /**
     * @dev Function to fecth the number of UTXOs (Unspent Transaction Outputs) associated with a given account.
     * @param account The address of the account for which to fetch the UTXO transaction size.
     * @return The number of UTXOs associated with the account.
     */
    function transactionSize(address account) public view returns (uint256) {
        return _eUTXO.transactionSize(account);
    }

    /**
     * @dev Function to the value of a UTXO transaction identified by its token ID.
     * @param tokenId The identifier of the UTXO transaction.
     * @return The value of the UTXO associated with the specified token ID.
     */
    function transactionValue(bytes32 tokenId) public view returns (uint256) {
        return _eUTXO.transactionValue(tokenId);
    }

    /**
     * @dev Function to fetch the input of a UTXO transaction identified by its token ID.
     * @param tokenId The identifier of the UTXO transaction.
     * @return The input associated with the specified UTXO token ID.
     */
    function transactionInput(bytes32 tokenId) public view returns (bytes32) {
        return _eUTXO.transactionInput(tokenId);
    }

    /**
     * @dev Function to fetch the owner of a UTXO transaction identified by its token ID.
     * @param tokenId The identifier of the UTXO transaction.
     * @return The address of the owner of the UTXO associated with the specified token ID.
     */
    function transactionOwner(bytes32 tokenId) public view returns (address) {
        return _eUTXO.transactionOwner(tokenId);
    }

    /**
     * @dev Function to checks whether a UTXO transaction has been spent, identified by its token ID.
     * @param tokenId The identifier of the UTXO transaction.
     * @return True if the UTXO associated with the specified token ID has been spent, false otherwise.
     */
    function transactionSpent(bytes32 tokenId) public view returns (bool) {
        return _eUTXO.transactionSpent(tokenId);
    }

    /**
     * @dev Function to fetch the extra data associated with a UTXO transaction identified by its token ID.
     * @param tokenId The identifier of the UTXO transaction.
     * @return The extra data stored for the UTXO associated with the specified token ID.
     */
    function transactionExtraData(bytes32 tokenId) public view returns (bytes32) {
        return _eUTXO.transactionExtraData(tokenId);
    }

    /**
     * @dev Function to transfer tokens (not supported in this contract).
     */
    function transfer(address to, uint256 value) public virtual override returns (bool) {
        revert ERC20TransferNotSupported();
    }

    /**
     * @inheritdoc IUTXOERC20
     */
    function transfer(
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) public virtual override returns (bool) {
        _transfer(msg.sender, to, tokenId, value, signature);
        return true;
    }

    /**
     * @dev Function to transfer tokens from one address to another (not supported in this contract).
     */
    function transferFrom(address from, address to, uint256 value) public virtual override returns (bool) {
        revert ERC20TransferFromNotSupported();
    }

    /**
     * @inheritdoc IUTXOERC20
     */
    function transferFrom(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, tokenId, value, signature);
        return true;
    }
}
