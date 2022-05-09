// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PriceFeed.sol";
import "./mocks/MockToken.sol";

contract BankTest is Test {
    
    PriceFeed public priceFeed;

    receive() external payable {}

    function setUp() public {
        priceFeed = new PriceFeed();
    }

    function testEthUsd() public {

        // test
        int price = priceFeed.getPrice(address(0));

        emit log_int(price);
    }

}
