// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/forge-std/src/Script.sol";
import {CrossChainReceiver} from "../src/CrossChainReceiver.sol";

contract DeployCrossChainReceiver is Script {
    address wormHoleRelayerReceiver = vm.envAddress("WORM_HOLE_RELAYER_TARGET");
    address tokenBridgeReceiver = vm.envAddress("TOKEN_BRIDGE_TARGET");
    address wormHoleReceiver = vm.envAddress("WORM_HOLE_CONTRACT_TARGET");
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    CrossChainReceiver public crossChainReceiver;

    function run() external {
        vm.startBroadcast(deployerPrivateKey);
        crossChainReceiver = new CrossChainReceiver(
            wormHoleRelayerReceiver,
            tokenBridgeReceiver,
            wormHoleReceiver
        );
        vm.stopBroadcast();
    }
}
