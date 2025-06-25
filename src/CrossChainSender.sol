// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/wormhole-solidity-sdk/src/WormholeRelayerSDK.sol";
import "lib/wormhole-solidity-sdk/src/interfaces/token/IERC20.sol";

contract CrossChainSender is TokenSender {
    uint256 public GAS_LIMIT = 1_000_000; // 1 million

    constructor(
        address _wormholeRelayer,
        address _tokenBridge,
        address _wormhole
    ) TokenBase(_wormholeRelayer, _tokenBridge, _wormhole) {}

    /// @notice Estimates the total cost required to perform a cross-chain deposit to a specified target chain.
    /// @dev Calculates the sum of the delivery cost (using the Wormhole Relayer) and the Wormhole message publishing fee.
    /// @param targetChain The Wormhole chain ID of the destination chain for the deposit.
    /// @return cost The estimated total cost (in wei) for the cross-chain deposit operation.
    // Function to get the estimated cost for cross-chain deposit
    function quoteCrossChainDeposit(
        uint16 targetChain
    ) public view returns (uint256 cost) {
        uint256 deliveryCost;
        (deliveryCost, ) = wormholeRelayer.quoteEVMDeliveryPrice(
            targetChain,
            0,
            GAS_LIMIT
        );

        // Total cost: delivery cost + cost of publishing the Wormhole message
        cost = deliveryCost + wormhole.messageFee();
    }

    /// @notice Sends tokens and an encoded payload to a receiver contract on a target chain via Wormhole.
    /// @dev Transfers tokens from the sender to this contract, encodes the recipient address, and sends both cross-chain.
    /// @param targetChain The Wormhole chain ID of the target chain.
    /// @param targetReceiver The address of the TokenReceiver contract on the target chain.
    /// @param recipient The recipient address on the target chain to receive the tokens.
    /// @param amount The amount of tokens to send.
    /// @param token The address of the IERC20 token contract to transfer.
    /// @custom:requirements `msg.value` must equal the cost returned by `quoteCrossChainDeposit(targetChain)`.
    // Function to send tokens and payload across chains
    function sendCrossChainDeposit(
        uint16 targetChain,
        address targetReceiver,
        address recipient,
        uint256 amount,
        address token
    ) public payable {
        // Get the cost for cross-chain deposit
        uint256 cost = quoteCrossChainDeposit(targetChain);
        require(
            msg.value == cost,
            "msg.value must equal quoteCrossChainDeposit(targetChain)"
        );

        // Transfer the specified amount of tokens from the user to this contract
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Encode the recipient's address into a payload
        bytes memory payload = abi.encode(recipient);

        // Use the Wormhole SDK to send the token and payload cross-chain
        sendTokenWithPayloadToEvm(
            targetChain,
            targetReceiver,
            payload,
            0,
            GAS_LIMIT,
            token,
            amount
        );
    }

    function setGasLimit(uint256 newGasLimit) external {
        require(newGasLimit > 0, "Gas limit must be greater than 0");
        GAS_LIMIT = newGasLimit;
    }
}
