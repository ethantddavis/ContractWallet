// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Swap.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceFeed {

    address private constant WETH_RINKARBY = 0xB47e6A5f8b33b3F17603C83a0535A9dcD7E32681;
    address private constant ETH_USD = 0x5f0423B1a6935dc5596e7A24d98532b67A0AeFd8;
    address private constant BTC_USD = 0x0c9973e7a27d00e656B9f153348dA46CaD70d03d; 

    mapping(address => address) public aggregator;

    constructor() {
        aggregator[address(0)] = ETH_USD;
        aggregator[WETH_RINKARBY] = ETH_USD;
    }

    function addAggregator(address token, address _aggregator) external {
        aggregator[token] = _aggregator;
    }

    /**
     * Returns the latest price
     */
    function getPrice(address token) public view returns (int) {        
        if (aggregator[token] == address(0)) {
            return 0;
        } 
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(aggregator[token]).latestRoundData();
        return price / 100000000;
    }
}
