//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20 ("Mock ERC20", "MERC") {
        _mint(msg.sender, 1000000e18);
    }
}