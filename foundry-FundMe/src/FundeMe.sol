// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { PriceConverter } from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {

    using PriceConverter for uint256;
    uint public minimunUsd = 5e18;
    address private i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    address[] private s_funders;
    mapping(address => uint) private s_funderToAmount;

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= minimunUsd, "You need to spend more ETH!");
        s_funders.push(msg.sender);
        s_funderToAmount[msg.sender] = s_funderToAmount[msg.sender] + msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_funderToAmount[funder] = 0;
            // payable(funder).transfer(funderToAmount[funder]);
        }
        s_funders = new address[](0);

        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Failed to send money");
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_funderToAmount[funder] = 0;
            // payable(funder).transfer(funderToAmount[funder]);
        }
        s_funders = new address[](0);

        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Failed to send money");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    /**
     * View / pure functions
     */

    function getAdressToAmountFunded(
        address _fundingAddress
    ) public view returns (uint256) {
        return s_funderToAmount[_fundingAddress];
    }

    function getFunder(uint256 _index) public view returns (address) {
        return s_funders[_index];
    }

    function getOwner () public view returns (address) {
        return i_owner;
    }
}