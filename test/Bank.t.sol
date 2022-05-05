// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "./mocks/MockToken.sol";

contract BankTest is Test {
    
    Bank public bank;
    MockToken public mockToken;

    function setUp() public {
        bank = new Bank();
        mockToken = new MockToken();
    }

    function testDeposit(uint64 amount) public {
        // before test
        uint256 initialTokenBalance = mockToken.balanceOf(address(this));
        mockToken.approve(address(bank), amount);

        // test
        bank.deposit(amount, address(mockToken));

        // check results
        uint256 bankBalance = bank.balanceOf(address(this), address(mockToken));
        assertEq(bankBalance, amount);

        uint256 senderBalance = mockToken.balanceOf(address(this));
        uint256 expectedSenderBalance = initialTokenBalance - amount;
        assertEq(senderBalance, expectedSenderBalance);
    }

    function testWithdraw(uint64 amount) public {
        // before test
        mockToken.approve(address(bank), 1000000e18);
        bank.deposit(1000000e18, address(mockToken));

        uint256 initialSenderBalance = mockToken.balanceOf(address(this));
        uint256 initialBankBalance = bank.balanceOf(address(this), address(mockToken));

        // test
        bank.withdraw(amount, address(mockToken));

        // check results
        uint256 bankBalance = bank.balanceOf(address(this), address(mockToken));
        uint256 expectedBankBalance = initialBankBalance - amount;
        assertEq(bankBalance, expectedBankBalance);

        uint256 senderBalance = mockToken.balanceOf(address(this));
        uint256 expectedSenderBalance = initialSenderBalance + amount;
        assertEq(senderBalance, expectedSenderBalance);
    }
}
