// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/forge-std/src/Script.sol";
import "../src/Worm.sol";

contract DeployToken is Script {
    address initialOwner = vm.envAddress("INITIAL_OWNER");
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    Worm public worm;

    function run() external {
        vm.startBroadcast(deployerPrivateKey);
        worm = new Worm(initialOwner);
        vm.stopBroadcast();
    }
}
