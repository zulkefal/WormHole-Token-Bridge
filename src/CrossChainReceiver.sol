// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/wormhole-solidity-sdk/src/WormholeRelayerSDK.sol";
import "lib/wormhole-solidity-sdk/src/interfaces/token/IERC20.sol";

contract CrossChainReceiver is TokenReceiver {
    constructor(
        address _wormholeRelayer,
        address _tokenBridge,
        address _wormhole
    ) TokenBase(_wormholeRelayer, _tokenBridge, _wormhole) {}

    /**
     * @notice Handles the receipt of cross-chain payloads and associated token transfers.
     * @dev This function is called internally when a cross-chain message and token(s) are received.
     *      It validates the sender, ensures exactly one token transfer, decodes the recipient address
     *      from the payload, and transfers the received tokens to the intended recipient.
     * @param payload ABI-encoded data containing the recipient address.
     * @param receivedTokens Array containing information about the received token(s); must contain exactly one entry.
     * @param sourceAddress The address of the sender on the source chain (as bytes32).
     * @param sourceChain The chain ID of the source chain.
     */
    function receivePayloadAndTokens(
        bytes memory payload,
        TokenReceived[] memory receivedTokens,
        bytes32 sourceAddress,
        uint16 sourceChain,
        bytes32
    )
        internal
        override
        onlyWormholeRelayer
        isRegisteredSender(sourceChain, sourceAddress)
    {
        require(receivedTokens.length == 1, "Expected 1 token transfer");

        // Decode the recipient address from the payload
        address recipient = abi.decode(payload, (address));

        // Transfer the received tokens to the intended recipient
        IERC20(receivedTokens[0].tokenAddress).transfer(
            recipient,
            receivedTokens[0].amount
        );
    }
}
