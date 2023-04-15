// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./superfluid/ISuperfluid.sol";
import "./superfluid/ISuperToken.sol";
import "./superfluid/ISuperAgreement.sol";
import "./superfluid/IConstantFlowAgreementV1.sol";

contract Vault {
    ISuperfluid private host;
    IConstantFlowAgreementV1 private cfa;
    ISuperToken private superToken;

    address private admin;
    mapping(address => uint256) public creatorPayouts;

    constructor(
        address _host,
        address _cfa,
        address _superToken,
        address _admin
    ) {
        host = ISuperfluid(_host);
        cfa = IConstantFlowAgreementV1(_cfa);
        superToken = ISuperToken(_superToken);
        admin = _admin;
    }

    function registerPayout(address _creator, uint256 _amount) external {
        require(msg.sender == admin, "Only admin can register payouts");
        creatorPayouts[_creator] += _amount;
    }

    function startStream(address _creator, int96 _flowRate) external {
        require(msg.sender == admin, "Only admin can start streams");
        require(creatorPayouts[_creator] > 0, "No payout for creator");

        host.callAgreement(
            cfa,
            abi.encodeWithSelector(
                cfa.createFlow.selector,
                superToken,
                _creator,
                _flowRate,
                new bytes(0)
            )
        );
    }

    function stopStream(address _creator) external {
        require(msg.sender == admin, "Only admin can stop streams");

        host.callAgreement(
            cfa,
            abi.encodeWithSelector(
                cfa.deleteFlow.selector,
                superToken,
                address(this),
                _creator,
                new bytes(0)
            )
        );
    }

    receive() external payable {
        if (msg.value > 0) {
            superToken.upgrade(msg.value);
        }
    }
}
