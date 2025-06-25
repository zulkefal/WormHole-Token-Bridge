// SPDX-License-Identifier: Apache 2
pragma solidity ^0.8.19;

//import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import "wormhole-sdk/interfaces/cctp/ITokenMessenger.sol";

import "wormhole-sdk/interfaces/IWormhole.sol";
import {WormholeCctpMessages} from "wormhole-sdk/libraries/WormholeCctpMessages.sol";
import {toUniversalAddress} from "wormhole-sdk/Utils.sol";

import {VM_ADDRESS} from "./Constants.sol";
import "./CctpOverride.sol";
import "./WormholeOverride.sol";

//faked foreign call chain:
//  foreignCaller -> foreignSender -> FOREIGN_TOKEN_MESSENGER -> foreign MessageTransmitter
//example:
//  foreignCaller = swap layer
//  foreignSender = liquidity layer - implements WormholeCctpTokenMessenger
//                     emits WormholeCctpMessages.Deposit VAA with a RedeemFill payload

//local call chain using faked vaa and circle attestation:
//  test -> intermediate contract(s) -> mintRecipient -> MessageTransmitter -> TokenMessenger
//example:
//  intermediate contract = swap layer
//  mintRecipient = liquidity layer

//using values that are easily recognizable in an encoded payload
uint32  constant FOREIGN_DOMAIN = 0xDDDDDDDD;
bytes32 constant FOREIGN_TOKEN_MESSENGER =
  0xEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE;
bytes32 constant FOREIGN_USDC =
  0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC;

//simulates a foreign WormholeCctpTokenMessenger
contract WormholeCctpSimulator {
  using WormholeOverride for IWormhole;
  using CctpMessages for CctpTokenBurnMessage;
  using CctpOverride for IMessageTransmitter;
  using CctpMessages for bytes;
  using { toUniversalAddress } for address;

  Vm constant vm = Vm(VM_ADDRESS);

  IWormhole           immutable wormhole;
  IMessageTransmitter immutable messageTransmitter;
  ITokenMessenger     immutable tokenMessenger;
  uint16              immutable foreignChain;

  uint64 foreignNonce;
  uint64 foreignSequence;
  bytes32 foreignCaller; //address that calls foreignSender to burn their tokens and emit a message
  bytes32 foreignSender; //address that sends tokens by calling TokenMessenger.depositForBurn
  address mintRecipient; //recipient of cctp messages
  address destinationCaller; //by default mintRecipient

  constructor(
    IWormhole wormhole_,
    address tokenMessenger_,
    uint16 foreignChain_,
    bytes32 foreignSender_, //contract that invokes the core bridge and calls depositForBurn
    address mintRecipient_,
    address usdc
  ) {
    wormhole           = wormhole_;
    tokenMessenger     = ITokenMessenger(tokenMessenger_);
    foreignChain       = foreignChain_;
    foreignSender      = foreignSender_;
    mintRecipient      = mintRecipient_;
    destinationCaller  = mintRecipient;
    messageTransmitter = tokenMessenger.localMessageTransmitter();

    wormhole.setUpOverride();
    messageTransmitter.setUpOverride();

    foreignNonce    = 0xBBBBBBBBBBBBBBBB;
    foreignSequence = 0xAAAAAAAAAAAAAAAA;
    //default value - can be overridden if desired
    foreignCaller = 0xCA11E2000CA11E200CA11E200CA11E200CA11E200CA11E200CA11E2000CA11E2;

    //register our fake foreign circle token messenger
    vm.prank(tokenMessenger.owner());
    tokenMessenger.addRemoteTokenMessenger(FOREIGN_DOMAIN, FOREIGN_TOKEN_MESSENGER);

    //register our fake foreign usdc
    //  The Circle TokenMessenger has been implemented in a way that supports multiple tokens
    //    so we have to establish the link between our fake foreign USDC with the actual local
    //    USDC.
    ITokenMinter localMinter = tokenMessenger.localMinter();
    vm.prank(localMinter.tokenController());
    localMinter.linkTokenPair(usdc, FOREIGN_DOMAIN, FOREIGN_USDC);
  }

  //to reduce boilerplate, we use setters to avoid arguments that are likely the same
  function setMintRecipient(address mintRecipient_) external {
    mintRecipient = mintRecipient_;
  }

  //setting address(0) disables the check in MessageTransmitter
  function setDestinationCaller(address destinationCaller_) external {
    destinationCaller = destinationCaller_;
  }

  function setForeignCaller(bytes32 foreignCaller_) external {
    foreignCaller = foreignCaller_;
  }

  function setForeignSender(bytes32 foreignSender_) external {
    foreignSender = foreignSender_;
  }

  //for creating "pure" cctp transfers (no associated Wormhole vaa)
  function craftCctpTokenBurnMessage(
    uint256 amount
  ) external returns (
    bytes memory encodedCctpMessage,
    bytes memory cctpAttestation
  ) {
    (, encodedCctpMessage, cctpAttestation) = _craftCctpTokenBurnMessage(amount);
  }

  //for creating cctp + associated vaa transfers
  function craftWormholeCctpRedeemParams(
    uint256 amount,
    bytes memory payload
  ) external returns (
    bytes memory encodedVaa,
    bytes memory encodedCctpMessage,
    bytes memory cctpAttestation
  ) {
    CctpTokenBurnMessage memory burnMsg;
    (burnMsg, encodedCctpMessage, cctpAttestation) = _craftCctpTokenBurnMessage(amount);

    //craft the associated VAA
    (, encodedVaa) = wormhole.craftVaa(
      foreignChain,
      foreignSender,
      foreignSequence++,
      WormholeCctpMessages.encodeDeposit(
        burnMsg.burnToken,
        amount,
        burnMsg.header.sourceDomain,
        burnMsg.header.destinationDomain,
        burnMsg.header.nonce,
        foreignCaller,
        burnMsg.mintRecipient,
        payload
      )
    );
  }

  function _craftCctpTokenBurnMessage(
    uint256 amount
  ) internal returns (
    CctpTokenBurnMessage memory burnMsg,
    bytes memory encodedCctpMessage,
    bytes memory cctpAttestation
  ) {
    //compose the cctp burn msg
    burnMsg.header.sourceDomain      = FOREIGN_DOMAIN;
    burnMsg.header.destinationDomain = messageTransmitter.localDomain();
    burnMsg.header.nonce             = foreignNonce++;
    burnMsg.header.sender            = FOREIGN_TOKEN_MESSENGER;
    burnMsg.header.recipient         = address(tokenMessenger).toUniversalAddress();
    burnMsg.header.destinationCaller = destinationCaller.toUniversalAddress();
    burnMsg.burnToken     = FOREIGN_USDC;
    burnMsg.mintRecipient = mintRecipient.toUniversalAddress();
    burnMsg.amount        = amount;
    burnMsg.messageSender = foreignSender;

    encodedCctpMessage = burnMsg.encode();
    cctpAttestation = messageTransmitter.sign(burnMsg);
  }
}
