### ERC20Collateralized

Extension of `ERC20` that adds a reserve of a foreign `ERC20`
token to collateralize the token. Useful for:
- creating a stable 2-way peg to any `ERC20` asset, or
- creating derivatives of any `ERC20` asset

The amount of tokens cannot exceed the amount of reserve tokens.
The set of accounts with the `MinterRole` have permission to 
increase the reserve and mint additional tokens. Every token-holder 
can burn tokens and receive an equivalued share of the reserve token.

The contract creator also can set a fixed exchange rate to the
reserve token to achieve arbitrary fractalization of value.
The value of tokens can never exceed the value of the reserve.

### Example

We create an ERC20 token collateralized by 
[CryptoFranc (XCHF)](https://etherscan.io/token/0xb4272071ecadd69d933adcd19ca99fe80664fc08),
such that 10 tokens are backed by 1 XCHF:

```
pragma solidity ^0.5.0;

import "erc20collateralized/contracts/ERC20Collateralized.sol";

contract MyCryptoFrancDerivative is ERC20Collateralized {
  constructor () ERC20Collateralized(address(0xb4272071ecadd69d933adcd19ca99fe80664fc08), 1, 10) public {}
}
```
