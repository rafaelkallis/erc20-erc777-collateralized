## ERC20Collateralized

Extension of `ERC20` that adds a reserve of a foreign `ERC20`
token to collateralize the token. 

> :warning: **This code has not been reviewed or audited.** :warning:

Useful for:
- creating a stable 2-way peg to any `ERC20` asset, or
- creating derivatives of any `ERC20` asset

The amount of tokens cannot exceed the amount of reserve tokens.
The set of accounts with the `MinterRole` have permission to 
increase the reserve and mint additional tokens. Every token-holder 
can burn tokens and receive an equivalued share of the reserve token.

The contract creator also can set a fixed exchange rate to the
reserve token to achieve arbitrary fractalization of value.
The value of tokens can never exceed the value of the reserve.

### Usage

We create an ERC20 token collateralized by 
[CryptoFranc (XCHF)](https://etherscan.io/token/0xb4272071ecadd69d933adcd19ca99fe80664fc08),
such that 10 tokens are backed by 1 XCHF:

```
pragma solidity ^0.5.0;

import "erc20collateralized/contracts/ERC20Collateralized.sol";

contract MyCryptoFrancDerivative is ERC20, ERC20Collateralized {
  constructor () ERC20Collateralized(address(0xb4272071ecadd69d933adcd19ca99fe80664fc08), 1, 10) public {}
}
```

Given the local user is the contract owner (has the `MinterRole`)
we can interact with the contract like so:

```js
const owner = "0x...";
const user = "0x...";
const cryptoFranc = await CryptoFranc.at("0xB4272071eCAdd69d933AdcD19cA99fe80664fc08");
const myCryptoFrancDerivative = await MyCryptoFrancDerivative.at("0x...");

// suppose "owner" has 500 XCHF
assert.equals(await cryptoFranc.balanceOf(owner), 500);
assert.equals(await cryptoFranc.balanceOf(user), 0);
assert.equals(await myCryptoFrancDerivative.balanceOf(owner), 0);
assert.equals(await myCryptoFrancDerivative.balanceOf(user), 0);

// approve 500 XCHF to the MyCryptoFrancDerivative contract
await cryptoFranc.approve(
  myCryptoFrancDerivative.address,
  500,
  { from: owner }
);

// mint 5000 XCHF-derivatives and send to "user"
await myCryptoFrancDerivative.mint(
  user, 
  500 * 10,
  { from: owner }
);

assert.equals(await cryptoFranc.balanceOf(owner), 0);
assert.equals(await cryptoFranc.balanceOf(user), 0);
// "myCryptoFrancDerivative" contract owns 500 XCHF
assert.equals(await cryptoFranc.balanceOf(myCryptoFrancDerivative.address), 500);
assert.equals(await myCryptoFrancDerivative.balanceOf(owner), 0);
// "user" owns 5000 XCHF-derivatives
assert.equals(await myCryptoFrancDerivative.balanceOf(user), 5000);

// "user" burns 5000 XCHF-derivatives and receives 500 XCHF in return
await myCryptoFrancDerivative.burn(
  500 * 10,
  { from: user }
);

assert.equals(await cryptoFranc.balanceOf(owner), 0);
// "user" owns 500 XCHF
assert.equals(await cryptoFranc.balanceOf(user), 500);
assert.equals(await cryptoFranc.balanceOf(myCryptoFrancDerivative.address), 0);
assert.equals(await myCryptoFrancDerivative.balanceOf(owner), 0);
assert.equals(await myCryptoFrancDerivative.balanceOf(user), 0);
```
