// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "../lib/forge-std/src/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TomiSupply is Test {
    address tomiAddress = 0x4385328cc4D643Ca98DfEA734360C0F596C83449;

    ///sender who holds tokens for bridging
    address sender = 0x33aF209AFDA52d31fFB473226E81A5063eC36b3A;

    function setUp() public {
        // Give sender some TOMI tokens
        deal(tomiAddress, sender, 10000e18); // 10,000 TOMI
        vm.deal(sender, 1000e18); // Give sender some ETH for gas
    }

    function testTomiSupply() public {
        // Check the total supply of TOMI tokens
        uint256 totalSupply = IERC20(tomiAddress).totalSupply();
        console.log("Total Supply of TOMI:", totalSupply);

        // Check the balance of the sender
        uint256 senderBalance = IERC20(tomiAddress).balanceOf(sender);

        console.log("Sender's TOMI Balance:", senderBalance);

        vm.startPrank(sender);
        IERC20(tomiAddress).approve(
            address(this),
            10000e18 // Approve 1000 TOMI for burning
        );
        IERC20(tomiAddress).transfer(
            0x000000000000000000000000000000000000dEaD,
            1000e18 // Transfer 1000 TOMI to burn
        );

        uint256 supplyAfterBurn = IERC20(tomiAddress).totalSupply();
        console.log("Total Supply of TOMI after burn:", supplyAfterBurn);
    }
}
