// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// Custom error
error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 5 * 1e18;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmount;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        /* require(msg.sender == i_owner, "Only Owner allowed"); */
        // Use if statement and custom error for gas optimization
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MIN_USD,
            "Not enough ETH"
        );
        s_funders.push(msg.sender);
        s_addressToAmount[msg.sender] += msg.value;
    }

    // Gas optimzied version of function withdraw() with minimized storage reads
    function cheaperWithdraw() public onlyOwner {
        uint256 funderLength = s_funders.length;

        for (uint256 i = 0; i < funderLength; i++) {
            address funder = s_funders[i];
            s_addressToAmount[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    function withdraw() public onlyOwner {
        // set mapping of funders to  0
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmount[funder] = 0;
        }

        // reset array of funders by creating a new and empty array
        s_funders = new address[](0);

        //withdraw all funds
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    /** Fallback and Receive Functions */
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /** Getter Functions */
    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmount[fundingAddress];
    }

    function getVersion() external view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
