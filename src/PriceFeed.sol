// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Swap.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceFeed {

    address private constant WETH_RINKARBY = 0xB47e6A5f8b33b3F17603C83a0535A9dcD7E32681;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant ETH_USD = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address private constant BTC_USD = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;
    address private constant ETH_USD_RINKARBY = 0x5f0423B1a6935dc5596e7A24d98532b67A0AeFd8;
    address private constant BTC_USD_RINKARBY = 0x0c9973e7a27d00e656B9f153348dA46CaD70d03d; 

    mapping(address => address) public aggregator;

    constructor() {
        aggregator[address(0)] = ETH_USD;
        aggregator[WETH] = ETH_USD;
        aggregator[WBTC] = BTC_USD;
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
