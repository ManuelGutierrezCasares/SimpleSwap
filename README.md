# Manuel Gutierrez Casares's Ethereum SimpleSwap

## Usage:
- This contract is fixated to use two tokens only; these are set when the first user adds liquidity to the management pool.
- This contract allows the user to do the following:
    - Add Liquidity to the management pool.
    - Remove Liquidity from the management pool.
    - Swap tokens.
    - Get Price of a token based on another.
    - Get amount of tokens that the user would receive.

## Variables:
- _tokenA: Stores the address of the first selected token.
- _tokenB: Stores the address of the first selected token.

## Functions:
- addLiquidity: Adds liquidity to the pool taking tokens from the user.
- removeLiquidity: Removes liquidity from the management pool and user cashes out tokens accordingly.
- swapExactTokensForTokens: Swaps one token for another in exact amounts.
- getPrice: Computes current price of a token given another.
- getAmountOut: Computes the amount of tokens someone could take out of this contract considering parameters.
- sqrt: Internal function to compute square root of a number.

## Events:
- None ATM.
