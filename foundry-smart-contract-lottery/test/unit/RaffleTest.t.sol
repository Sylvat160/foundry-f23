// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {CreateSubscription} from "../../script/Interaction.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract RaffleTest is StdCheats, Test {
    /* Errors */
    event RequestedRaffleWinner(uint256 indexed requestId);
    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed player);

    Raffle public raffle;
    HelperConfig public helperConfig;

    uint64 subscriptionId;
    bytes32 gasLane;
    uint256 automationUpdateInterval;
    uint256 raffleEntranceFee;
    uint32 callbackGasLimit;
    address vrfCoordinatorV2;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        vm.deal(PLAYER, STARTING_USER_BALANCE);

        (
            ,
            gasLane,
            automationUpdateInterval,
            raffleEntranceFee,
            callbackGasLimit,
            vrfCoordinatorV2, // link
            // deployerKey
            ,

        ) = helperConfig.activeNetworkConfig();
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    /////////////////////////
    // enterRaffle         //
    /////////////////////////

    function testRaffleRevertsWHenYouDontPayEnought() public {
        // Arrange
        vm.prank(PLAYER);
        // Act / Assert
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enterRaffle{value: raffleEntranceFee}();
        // Assert
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEmitsEventOnEntrance() public {
        // Arrange
        vm.prank(PLAYER);

        // Act / Assert
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEnter(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
        vm.warp(block.timestamp + automationUpdateInterval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        // Act / Assert
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
    }

    ///////////////////
    // checkUpKeep   //
    //////////////////

    function testCheckUpKeepReturnsIfHasNoBalance() public {
        // Arrange
        vm.warp(block.timestamp + automationUpdateInterval + 1);
        // Act
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");

        // Assert
        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRaffleNotOpen() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();

        vm.warp(block.timestamp + automationUpdateInterval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        //Act
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        //Assert
        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfEnoughTimeHasntPassed() public {
        //Arrage
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
        //Act
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        //Assert
        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnsTrueWhenParamaterAreGood() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
        vm.warp(block.timestamp + automationUpdateInterval + 1);
        vm.roll(block.number + 1);
        //Act
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        //Assert
        assert(upKeepNeeded);
    }

    /////////////////////
    // performUpkeep  //
    ////////////////////

    function testPerformUpKeepCanOnlyPerforIfCheckUpKeepIsTrue() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
        vm.warp(block.timestamp + automationUpdateInterval + 1);
        vm.roll(block.number + 1);
        //Act & Assert
        // vm.expectRevert(Raffle.Raffle__UpkeepNotNeeded.selector);
        raffle.performUpkeep("");
    }

    function testPerformUpkeepToRevertIfCheckUpKeepIsFalse() public {
        //Arrange
        uint256 balance = 0;
        uint256 numPlayers = 0;
        uint256 raffleState = uint256(Raffle.RaffleState.OPEN);
        // Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector,
                balance,
                numPlayers,
                raffleState
            )
        );
        raffle.performUpkeep("");
    }

    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
        vm.warp(block.timestamp + automationUpdateInterval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpKeepUpdateRaffleStateAndEmitsRequestId()
        public
        raffleEnteredAndTimePassed
    {
        // Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(raffleState == Raffle.RaffleState.CALCULATING);
    }

    ///////////////////////////
    // fulfillRandomWord    //
    //////////////////////////

    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 _requestId
    ) public skipFork {
        // Arrange
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinatorV2).fulfillRandomWords(
            _requestId,
            address(raffle)
        );
    }

    function testFulffilRandomWordsPicksWinnerResetsAndSendMoney()
        public
        raffleEnteredAndTimePassed skipFork
    {
        //Arrange 
        uint256 additionalEntrants = 5;
        uint256 startingIndex = 1;
        for (uint256 i = startingIndex; i < additionalEntrants + startingIndex; i++) {
            address player = address(uint160(i));
            hoax(player, STARTING_USER_BALANCE);
            raffle.enterRaffle{value: raffleEntranceFee}();
        }

        uint256 prize = raffleEntranceFee * (additionalEntrants + 1);

        // Pretend to be chainlink vrf and pick the winner
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        uint256 previousTimeStamp = raffle.getLastTimeStamp();

        VRFCoordinatorV2Mock(vrfCoordinatorV2).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );

        // Assert
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        // assert(uint256(raffle.getRaffleState()) > 0);
        // assert(raffle.getRecentWinner() != address(0));
        // assert(raffle.getNumberOfPlayers() == 0);
        // assert(previousTimeStamp < raffle.getLastTimeStamp());
        assert(raffle.getRecentWinner().balance == prize + STARTING_USER_BALANCE - raffleEntranceFee);


    }
}
