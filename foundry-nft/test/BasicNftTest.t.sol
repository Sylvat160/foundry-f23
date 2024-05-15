// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {DeployBasicNft} from "../script/DeployBasicNft.s.sol";

contract BasicNftTest is Test {
    DeployBasicNft deployer;
    BasicNft basicNft;

    address public user = makeAddr("USER");
    string s_tokenUri =
        "https://ipfs.io/ipfs/QmSsYRx3LpDAb1GZQm7zZ1AuHZjfbPkD6J7s9r41xu1mf8?filename=pug.png";

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    function testNameIsCorrect() public view {
        string memory name = basicNft.name();
        string memory expectedName = "Dogie";
        assertEq(
            keccak256(abi.encodePacked(name)),
            keccak256(abi.encodePacked(expectedName))
        );
    }

    function testCanMintAndHaveBalance() public {
        vm.prank(user);
        basicNft.mintNft(s_tokenUri);

        assertEq(basicNft.balanceOf(user), 1);
        assertEq(
            keccak256(abi.encodePacked(basicNft.tokenURI(0))),
            keccak256(abi.encodePacked(s_tokenUri))
        );
    }
}
