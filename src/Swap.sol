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
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    

    function _swap(address tokenToSell, address tokenToBuy, uint256 amountToSell) internal returns (uint256) {
        require(amountIn > 0, "Must pass non 0 ETH amount");
        IERC20(tokenIn).approve(address(SWAP_ROUTER), amountIn);
        
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenToSell,
                tokenOut: tokenToBuy,
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        
        return SWAP_ROUTER.exactInputSingle(params);
    }

    function _wrapEth(uint256 amount) internal {
        wETH(wethAddress()).deposit{value : amount}();
    }

    function _unwrapEth(uint256 amount) internal {
        wETH(wethAddress()).withdraw(amount);
    }

    function wethAddress() public pure returns (address) {
        return WETH;
    }

  
}