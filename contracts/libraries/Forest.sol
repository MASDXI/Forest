// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Forest Model Library
 * @notice Library containing data structures and functions for managing transactions within a forest-like structure.
 * @author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)
 */
library Forest {
    /**
     * @dev Structure representing a transaction within the forest.
     */
    struct Transaction {
        bytes32 root; // Root hash of the transaction
        bytes32 parent; // Parent transaction hash
        uint256 value; // Value associated with the transaction
    }

    /**
     * @dev Structure representing an input for a transaction.
     */
    struct TransactionInput {
        bytes32 outpoint; // Identifier of the transaction output being spent
        uint256 value; // Value of the transaction input
    }

    /**
     * @dev Structure representing an output for a transaction.
     */
    struct TransactionOutput {
        uint256 value; // Value of the transaction output
        address account; // Recipient account of the transaction output
    }

    /**
     * @dev Structure representing a tree of transactions for a specific account.
     */
    struct Tree {
        mapping(address => uint256) size; // Number of transactions for each account
        mapping(address => uint256) nonces; // Nonce (transaction count) for each account
        mapping(address => mapping(bytes32 => Transaction)) trees; // Mapping of account to transaction trees
    }

    /**
     * @dev Event emitted when a transaction is created within the forest.
     * @param id The identifier of the transaction.
     * @param root The root hash of the transaction.
     * @param creator The address that created the transaction.
     * @param owner The address that owns the transaction.
     */
    event TransactionCreated(bytes32 indexed id, bytes32 indexed root, address indexed creator, address owner);

    /**
     * @dev Event emitted when a transaction is consumed (set to zero value) within the forest.
     * @param id The identifier of the transaction.
     */
    event TransactionConsumed(bytes32 indexed id);

    /**
     * @dev Event emitted when a transaction output is spent.
     * @param id The identifier of the transaction output.
     * @param spender The address that spent the transaction output.
     * @param value The value spent.
     */
    event TransactionSpent(bytes32 indexed id, address indexed spender, uint256 value);

    /**
     * @dev Error thrown when attempting to create an existing transaction.
     */
    error TransactionExist();

    /**
     * @dev Error thrown when attempting to interact with a non-existent transaction.
     */
    error TransactionNotExist();

    /**
     * @dev Error thrown when attempting to spend more value than available in a transaction output.
     * @param value The value of the transaction.
     * @param spend The amount being spent.
     */
    error TransactionInsufficient(uint256 value, uint256 spend);

    /**
     * @dev Error thrown when attempting to create a transaction with zero value.
     */
    error TransactionZeroValue();

    /**
     * @dev Checks if a transaction exists within an account's tree.
     * @param self The reference to the Tree storage.
     * @param account The address of the account owning the transaction.
     * @param id The identifier of the transaction.
     * @return true if the transaction exists, false otherwise.
     */
    function _transactionExist(Tree storage self, address account, bytes32 id) private view returns (bool) {
        return self.trees[account][id].root != bytes32(0);
    }

    /**
     * @dev Calculates the root hash for a transaction within the forest.
     * @return The calculated root hash.
     */
    function calculateTranscationRootHash() internal view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, block.number, block.timestamp));
    }

    /**
     * @dev Calculates the hash of a transaction.
     * @param creator The address that created the transaction.
     * @param nonce The nonce (transaction count) for the creator.
     * @return The calculated transaction hash.
     */
    function calculateTransactionHash(address creator, uint256 nonce) internal view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, creator, nonce));
    }

    /**
     * @dev Retrieves a transaction from an account's transaction tree.
     * @param self The reference to the Tree storage.
     * @param account The address of the account owning the transaction.
     * @param id The identifier of the transaction.
     * @return The transaction details.
     */
    function transaction(Tree storage self, address account, bytes32 id) internal view returns (Transaction memory) {
        return self.trees[account][id];
    }

    /**
     * @dev Retrieves the root hash of a transaction from an account's transaction tree.
     * @param self The reference to the Tree storage.
     * @param account The address of the account owning the transaction.
     * @param id The identifier of the transaction.
     * @return The root hash of the transaction.
     */
    function transactionRoot(Tree storage self, address account, bytes32 id) internal view returns (bytes32) {
        return self.trees[account][id].root;
    }

    /**
     * @dev Retrieves the value of a transaction from an account's transaction tree.
     * @param self The reference to the Tree storage.
     * @param account The address of the account owning the transaction.
     * @param id The identifier of the transaction.
     * @return The value associated with the transaction.
     */
    function transactionValue(Tree storage self, address account, bytes32 id) internal view returns (uint256) {
        return self.trees[account][id].value;
    }

    /**
     * @dev Creates a new transaction within an account's transaction tree.
     * @param self The reference to the Tree storage.
     * @param txOutput The transaction output containing value and recipient information.
     * @param root The root hash associated with the transaction.
     * @param parent The parent transaction hash.
     * @param id The identifier of the transaction.
     * @param creator The address that created the transaction.
     */
    function createTransaction(
        Tree storage self,
        TransactionOutput memory txOutput,
        bytes32 root,
        bytes32 parent,
        bytes32 id,
        address creator
    ) internal {
        if (txOutput.value == 0) {
            revert TransactionZeroValue();
        }
        if (_transactionExist(self, txOutput.account, id)) {
            revert TransactionExist();
        }
        self.trees[txOutput.account][id] = Transaction(root, parent, txOutput.value);
        self.nonces[creator]++;
        self.size[txOutput.account]++;

        emit TransactionCreated(id, root, creator, txOutput.account);
    }

    /**
     * @dev Spends (reduces the value of) a transaction output within an account's transaction tree.
     * @param self The reference to the Tree storage.
     * @param txInput The transaction input specifying the output being spent and its value.
     * @param account The address of the account spending the transaction.
     */
    function spendTransaction(Tree storage self, TransactionInput memory txInput, address account) internal {
        if (!_transactionExist(self, account, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        uint256 value = self.trees[account][txInput.outpoint].value;
        if (value < txInput.value) {
            revert TransactionInsufficient(value, txInput.value);
        }
        self.trees[account][txInput.outpoint].value -= txInput.value;
        self.nonces[account]++;

        emit TransactionSpent(txInput.outpoint, account, txInput.value);
    }

    /**
     * @dev Consumes (sets to zero value) a transaction within an account's transaction tree.
     * @param self The reference to the Tree storage.
     * @param id The identifier of the transaction being consumed.
     * @param account The address of the account owning the transaction.
     */
    function consumeTransaction(Tree storage self, bytes32 id, address account) internal {
        if (!_transactionExist(self, account, id)) {
            revert TransactionNotExist();
        }
        self.trees[account][id].value = 0;
        self.size[account]--;

        emit TransactionConsumed(id);
    }

    /**
     * @dev Retrieves the transaction count (nonce) for a specific account.
     * @param self The reference to the Tree storage.
     * @param account The address of the account.
     * @return The number of transactions (nonce) for the account.
     */
    function transactionCount(Tree storage self, address account) internal view returns (uint256) {
        return self.nonces[account];
    }

    /**
     * @dev Retrieves the size (number of transactions) for a specific account.
     * @param self The reference to the Tree storage.
     * @param account The address of the account.
     * @return The size (number of transactions) for the account.
     */
    function transactionSize(Tree storage self, address account) internal view returns (uint256) {
        return self.size[account];
    }
}
