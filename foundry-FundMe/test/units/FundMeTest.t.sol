// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console}  from "forge-std/Test.sol";
import {FundMe} from "../../src/FundeMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, START_BALANCE);
    }

    function testMinimumUsd() public view {
        uint minimumUsd = fundMe.minimunUsd();
        assertEq(minimumUsd, 5e18, "Minimum USD should be 5");
    }


    function testOwnerIsMsgSender() public view {
        // console.log("Owner: ", fundMe.owner(), "Sender: ", msg.sender);
        // assertEq(fundMe.owner(), address(this), "Owner should be msg.sender");
        assertEq(fundMe.getOwner(), msg.sender, "Owner should be msg.sender");
    }

    function testPriceFeedVersion() public view {
        uint version = fundMe.getVersion();
        assertEq(version, 4, "Version should be 4");
    }

    function testFundFailsWithoutEnoughMoney() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAdressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }

    function testAddFundersToFundersArray() public {
        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithAsSingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used: ", gasUsed);
        //Assert
        uint256 finalOwnerBalance = fundMe.getOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;

        assertEq(finalFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, finalOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFundingIndex = 1;

        for (uint160 i = startingFundingIndex; i < numberOfFunders; i++) {
            hoax(address(i), START_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 finalOwnerBalance = fundMe.getOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;
        assertEq(finalFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, finalOwnerBalance);
    }

    function testWithdrawWithMultipleFundersCheaper() public {
        uint160 numberOfFunders = 10;
        uint160 startingFundingIndex = 1;

        for (uint160 i = startingFundingIndex; i < numberOfFunders; i++) {
            hoax(address(i), START_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 finalOwnerBalance = fundMe.getOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;
        assertEq(finalFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, finalOwnerBalance);
    }

}