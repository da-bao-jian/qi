//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//import 1inch interface files
//if tx is not in a bundle by execution file, send to 1inch

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ERC1271 {
    bytes4 private constant _ERC1271MAGICVALUE = 0x1626ba7e;
    
    struct TransactionData {
        address target;
        uint256 amount;
        uint256 deadline;
        bytes calldataData;
    }
    
    event SignedTransaction(
        address indexed signer,
        address indexed target,
        uint256 amount,
        uint256 deadline,
        bytes calldataData,
        bytes signature
    );
    
    event ValidSignature(bytes32 indexed hash, bytes signature);
    event InvalidSignature(bytes32 indexed hash, bytes signature);
    
    function signTransaction(
        address _target,
        uint256 _amount,
        uint256 _deadline,
        bytes memory _calldataData
    ) public returns (bytes32) {
        bytes32 txHash = keccak256(
            abi.encodePacked(_target, _amount, _deadline, _calldataData)
        );
        
        bytes memory signature = /* Your signature logic */;
        
        require(
            _isValidSignature(txHash, signature),
            "Invalid signature"
        );
        
        emit SignedTransaction(
            msg.sender,
            _target,
            _amount,
            _deadline,
            _calldataData,
            signature
        );

        return txHash;
    }
    
    function _isValidSignature(bytes32 _hash, bytes memory _signature)
        internal
        view
        returns (bool isValid)
    {
        // Implement your signature validation logic
        return true; // This is a placeholder. Replace with your own logic.
    }

    function isValidSignature(bytes32 _hash, bytes memory _signature)
        public
        view
        returns (bytes4 magicValue)
    {
        if (_isValidSignature(_hash, _signature)) {
            emit ValidSignature(_hash, _signature);
            return _ERC1271MAGICVALUE;
        } else {
            emit InvalidSignature(_hash, _signature);
            return 0x00000000;
        }
    }


    // execute safe tx via receive
    // execute arbitrarily sourced calldata 
    receive() external payable {} 
    fallback() external {}
}

/*
the bidder/searcher (MEVer) is not creating an auction rather:
the MEVer is searching the list of transactions (txs); 
    these txs are messages emitted from our contract (or CoW-like protocols) as erc1271s
    relayers then pickup these messages as they are emitted and adds them to our database 
    this database is queried by MEVers via posgres GET request feeds
once one or many favorable message(s) are bundled into a batch they go to the auction pool
    the auction pool has it's own deadline
    each batch can be bid on by other bidders
    there can be multiple winners:
        batches with all unique messages win automatically
        the different batches needed to be compared against eachother offchain since there is a factor of O(2^n)
        there needs to be a layer that confirms what the final batches will be
        the Searcher will then define the execution order
    



Ux to create CoW message (erc1271 message)
Message is sent to relayer (prebuilt, eg cow swap/1inch)
Bot and Postgres database to pool relayer data feed
Build web socket to handle postgres requests
Built database handles get requests via a socket
Bidder uses our smart contract to init auction
	255 is the cap in a pool but need a new solution
	the new solution would ignore unsavory txs
	this means that the bidder bundles txs into an auction
    */