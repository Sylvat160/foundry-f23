// SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title OracleLib
 * @dev This library is responsible for the logic of the Oracle
 * @author SYLVAIN TAGNABOU
 * @dev This contract  is used to check the chainlink Oracle for stale data
 * If a price is stale , the function will revert and rebder the DSEngine contract unusable
 */
library OracleLib {
    error OracleLib__StalePrice();
    uint256 private constant TIMEOUT = 3 hours;
    function staleCheckLatestRoundData(AggregatorV3Interface _priceFeed)
        public
        view
        returns (uint80 roundId, int256 price, uint256 startedAt, uint256 timeElapsed, uint80 answeredInRound)
    {
        (roundId, price, startedAt, timeElapsed, answeredInRound) = _priceFeed.latestRoundData();
        uint256 secondsSince = block.timestamp - startedAt;
        if (secondsSince > TIMEOUT) revert OracleLib__StalePrice();
        return (roundId, price, startedAt, timeElapsed, answeredInRound);
    }
}
