// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { SimpleStorage } from "../src/SimpleStorage.sol";

contract SimpleStorageScript is Script {
    // function setUp() public {}

    function run() external returns (SimpleStorage) {
        vm.broadcast();
        SimpleStorage simpleStorage = new SimpleStorage();
        // vm.stopBroadcast();
        return simpleStorage;
    }

    // function run() public {
    //     vm.broadcast();
    // }
}
