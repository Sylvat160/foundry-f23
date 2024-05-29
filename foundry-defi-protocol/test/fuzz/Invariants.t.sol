// SPDX-License-Identifier: MIT
// Invariant aka properties

// 1. What are our invariants?
// - The total Supply of DSC should be less than the total value of collateral
// - Getter view functions should never revert

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDsc} from "../../script/DeployDsc.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDsc deployer;
    DSCEngine engine;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    Handler handler;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDsc();
        (dsc, engine, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        handler = new Handler(engine, dsc);
        targetContract(address(handler));
    }

    function invariants_protocolMustHaveMoreValueThanTotalSupply() public view {
        // get the value of all the collateral in the protocol
        // compare it to all the debt
        uint256 totalSupply = dsc.totalSupply();
        
        uint256 wethWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint256 wbtcWethDeposited = IERC20(wbtc).balanceOf(address(engine));

        uint256 wethValue = engine.getUsdValue(weth, wethWethDeposited);
        uint256 wbtcValue = engine.getUsdValue(wbtc, wbtcWethDeposited);

        console.log("Total Supply: ", totalSupply);
        console.log("WETH Value: ", wethValue);
        console.log("WBTC Value: ", wbtcValue);

        assert(wethValue + wbtcValue >= totalSupply);
    }
}
