// SPDX-License-Identifier: MIT
/*pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "../src/Swap.sol";
import "./mocks/MockToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapTest is Test {
    
    address public constant WETH_GOERLI = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address public constant WBTC_GOERLI = 0xC04B0d3107736C32e19F1c62b2aF67BE61d63a05;
    Swap public swap;

    receive() external payable {}

    function setUp() public {
        swap = new Bank();
    }

    function testWrapEth(uint64 amount) public {
        // before
        uint256 initialEthBalance = address(this).balance;

        // test 
        swap.wrapEth(amount);

        // check
        uint256 ethBalance = address(this).balance;
        uint256 expectedEthBalance = initialEthBalance - amount;
        assertEq(ethBalance, expectedEthBalance);

        uint256 wethBalance = IERC20(WETH_GOERLI).balanceOf(address(this));
        assertEq(wethBalance, amount);
    }

    function testFailWrapEth() public {
        // before
        uint256 amount = 1e18;

        // test
        swap.wrapEth{value: amount}(amount + 1);
    }

    function testSwap() public {
        // before
        uint256 amount = 1e12;
        swap.wrapEth{value: amount}(amount);
        IERC20(WETH_GOERLI).approve(address(swap), amount);

        // test 
        swap.swap(WETH_GOERLI, WBTC_GOERLI, amount, address(this));
    }
}*/
