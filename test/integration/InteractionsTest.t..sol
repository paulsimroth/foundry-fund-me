// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    // Create User Address to test transactions
    address USER = makeAddr("user");
    //Starting balance for USER address
    uint256 constant STARTING_BALANCE = 10 ether;
    // Set 1 ETH as constant to use for testing transactions
    uint256 constant SEND_VALUE = 0.1 ether;
    // Gas Price for local testing
    uint256 constant GAS_PRICE = 1;

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

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
