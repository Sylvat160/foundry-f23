// Is going to narrow down the way we call our functions
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDsc} from "../../script/DeployDsc.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract Handler is Test {
    DSCEngine engine;
    DecentralizedStableCoin dsc;
    ERC20Mock weth;
    ERC20Mock wbtc;
    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _engine, DecentralizedStableCoin _dsc) {
        engine = _engine;
        dsc = _dsc;
        address[] memory tokens = engine.getCollateralTokens();
        weth = ERC20Mock(tokens[0]);
        wbtc = ERC20Mock(tokens[1]);
    }

    //deposit collateral <-
    function depositCollateral(uint256 collateralSeed, uint256 amount) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amount = bound(amount, 1, MAX_DEPOSIT_SIZE);
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amount);
        collateral.approve(address(engine), amount);
        engine.depositCollateral(address(collateral), amount);
        vm.stopPrank();
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amount) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = engine.getCollateralBalanceOfUser(msg.sender, address(collateral));
        amount = bound(amount, 0, maxCollateralToRedeem);
        if (amount == 0) {
            return;
        }
        console.log("Redeeming collateral: ", amount);
        console.log("Max collateral to redeem: ", maxCollateralToRedeem);
        console.log("Collateral address: ", address(collateral));
        //   Total Supply:  0
        //   WETH Value:  41932837592281000000
        //   WBTC Value:  0
        //   Bound result 4328662008409491
        //   Redeeming collateral:  4328662008409491
        //   Max collateral to redeem:  20966418796140500
        //   Collateral address:  0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        //   Total Supply:  0
        //   WETH Value:  41932837592281000000
        //   WBTC Value:  0

        engine.redeemCollateral(address(collateral), 1e18);
    }

    // Helper function
    function _getCollateralFromSeed(uint256 seed) private view returns (ERC20Mock) {
        if (seed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
