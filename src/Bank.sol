// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Swap.sol";
import "./PriceFeed.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Bank is Swap, PriceFeed {

    mapping(address => mapping(address => uint256)) private _balance;
    mapping(address => uint256) private _ethBalance;

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

    receive() external payable {}

    /**
     * Transfer and record ERC20 from user to bank
     */
    function deposit(uint256 amount, address token) external {

        _balance[msg.sender][token] += amount;
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, token, amount);
    }
 
    /**
     * Accept and record ETH from user to bank
     */
    function deposit(uint256 amount) external payable {
        require(msg.value == amount, "Bank: msg.value and amount parameter must be the same");

        _ethBalance[msg.sender] += amount;

        emit Deposit(msg.sender, address(0), amount);
    }

    /**
     * Transfer and update ERC20 from bank to user
     */
    function withdraw(uint256 amount, address token) external {
        require(amount <= _balance[msg.sender][token], "Bank: cannot withdraw more than deposited");
        
        uint256 remainingBalance = _balance[msg.sender][token] - amount;
        _balance[msg.sender][token] = remainingBalance;
        IERC20(token).transfer(msg.sender, amount);

        emit Withdraw(msg.sender, token, amount, remainingBalance);
    }

    /**
     * Transfer and update ETH from bank to user
     */
    function withdraw(uint256 amount) external {
        require(amount <= _ethBalance[msg.sender], "Bank: cannot withdraw more than deposited");

        uint256 remainingBalance = _ethBalance[msg.sender] - amount;
        _ethBalance[msg.sender] = remainingBalance;
        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, address(0), amount, remainingBalance);
    }

    function wrapEth(uint256 amount) external {
        require(amount <= _ethBalance[msg.sender], "Bank: cannot wrap more than deposited");

        _wrapEth(amount);

        _ethBalance[msg.sender] -= amount;
        _balance[msg.sender][wethAddress()] += amount;
    }

    function unwrapEth(uint256 amount) external {
        require(amount <= _balance[msg.sender][wethAddress()], "Bank: cannot unwrap more than deposited");

        _unwrapEth(amount);

        _ethBalance[msg.sender] += amount;
        _balance[msg.sender][wethAddress()] -= amount;
    }

    /**
     * Return a users balance of a specfic token
     */
    function balanceOf(address user, address token) public view returns (uint256 balance) {
        if (token == address(0)) {
            balance = _ethBalance[user];
        } else {
            balance = _balance[user][token];
        }

        return balance;
    }

    function sumBalances(address user, address[] memory tokens) external view returns (uint256 sum) {
        for  (uint256 i = 0; i < tokens.length; i++) {
            sum += balanceOf(user, tokens[i]) * uint256(getPrice(tokens[i])); 
        }

        return sum;
    }

    function swap(address tokenToSell, address tokenToBuy, uint256 amountToSell) external {
        //IERC20(wethAddress()).approve(address(bank), amount);
        uint256 amountRecieved = _swap(tokenToSell, tokenToBuy, amountToSell);
    }

} 