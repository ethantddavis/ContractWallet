// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

interface wETH {
    function deposit() external payable;
    function withdraw(uint256) external;
}

abstract contract Swap {

    ISwapRouter private constant SWAP_ROUTER = ISwapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
    address private constant WETH_GOERLI = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address private constant WETH_RINKARBY = 0xB47e6A5f8b33b3F17603C83a0535A9dcD7E32681;

    function swap(address tokenIn, address tokenOut, uint256 amountIn, address recipient) external {
        require(amountIn > 0, "Must pass non 0 ETH amount");

        uint256 deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        uint24 fee = 3000;
        uint256 amountOutMinimum = 0;
        uint160 sqrtPriceLimitX96 = 0;
        
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            recipient,
            deadline,
            amountIn,
            amountOutMinimum,
            sqrtPriceLimitX96
        );
        
        SWAP_ROUTER.exactInputSingle{ value: amountIn }(params);
    }

    function _wrapEth(uint256 amount) internal {
        wETH(wethAddress()).deposit{value : amount}();
    }

    function _unwrapEth(uint256 amount) internal {
        wETH(wethAddress()).withdraw(amount);
    }

    function wethAddress() public pure returns (address) {
        
        return WETH_RINKARBY;
    }

  
}