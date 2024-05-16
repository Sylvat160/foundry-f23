// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;    

import {Test, console} from "forge-std/Test.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {DeployMoodNft} from "script/DeployMoodNft.s.sol";

contract MoodNftTest is Test {
    MoodNft moodNft;
    DeployMoodNft deployer;
    address user = makeAddr("user");
    address user2 = makeAddr("user2");

    function setUp() public {
        deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    function testViewTokenUri() public {
        vm.prank(user);
        moodNft.mintNft();
        console.log("Token URI: ", moodNft.tokenURI(0));

    }

    function testFlipMoodWhenNotOwner() public {
        vm.prank(user);
        moodNft.mintNft();

        vm.expectRevert(MoodNft.MoodNft__CantFlipMoodIfNotOwner.selector);
        vm.prank(user2);
        moodNft.flipMood(0);
    }
    
    function testFlipMoodWhenIsOwner() public {
        vm.startPrank(user);
        moodNft.mintNft();
        moodNft.flipMood(0);
        vm.stopPrank();
    }
}