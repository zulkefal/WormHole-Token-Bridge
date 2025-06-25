// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/forge-std/src/Script.sol";
import {CrossChainReceiver} from "../src/CrossChainReceiver.sol";

contract DeployWhiteList is Script {
    address crossChainReceiver = vm.envAddress("CROSS_CHAIN_RECEIVER");

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    uint16 sourceChain = 30; // base

    address crossChainSender = vm.envAddress("CROSS_CHAIN_SENDER");

    function run() external {
        vm.startBroadcast(deployerPrivateKey);
        CrossChainReceiver(crossChainReceiver).setRegisteredSender(
            sourceChain,
            bytes32(uint256(uint160(address(crossChainSender))))
        );

        vm.stopBroadcast();
    }
}
