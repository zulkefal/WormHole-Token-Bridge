// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "../lib/forge-std/src/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CrossChainSender} from "../src/CrossChainSender.sol";
import {CrossChainReceiver} from "../src/CrossChainReceiver.sol";

contract CrossChainSenders is Test {
    /// Sepolia USDT address
    address sepoliaUSDT = 0x6fEA2f1b82aFC40030520a6C49B0d3b652A65915;

    ///sender who holds tokens for bridging
    address senderSepolia = 0x33aF209AFDA52d31fFB473226E81A5063eC36b3A;

    // **************************************************************************************************************************************************
    // **************************************************************** Sender Details ******************************************************************
    // **************************************************************************************************************************************************

    /// token bridge address (sepolia)
    address _tokenBridgeSender = 0xDB5492265f6038831E89f495670FF909aDe94bd9;

    /// wormhole relayer address on sepolia
    address wormholeRelayerSender = 0x7B1bD7a6b4E61c2a123AC6BC2cbfC614437D0470;

    /// worm hole contract on sepolia
    address wormholeSender = 0x4a8bc80Ed5a4067f1CCf107057b8270E0cC11A78;

    // **************************************************************************************************************************************************
    // **************************************************************** Receiver Details ****************************************************************
    // **************************************************************************************************************************************************

    /// wormhole relayer address on hoelsky
    address wormholeRelayerReciever;

    /// token bridge address (holesky)
    address _tokenBridgeReceiver;

    /// worm hole contract on holesky
    address wormholeReciever;

    // **************************************************************************************************************************************************
    // **************************************************************** Contract Instances **************************************************************
    // **************************************************************************************************************************************************

    /// instance of CrossChainSender Contract
    CrossChainSender crossChainSender;

    /// instance of CrossChainReceiver Contract
    CrossChainReceiver crossChainReceiver;

    // **************************************************************************************************************************************************
    // **************************************************************** Setup ***************************************************************************
    // **************************************************************************************************************************************************

    function setUp() public {
        deal(sepoliaUSDT, senderSepolia, 10000e6); // Give sender 1000 USDT
        vm.deal(senderSepolia, 1000e18); // Give sender some ETH for gass

        crossChainSender = new CrossChainSender(
            wormholeRelayerSender,
            _tokenBridgeSender,
            wormholeSender
        );

        crossChainReceiver = new CrossChainReceiver(
            wormholeRelayerReciever,
            _tokenBridgeReceiver,
            wormholeReciever
        );
    }

    // **************************************************************************************************************************************************
    // **************************************************************** Functions ***********************************************************************
    // **************************************************************************************************************************************************

    function testCrossChainDeposit() public {
        // Simulate a cross-chain deposit
        uint16 targetChain = 10002;
        address targetReceiver = 0x1234567890123456789012345678901234567890;
        address recipient = 0xF6211448a2f522EAdcbDbF2f46CeaE43237E2bA7;
        uint256 amount = 1000e6; // Amount to send (100 USDT)

        vm.startPrank(senderSepolia);

        IERC20(sepoliaUSDT).approve(address(crossChainSender), amount);

        crossChainSender.sendCrossChainDeposit{
            value: crossChainSender.quoteCrossChainDeposit((targetChain))
        }((targetChain), targetReceiver, recipient, amount, sepoliaUSDT);
    }
}
