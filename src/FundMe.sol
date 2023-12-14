// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";

// Custom error
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 5 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmount;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        /* require(msg.sender == i_owner, "Only Owner allowed"); */
        // Use if statement and custom error for gas optimization
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MIN_USD, "Not enough ETH");
        funders.push(msg.sender);
        addressToAmount[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // set mapping of funders to  0
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmount[funder] = 0;
        }

        // reset array of funders by creating a new and empty array
        funders = new address[](0);

        //withdraw all funds
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
