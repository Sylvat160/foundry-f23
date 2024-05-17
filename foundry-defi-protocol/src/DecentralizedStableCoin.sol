// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

/**
 * @title Decentralized Stable Coin
 * @author Sylvain TAGNABOU
 * Collateral: Exegenous (BTC, ETH)
 * Minting : Algorithmic
 * Peg: Anchored to USD for relative stability
 *
 * This is the contract meant to be governed by DSSEngine. This contract is just an ERC20 implementation of our stablecoin system.
 */
contract DecentralizedStableCoin {
    constructor() {}
}
