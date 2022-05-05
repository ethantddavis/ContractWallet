// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error TransferFailed();

contract Bank {

    mapping(address => mapping(address => uint256)) private _balance;

    event Deposit (
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );
    event Withdraw (
        address indexed user,
        address indexed token,
        uint256 indexed amount,
        uint256 remaining
    );
    

    constructor() {
    
    }

    function deposit(uint256 amount, address token) public {

        // record balance
        _balance[msg.sender][token] += amount;

        // transfer collateral
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        //emit Deposit event
        emit Deposit(msg.sender, token, amount);
    }

    function withdraw(uint256 amount, address token) public {
        // make sure user does not withdraw too much
        require(amount <= _balance[msg.sender][token], "Bank: cannot withdraw more than deposited");
       
        // assign msg.sender ether deposit balance to variable for event
        uint256 remainingBalance = _balance[msg.sender][token] - amount;

        // send collateral back to user
        IERC20(token).transfer(msg.sender, amount);

        // update balance
        _balance[msg.sender][token] = remainingBalance;
        
        emit Withdraw(msg.sender, token, amount, remainingBalance);
    }

    function balanceOf(address user, address token) public view returns (uint256) {
        return _balance[user][token];
    }

} 