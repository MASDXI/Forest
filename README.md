---
Title: "Forest: Smart Contract Implementation for Enhanced Traceability in Central Bank Digital Currency Systems"
Description: "An implementation of advanced data structure over token smart contract."
Author: "Sirawit Techavanitch (sirawit_tec@utcc.ac.th)"
Status: "Draft"
---

<h1 align="center">
<img src="./docs/assets/banner.png" width="450"/>
</h1>

# Forest: A Smart Contract Implementation for Enhanced Traceability in Central Bank Digital Currency Systems

## Abstract

// TODO  
**Keyword: Anti-Money Laundering, Blockchain, Counter Financial Terrorism, Central Bank Digital Currencies, Smart Contract**

## Introduction

The present-day Central Bank Digital Currency concept aims to utilize the advantages of Blockchain Technology or Distributed Ledger Technology that provide immutability, transparency, and security, and adopts smart contracts, which plays a key feature in creating programmable money. However, technology itself gives an advantage and eliminates the problem ideally of compliance with the regulator and AML/CFT standard, but it does not seem practical to be done in the real world and is not efficiently responsible for the financial crime or incidents that occur in the open network of economic.

## Related Works

// Opinion: AI and Deep learning recognize and analyze the pattern, but it'd be nice if the data structure also provided a more efficient and fast response to the incident.

- [ERC20](https://eips.ethereum.org/EIPS/eip-20) fungible token intended to be currency-like, but the data structure is account-based, making it hard to separate money when it's mixed with the total balance.
- [ERC721](https://eips.ethereum.org/EIPS/eip-721) not suitable due to metadata not being stored on-chain, it can be modified to support, but it's not intended to be exchangeable.
- [ERC1155](https://eips.ethereum.org/EIPS/eip-1155) metadata problem is the same as `ERC721`, however, `ERC1155` can utilize tokenId as root, it can freeze the balance for each account, but it ends up with you can't to separate the money when it's stored in the total balance.
- [ERC1400](https://eips.ethereum.org/EIPS/eip-1400) have characteristic base from `ERC20` but extended functionality for freeze account or freeze balance.
- [ERC3643](https://eips.ethereum.org/EIPS/eip-3643) have characteristic same as `ERC1400` but extended functionality for store the document and other feature.
- [MerkleTree](https://www.geeksforgeeks.org/blockchain-merkle-trees/) not suitable for the payment due to its need to maintain the root hash and generate proof every time.
- [UTXO](https://www.geeksforgeeks.org/what-is-unspent-transaction-output-utxo/) maintain the amount of money or group of money in each individual transaction. To spend the transaction, the caller needs to be the owner of the transaction that needs to be spent.
- [eUTXO](https://docs.cardano.org/about-cardano/learn/eutxo-explainer/) extended version of `UTXO`, purpose of `eUTXO` is adding/carrying additional data as extraData or payload in the transaction.

## Methodology

Introduce implementation call `Forest` used the way to modified the state to keep tracking subtree avoid to creating transaction output for change back the to spender like in `UTXO`.

## Conclusion and Evaluation

| Features                                                            | ERC20 | UTXO | eUTXO | Forest |
| ------------------------------------------------------------------- | ----- | ---- | ----- | ------ |
| freeze the `sender` account.                                        | ✓     | ✓    | ✓     | ✓      |
| freeze the `recipient` account.                                     | ✓     | ✓    | ✓     | ✓      |
| freeze the certain `amount` token.                                  | ✗     | ✓    | ✓     | ✓      |
| freeze the specifics `tokenId` or `txId`.                           | ✗     | ✓    | ✓     | ✓      |
| freeze the specifics `tokenId` or `TxId` that relevant to the root. | ✗     | ✗    | ✓     | ✓      |
| keep tracking child/subtree.                                        | ✗     | ✗    | ✗     | ✓      |

- For `ERC20` provide events and keep tracking each `Transfer`,  
  but the problem is the `ERC20` model can't separate `clean money` from `dirty money`,  
  due to the `ERC20` not have `tokenId` to keep tracking each token when it's move.
- For `ERC721` its use non-fungible, each token is unique and not intend to keep tracking amount or value.
- For `ERC1400`, includes features like partitioned balances,  
  allowing tokens to be split into subsets based on conditions or rules (e.g., restrictions, investor categories).  
  It also supports document management, enabling the attachment of legal documents to tokens, and integrates with compliance mechanisms,  
  ensuring that transfers comply with rules like KYC/AML checks. However,  
  `ERC1400` tokens still face challenges in tracking the history or provenance of individual tokens beyond their partitioned states.
- For `ERC1155` improves upon ERC20 and ERC721 by offering more flexibility and reducing operational overhead,  
  it does not inherently provide a way to distinguish between `clean` and `dirty` tokens,  
  as it lacks the ability to track individual token histories like `UTXO` models do.
- For `UTXO` and `eUTXO` facing challenge to combine multiple `UnspentTransaction` and spent as one,  
  in case, user want to spend value that greater that selected `UnspentTransaction`.  
  Possible solution: prepare and batching as an array,  
  `UTXO` and `eUTXO` maintain the amount of money or group of money in each individual transaction.  
  Each `UnspentTransaction` is not underlying any account,
  so to spend the transaction, the caller needs to be the owner of the transaction that needs to be spent.
- For `Forest` use to modify an existing state rather than create a new output transaction, like in `UTXO` or `eUTXO` do,  
  it allows spending the transaction multiple times till it's met `0`, The `Forest` model enables tracking of child/subtree structures,  
  providing a hierarchical view of token flows and relationships,  
  which is not possible in traditional token standards like `ERC20`, `ERC721`, `ERC1155`, `ERC1400`, and `ERC3643`.

## For Further Work

Currently `Forest` not 100% compatible with existing `ERC20` standard.
To complete and fully supported `ERC20` interface `Forest` require to have automatically select and spent the transaction.  
However it's doesn't need to be store each transaction in sorted list.

- Rewrite the contract not inherit ERC20 from `@openzeppelin/contracts` can reduce unnecessary `gasUsed`.
- Adopting `FIFO` or First-In-First-Out style which is can be done in smart contract but should be considering the `gasUsed`.
- Second off-load heavy computation from the smart contract to a custom pre-compiled contract.
- Third create a stateful pre-compiled contract that fully functional same as the smart contract specification.

Learn more about [pre-compiled contract](https://www.rareskills.io/post/solidity-precompiles)

The `Forest` project addresses significant challenge, particularly state bloat and [dust](https://www.investopedia.com/terms/b/bitcoin-dust.asp) transaction.  
Merging multiple small transactions into a single larger transaction helps reduce the number of entries in the blockchain’s state, thereby minimizing state growth.  
However, this process can complicate traceability, as it obscures the individual histories of the merged transactions.  
Additionally, once a transaction's output has been spent, it can be marked as spent or removed from the dataset,  
which further complicates the ability to trace the flow of funds. While these strategies are effective in managing state size,  
they can hinder users' ability to follow transaction trails, making it difficult to verify the origins of funds.

## Glossary of Terms

**AML** Anti-Money Laundering  
**B2G** Back to Genesis  
**CBDC** Central Bank Digital Currency  
**CFT** Counter Financial Terrorism  
**C2C** Customer to Customer  
**DLT** Distributed Ledger Technology  
**eUTXO** Extended Transaction Output  
**KYC** Know Your Customer  
**UTXO** Unspent Transaction Output

## Reference

<div align="center">
<img src="./docs/assets/reports/BOT-rCBDC-Fraud-Handling01.png" width="450"/>
<p style="text-align: center;"><em>Conceptual Feasibility Fraud Handling from rCBDC BOT report page 33.</em></p>
</div>

<div align="center">
<img src="./docs/assets/reports/BOT-rCBDC-Fraud-Handling02.png" width="450"/>
<p style="text-align: center;"><em>Comparison of As is and To be (Conceptual) from rCBDC BOT report page 33.</em></p>
</div>
