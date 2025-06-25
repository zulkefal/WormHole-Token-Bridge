// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/forge-std/src/Script.sol";
import {CrossChainSender} from "../src/CrossChainSender.sol";

contract DeployCrossChainSender is Script {
    address wormHoleRelayerSender = vm.envAddress("WORM_HOLE_RELAYER_SOURCE");
    address tokenBridgeSender = vm.envAddress("TOKEN_BRIDGE_SOURCE");
    address wormHoleSender = vm.envAddress("WORM_HOLE_CONTRACT_SOURCE");

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    CrossChainSender crossChainSender;

    function run() external {
        vm.startBroadcast(deployerPrivateKey);
        crossChainSender = new CrossChainSender(
            wormHoleRelayerSender,
            tokenBridgeSender,
            wormHoleSender
        );
        vm.stopBroadcast();
    }
}
