// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/forge-std/src/Script.sol";
import {CrossChainSender} from "../src/CrossChainSender.sol";

contract DeployBridgeTokens is Script {
    address crossChainReceiver = vm.envAddress("CROSS_CHAIN_RECEIVER");

    uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY_SENDER");

    address public crossChainAddress = vm.envAddress("CROSS_CHAIN_SENDER");

    CrossChainSender crossChainSender = CrossChainSender(crossChainAddress);

    address tokenAddress = vm.envAddress("TOKEN_ADDRESS"); // WRH address

    uint16 targetChain = 23;
    // uint16 sourceChain = 10002;
    address recipient = 0x255eC453F14Ed7ba3d7BEbF9F253E17778b6ADF3;
    uint256 amount = 20e18; // Amount to send (20 WRH Tokens)

    function run() external {
        vm.startBroadcast(senderPrivateKey);
        IERC20(tokenAddress).approve(address(crossChainSender), amount);
        CrossChainSender(crossChainSender).sendCrossChainDeposit{
            value: CrossChainSender(crossChainSender).quoteCrossChainDeposit(
                (targetChain)
            )
        }(targetChain, crossChainReceiver, recipient, amount, tokenAddress);
        vm.stopBroadcast();
    }
}
