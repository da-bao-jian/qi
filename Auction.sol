// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC1271.sol";
import "./Vault.sol";

// Add the IRouter interface later
// will handke how to execute all the calldata
// also can enable partial bundle execution
interface IRouter {
    function execute(bytes32 calldataHash) external;
}

contract Auction {
    ERC1271 private erc1271;
    uint256 private constant auctionDuration = 10; // 10 blocks

    Vault private vault;

    event AuctionCompleted(uint256 winningIndex, TransactionData[] executedMessages);
    event BatchCompleted(uint256 batchIndex, TransactionData[] executedMessages);

    struct Bid {
        address bidder;
        uint256 bidAmount;
        uint256 numBids;
        uint256 startBlock;
        TransactionData[] txDataList;
    }

    Bid[] public bids;

    constructor(address erc1271Address, address vaultAddress) {
        erc1271 = ERC1271(erc1271Address);
        vault = Vault(vaultAddress);
    }

    function submitBid(TransactionData[] memory _txDataList) public payable {
        uint256 bidAmount = msg.value;
        uint256 numBids = _txDataList.length;
        uint256 startBlock = block.number;

        bids.push(
            Bid({
                bidder: msg.sender,
                bidAmount: bidAmount,
                numBids: numBids,
                startBlock: startBlock,
                txDataList: _txDataList
            })
        );
    }

    function increaseBid(uint256 bidIndex) public payable {
        Bid storage bid = bids[bidIndex];
        require(msg.sender == bid.bidder, "Not the original bidder");
        bid.bidAmount += msg.value;
    }

    function finalizeAuction() public {
        uint256 endBlock = bids[0].startBlock + auctionDuration;
        require(block.number >= endBlock, "Auction not yet ended");

        uint256[] memory winningIndices;
        TransactionData[][] memory executedMessages;

        for (uint256 i = 0; i < bids.length; i++) {
            if (isUniqueBatch(bids[i].txDataList)) {
                winningIndices.push(i);
                executedMessages.push(bids[i].txDataList);
                continue;
            }

            uint256 winnerIndex = i;
            uint256 loserIndex;

            for (uint256 j = i + 1; j < bids.length; j++) {
                if (isConflictingBatch(bids[i].txDataList, bids[j].txDataList)) {
                    uint256 winnerScore = bids[winnerIndex].bidAmount / bids[winnerIndex].numBids;
                    uint256 contenderScore = bids[j].bidAmount / bids[j].numBids;

                    if (contenderScore > winnerScore) {
                        loserIndex = winnerIndex;
                        winnerIndex = j;
                    } else {
                        loserIndex = j;
                    }

                    // Get the new batch containing the remaining messages of the losing bid
                    TransactionData[] memory newBatch = executeRemainingMessages(bids[winnerIndex].txDataList, bids[loserIndex].txDataList);
                    
                    // Add the new batch to the list of bids
                    if (newBatch.length > 0) {
                        Bid memory newBid = Bid({
                            bidder: bids[loserIndex].bidder,
                            bidAmount: bids[loserIndex].bidAmount,
                            numBids: newBatch.length,
                            txDataList: newBatch,
                            startBlock: block.number
                        });
                        bids.push(newBid);
                    } else {
                        revert("Loser has no messages to execute");
                    }
                }
            }

            winningIndices.push(winnerIndex);
            executedMessages.push(bids[winnerIndex].txDataList);

            // Emit the BatchCompleted event for the winning batch
            emit BatchCompleted(winnerIndex, bids[winnerIndex].txDataList);

            // Emit the BatchCompleted event for the remaining batch (if it exists)
            if (newBatch.length > 0) {
                emit BatchCompleted(bids.length - 1, newBatch);
            }
        }

        // ... (Transfer funds and register payouts)

        // Emit the AuctionCompleted event
        emit AuctionCompleted(winningIndices, executedMessages);

        // Cleanup bids
        delete bids;
    }


    function isUniqueBatch(TransactionData[] memory batch) internal pure returns (bool) {
        for (uint256 i = 0; i < batch.length; i++) {
            for (uint256 j = i + 1; j < batch.length; j++) {
                if (isEqualTransactionData(batch[i], batch[j])) {
                    return false;
                }
            }
        }
        return true;
    }

    function isConflictingBatch(TransactionData[] memory batch1, TransactionData[] memory batch2) internal pure returns (bool) {
        for (uint256 i = 0; i < batch1.length; i++) {
            for (uint256 j = 0; j < batch2.length; j++) {
                if (isEqualTransactionData(batch1[i], batch2[j])) {
                    return true;
                }
            }
        }
        return false;
    }

    function isEqualTransactionData(TransactionData memory data1, TransactionData memory data2) internal pure returns (bool) {
        return (
            data1.target == data2.target &&
            data1.amount == data2.amount &&
            data1.deadline == data2.deadline &&
            keccak256(data1.data) == keccak256(data2.data)
        );
    }

        function executeRemainingMessages(TransactionData[] memory winnerBatch, TransactionData[] memory loserBatch) internal returns (TransactionData[] memory) {
        TransactionData[] memory newBatch;
        uint256 newIndex = 0;

        for (uint256 i = 0; i < loserBatch.length; i++) {
            bool found = false;

            for (uint256 j = 0; j < winnerBatch.length; j++) {
                if (isEqualTransactionData(loserBatch[i], winnerBatch[j])) {
                    found = true;
                    break;
                }
            }

            // Add the remaining messages from the loserBatch that are not in the winnerBatch to the newBatch
            if (!found) {
                newBatch[newIndex] = loserBatch[i];
                newIndex++;
            }
        }

        return newBatch;
    }

    function executeBatchesInCustomOrder(IRouter router, bytes32[] memory calldataHashes) public {
    for (uint256 i = 0; i < calldataHashes.length; i++) {
        bytes32 calldataHash = calldataHashes[i];

        // Call the external router contract to handle the final target of the calldata
        router.execute(calldataHash);
    }
}

}
