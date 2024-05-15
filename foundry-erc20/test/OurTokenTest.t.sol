// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployOurToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployOurToken.INITIAL_SUPPLY());
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend 1000 tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Bob checks Alice's allowance
        uint256 transferAmount = 500;
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
        uint256 transferAmount = 5000;
        address receiver = makeAddr("receiver");
        vm.prank(bob);
        ourToken.transfer(receiver, transferAmount);
        assertEq(ourToken.balanceOf(receiver), transferAmount);
    }


}