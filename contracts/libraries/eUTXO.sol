// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Extended Unspent Transaction Output Model
 * @notice This library implements the Extended Unspent Transaction Output (eUTXO) model for managing transactions on the blockchain.
 * @author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)
 */
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

library ExtendedUnspentTransactionOutput {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    /**
     * @dev Structure representing a transaction.
     */
    struct Transaction {
        bytes32 input;
        uint256 value;
        bytes32 extraData;
        address owner;
        bool spent;
    }

    /**
     * @dev Structure representing an input for a transaction.
     */
    struct TransactionInput {
        bytes32 outpoint;
        bytes signature;
    }

    /**
     * @dev Structure representing an output for a transaction.
     */
    struct TransactionOutput {
        uint256 value;
        address account;
    }

    /**
     * @dev Structure representing an Extended Unspent Tranasction Output.
     */
    struct eUTXO {
        mapping(address => uint256) size;
        mapping(address => uint256) nonces;
        mapping(bytes32 => Transaction) transactions;
    }

    /**
     * @notice Event emitted when a transaction is created.
     * @param id The identifier of the transaction.
     * @param creator The creator of the transaction.
     * @param owner The owner of the transaction output.
     */
    event TransactionCreated(bytes32 indexed id, address indexed creator, address indexed owner);

    /**
     * @notice Event emitted when a transaction is consumed.
     * @param id The identifier of the transaction.
     */
    event TransactionConsumed(bytes32 indexed id);

    /**
     * @notice Event emitted when a transaction is spent.
     * @param id The identifier of the transaction.
     * @param spender The address that spent the transaction.
     */
    event TransactionSpent(bytes32 indexed id, address indexed spender);

    /**
     * @notice Error thrown when attempting to spend an already spent transaction.
     */
    error TransactionAlreadySpent();

    /**
     * @notice Error thrown when attempting to create a transaction that already exists.
     */
    error TransactionExist();

    /**
     * @notice Error thrown when attempting to access a non-existent transaction.
     */
    error TransactionNotExist();

    /**
     * @notice Error thrown when a transaction is unauthorized.
     */
    error TransactionUnauthorized();

    /**
     * @notice Error thrown when trying to create a transaction with zero value.
     */
    error TransactionZeroValue();

    /**
     * @notice Checks if a transaction with the given id exists in the eUTXO.
     * @param self The eUTXO storage.
     * @param id The identifier of the transaction.
     * @return true if the transaction exists, false otherwise.
     */
    function _transactionExist(eUTXO storage self, bytes32 id) private view returns (bool) {
        return self.transactions[id].value > 0;
    }

    /**
     * @notice Calculates the hash of a transaction based on the creator and nonce.
     * @param creator The creator of the transaction.
     * @param nonce The nonce associated with the creator.
     * @return The calculated transaction hash.
     */
    function calculateTransactionHash(address creator, uint256 nonce) internal view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, creator, nonce));
    }

    /**
     * @notice Creates a new transaction output in the eUTXO.
     * @param self The eUTXO storage.
     * @param txOutput The transaction output details.
     * @param input The input identifier of the transaction.
     * @param id The identifier of the transaction.
     * @param creator The creator of the transaction.
     * @param data Extra data associated with the transaction.
     */
    function createTransaction(
        eUTXO storage self,
        TransactionOutput memory txOutput,
        bytes32 input,
        bytes32 id,
        address creator,
        bytes32 data
    ) internal {
        if (txOutput.value == 0) {
            revert TransactionZeroValue();
        }
        if (_transactionExist(self, id)) {
            revert TransactionExist();
        }
        self.transactions[id] = Transaction(input, txOutput.value, data, txOutput.account, false);
        self.nonces[creator]++;
        self.size[txOutput.account]++;

        emit TransactionCreated(id, creator, txOutput.account);
    }

    /**
     * @notice Spends a transaction in the eUTXO.
     * @param self The eUTXO storage.
     * @param txInput The transaction input details.
     * @param account The account spending the transaction.
     */
    function spendTransaction(eUTXO storage self, TransactionInput memory txInput, address account) internal {
        if (!_transactionExist(self, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        if (transactionSpent(self, txInput.outpoint)) {
            revert TransactionAlreadySpent();
        }

        if (
            keccak256(abi.encodePacked(txInput.outpoint)).toEthSignedMessageHash().recover(txInput.signature) ==
            address(0)
        ) {
            revert TransactionUnauthorized();
        }
        self.transactions[txInput.outpoint].spent = true;
        self.size[account]--;

        emit TransactionSpent(txInput.outpoint, account);
    }

    /**
     * @notice Consumes (marks as spent) a transaction in the eUTXO.
     * @param self The eUTXO storage.
     * @param id The identifier of the transaction to consume.
     * @param account The account consuming the transaction.
     */
    function consumeTransaction(eUTXO storage self, bytes32 id, address account) internal {
        if (!_transactionExist(self, id)) {
            revert TransactionNotExist();
        }
        self.transactions[id].spent = true;
        self.size[account]--;

        emit TransactionConsumed(id);
    }

    /**
     * @notice Retrieves the details of a transaction from the eUTXO.
     * @param self The eUTXO storage.
     * @param id The identifier of the transaction.
     * @return The transaction details.
     */
    function transaction(eUTXO storage self, bytes32 id) internal view returns (Transaction memory) {
        return self.transactions[id];
    }

    /**
     * @notice Retrieves the value of a transaction from the eUTXO.
     * @param self The eUTXO storage.
     * @param id The identifier of the transaction.
     * @return The transaction value.
     */
    function transactionValue(eUTXO storage self, bytes32 id) internal view returns (uint256) {
        return self.transactions[id].value;
    }

    /**
     * @notice Retrieves the input identifier of a transaction from the eUTXO.
     * @param self The eUTXO storage.
     * @param id The identifier of the transaction.
     * @return The transaction input identifier.
     */
    function transactionInput(eUTXO storage self, bytes32 id) internal view returns (bytes32) {
        return self.transactions[id].input;
    }

    /**
     * @notice Retrieves the extra data associated with a transaction from the eUTXO.
     * @param self The eUTXO storage.
     * @param id The identifier of the transaction.
     * @return The transaction extra data.
     */
    function transactionExtraData(eUTXO storage self, bytes32 id) internal view returns (bytes32) {
        return self.transactions[id].extraData;
    }

    /**
     * @notice Checks if a transaction in the eUTXO has been spent.
     * @param self The eUTXO storage.
     * @param id The identifier of the transaction.
     * @return true if the transaction has been spent, false otherwise.
     */
    function transactionSpent(eUTXO storage self, bytes32 id) internal view returns (bool) {
        return self.transactions[id].spent;
    }

    /**
     * @notice Retrieves the owner of a transaction in the eUTXO.
     * @param self The eUTXO storage.
     * @param id The identifier of the transaction.
     * @return The owner address of the transaction.
     */
    function transactionOwner(eUTXO storage self, bytes32 id) internal view returns (address) {
        return self.transactions[id].owner;
    }

    /**
     * @notice Retrieves the number of transactions associated with an account in the eUTXO.
     * @param self The eUTXO storage.
     * @param account The account address.
     * @return The count of transactions.
     */
    function transactionCount(eUTXO storage self, address account) internal view returns (uint256) {
        return self.nonces[account];
    }

    /**
     * @notice Retrieves the size of transactions associated with an account in the eUTXO.
     * @param self The eUTXO storage.
     * @param account The account address.
     * @return The size of transactions.
     */
    function transactionSize(eUTXO storage self, address account) internal view returns (uint256) {
        return self.size[account];
    }
}
