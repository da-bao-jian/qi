// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC1271 {
    function isValidSignature(bytes32 _hash, bytes memory _signature)
        external
        view
        returns (bytes4 magicValue);

    event ValidSignature(bytes32 indexed hash, bytes signature);
    event InvalidSignature(bytes32 indexed hash, bytes signature);
}
