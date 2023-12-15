// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // Create USer Address to test transactions
    address USER = makeAddr("user");
    //Starting balance for USER address
    uint256 constant STARTING_BALANCE = 10 ether;
    // Set 1 ETH as constant to use for testing transactions
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        /**
         * DeployFundMe is used for setting up priceFeed
         * contract gets imported here and used for running tests
         */
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // Give USER funds for testing transactions
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinAmountIsFive() public {
        assertEq(fundMe.MIN_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        // Test getVersion()
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsNotEnoughEth() public {
        // Expect revert on sending not enough ETH
        vm.expectRevert();
        fundMe.fund(); // send 0 value
    }

    function testFundUpdatesFundedData() public {
        // Create fake address to send transactions during tests
        // Next TX will be sent by USER
        vm.prank(USER);

        // Fund Contract
        fundMe.fund{value: SEND_VALUE}();

        // Assert correct amount and mapping
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToFunderArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    // Modifier to send funds to Contract by USER
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Create multiple users and fund contract
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
