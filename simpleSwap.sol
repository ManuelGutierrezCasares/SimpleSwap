// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title SimpleSwap contract
/// @author Manuel Gutierrez Casares
/// @notice This contract is based on Uniswap v2
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

contract SimpleSwap is ERC20 {
    address private _tokenA;
    address private _tokenB;

    constructor() ERC20("liquidity", "LQD") {}

    /// @dev Users are able to add liquidity to the management pool.
    /// @dev It's a must to use this function to initialize the management pool.
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity) {
        address __tokenA = _tokenA;
        address __tokenB = _tokenB;

        /// Initializing token addresses for  and check for wrong tokens
        if (__tokenA == address(0) && __tokenB == address(0)) {
            __tokenA = tokenA;
            __tokenB = tokenB;
        } else {
            require(__tokenA == tokenA && __tokenB == tokenB, "Can't swap tokens");
        }

        /// Approve so SC will be able to transfer tokens for the user
        ERC20(tokenA).approve(address(this), amountADesired);
        ERC20(tokenB).approve(address(this), amountBDesired);

        /// Transfer tokens A and B according to what user wants to add to pool
        ERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        ERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        /// Calculate liquidity, send liquidity tokens to user and add 
        liquidity = sqrt(amountADesired * amountBDesired);
        _mint(msg.sender, liquidity);

        return (ERC20(tokenA).balanceOf(address(this)), ERC20(tokenB).balanceOf(address(this)), liquidity);

    }

    /// @dev Users are able to withdraw their tokens based on their current liquidity token amount.
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB) {
        address __tokenA = _tokenA;
        address __tokenB = _tokenB;
        
        /// Validations
        require(__tokenA != address(0) && __tokenB != address(0), "Add liquidity first");
        require(__tokenA == tokenA && __tokenB == tokenB, "Can't swap tokens");
        require(balanceOf(msg.sender) >= liquidity, "Not enough liquidity");
        require(ERC20(tokenA).balanceOf(address(this)) >= amountAMin, "Not enough tokens A");
        require(ERC20(tokenB).balanceOf(address(this)) >= amountBMin, "Not enough tokens B");

        uint _totalSupply = totalSupply();

        /// Burn user's liquidity tokens
        _burn(msg.sender, liquidity);

        /// Calculate amount of tokens to transfer
        uint withdrawnA = ERC20(tokenA).balanceOf(address(this)) * (liquidity / _totalSupply);
        uint withdrawnB = ERC20(tokenB).balanceOf(address(this)) * (liquidity / _totalSupply);

        /// Validate min amount of tokens
        require(withdrawnA >= amountAMin && withdrawnB >= amountBMin, "Not enough liquidity");

        /// Transfer tokens according to what user wants to remove from pool
        ERC20(tokenA).transfer(msg.sender, withdrawnA);
        ERC20(tokenB).transfer(msg.sender, withdrawnB);

        return(withdrawnA, withdrawnB);

    }

    /// @dev Swaps one token for another in exact amounts.
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts) {
        address __tokenA = _tokenA;
        address __tokenB = _tokenB;
        
        /// Validations
        require((path[0] == __tokenA || path[1] == __tokenA) && (path[0] == __tokenB || path[1]== __tokenB), "Can't swap this tokens");
        if(path[1] == __tokenB) {
            require(ERC20(__tokenB).balanceOf(address(this)) >= amountOutMin, "Not enough tokens B");
        } else {
            require(ERC20(__tokenA).balanceOf(address(this)) >= amountOutMin, "Not enough tokens A");
        }

        /// Approve and transfer amountIn
        ERC20(path[0]).approve(address(this), amountIn);
        ERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        /// Compute amount Out
        uint withdrawn;
        if(path[0] == __tokenA) {
            withdrawn = (amountIn * ERC20(__tokenB).balanceOf(address(this))) / (ERC20(__tokenA).balanceOf(address(this)) + amountIn);
        } else {
            withdrawn = (amountIn * ERC20(__tokenA).balanceOf(address(this))) / (ERC20(__tokenB).balanceOf(address(this)) + amountIn);
        }

        /// Check if withdrawn value is valid
        require(withdrawn >= amountOutMin, "Not enough tokens");

        /// Transfer amountOut
        ERC20(path[1]).transfer(msg.sender, withdrawn);

        uint[] memory returnValue = new uint[](2);
        returnValue[0] = amountIn;
        returnValue[1] = withdrawn;
        
        return(returnValue);
        
    }

    /// @dev Calculates current price of a token given another.
    function getPrice(address tokenA, address tokenB) external view returns (uint price) {
        address __tokenA = _tokenA;
        address __tokenB = _tokenB;

        /// Validations
        require(__tokenA != address(0) && __tokenB != address(0), "Must add liquidity first");
        require(__tokenA == tokenA && __tokenB == tokenB, "Can't swap those tokens!");

        return (ERC20(__tokenB).balanceOf(address(this)) * 1e18) / ERC20(__tokenA).balanceOf(address(this));

    }

    /// @dev Returns the amount of tokens someone could take out of this contract considering parameters.
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut) {
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    /// @dev Internal function to calculate square root.
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

}
