// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC1271.sol";
import "./Vault.sol";

contract Auction {
    ERC1271 private erc1271;
    uint256 private constant auctionDuration = 10; // 10 blocks

    Vault private vault;

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

        uint256 winningIndex = 0;
        uint256 maxScore = 0;

        for (uint256 i = 0; i < bids.length; i++) {
            uint256 score = bids[i].bidAmount / bids[i].numBids;

            if (score > maxScore) {
                maxScore = score;
                winningIndex = i;
            }
        }

        // Payout logic to message creators and cleanup
    }
}
