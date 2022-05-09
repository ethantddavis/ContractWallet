// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "./mocks/MockToken.sol";

contract BankTest is Test {
    
    Bank public bank;
    MockToken public mockToken;

    receive() external payable {}

    function setUp() public {
        bank = new Bank();
        mockToken = new MockToken();
    }

    function testDeposit(uint64 amount) public {
        // before
        uint256 initialTokenBalance = mockToken.balanceOf(address(this));
        mockToken.approve(address(bank), amount);

        // test
        bank.deposit(amount, address(mockToken));

        // check
        uint256 bankBalance = bank.balanceOf(address(this), address(mockToken));
        assertEq(bankBalance, amount);

        uint256 senderBalance = mockToken.balanceOf(address(this));
        uint256 expectedSenderBalance = initialTokenBalance - amount;
        assertEq(senderBalance, expectedSenderBalance);
    }

    function testFailDeposit() public {
        // before
        uint256 amount = 10000000e18;
        mockToken.approve(address(bank), amount);

        // test
        bank.deposit(amount, address(mockToken));
    }

    function testEthDeposit(uint64 amount) public {
        // before
        uint256 initialEthBalance = address(this).balance;

        // test
        bank.deposit{value: amount}(amount);

        // check
        uint256 bankBalance = bank.balanceOf(address(this), address(0));
        assertEq(bankBalance, amount);

        uint256 senderBalance = address(this).balance;
        uint256 expectedSenderBalance = initialEthBalance - amount;
        assertEq(senderBalance, expectedSenderBalance);
    }

    function testFailEthDeposit() public {
        // before
        uint256 amount = 10e18;

        // test
        bank.deposit{value: amount}(amount + 1);
    }

    function testWithdraw(uint64 amount) public {
        // before
        mockToken.approve(address(bank), 1000000e18);
        bank.deposit(1000000e18, address(mockToken));

        uint256 initialSenderBalance = mockToken.balanceOf(address(this));
        uint256 initialBankBalance = bank.balanceOf(address(this), address(mockToken));

        // test
        bank.withdraw(amount, address(mockToken));

        // check 
        uint256 bankBalance = bank.balanceOf(address(this), address(mockToken));
        uint256 expectedBankBalance = initialBankBalance - amount;
        assertEq(bankBalance, expectedBankBalance);

        uint256 senderBalance = mockToken.balanceOf(address(this));
        uint256 expectedSenderBalance = initialSenderBalance + amount;
        assertEq(senderBalance, expectedSenderBalance);
    }

    function testFailWithdraw() public {

        // test
        bank.withdraw(100e18, address(mockToken));
    }

    function testEthWithdraw(uint64 amount) public {
        // before
        bank.deposit{value: 1000000e18}(1000000e18);

        uint256 initialSenderBalance = address(this).balance;
        uint256 initialBankBalance = bank.balanceOf(address(this), address(0));

        // test
        bank.withdraw(amount);

        // check 
        uint256 bankBalance = bank.balanceOf(address(this), address(0));
        uint256 expectedBankBalance = initialBankBalance - amount;
        assertEq(bankBalance, expectedBankBalance);

        uint256 senderBalance = address(this).balance;
        uint256 expectedSenderBalance = initialSenderBalance + amount;
        assertEq(senderBalance, expectedSenderBalance);
    }

    function testFailEthWithdraw() public {

        // test
        bank.withdraw(100e18, address(0));
    }

    function testWrapEth(uint64 amount) public {
        // before
        bank.deposit{value: 1000000e18}(1000000e18);
        uint256 initialEthBalance = bank.balanceOf(address(this), address(0));

        // test 
        bank.wrapEth(amount);

        // check 
        uint256 ethBalance = bank.balanceOf(address(this), address(0));
        uint256 expectedEthBalance = initialEthBalance - amount;
        assertEq(ethBalance, expectedEthBalance);

        uint256 wethBalance = bank.balanceOf(address(this), bank.wethAddress());
        assertEq(wethBalance, amount);
    }

    function testFailWrapEth() public {
        // before
        uint256 amount = 1e18;

        // test
        bank.wrapEth(amount);
    }

    function testUnwrapEth(uint64 amount) public {
        // before
        bank.deposit{value: 1000000e18}(1000000e18);
        bank.wrapEth(1000000e18);
        uint256 initialWethBalance = bank.balanceOf(address(this), address(bank.wethAddress()));

        // test 
        bank.unwrapEth(amount);
        
        // check 
        uint256 ethBalance = bank.balanceOf(address(this), address(0));
        assertEq(ethBalance, amount);

        uint256 wethBalance = bank.balanceOf(address(this), bank.wethAddress());
        uint256 expectedWethBalance = initialWethBalance - amount;
        assertEq(wethBalance, expectedWethBalance);
    }

    function testFailUnwrapEth() public {
        // before
        uint256 amount = 1e18;

        // test
        bank.unwrapEth(amount);
    }

    function testSumBalances(uint16 amount) public {
        // before 
        address[] memory tokens = new address[](3);
        tokens[0] = address(0);
        tokens[1] = address(mockToken);
        tokens[2] = bank.wethAddress();
        bank.deposit{value: 1e18}(1e18);
        IERC20(mockToken).approve(address(bank), amount);
        bank.deposit(amount, address(mockToken));
        bank.wrapEth(amount);

        // test
        uint256 sum = bank.sumBalances(address(this), tokens);

        // check
        uint256 lowerBound = amount + 2000e18;
        uint256 upperBound = amount + 3000e18;
        assertTrue(sum > lowerBound && sum < upperBound);
    }
}
