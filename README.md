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

### ERC20 Usage

We create an ERC20 token collateralized by 
[CryptoFranc (XCHF)](https://etherscan.io/token/0xb4272071ecadd69d933adcd19ca99fe80664fc08),
such that 10 tokens are backed by 1 XCHF:

```
pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "erc20-erc777-collateralized/contracts/ERC20Collateralized.sol";

contract MyCryptoFrancDerivative is ERC20, ERC20Collateralized(address(0xb4272071ecadd69d933adcd19ca99fe80664fc08), 1, 10) {
  
  function _mintAdapter(uint256 amount) internal {
    _mint(address(this), amount);
  }
  
  function _burnAdapter(uint256 amount) internal {
    _burn(address(this), amount);
  }
}
```

We can interact with the contract like so:

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

// lock 500 XCHF and mint 5000 XCHF-derivatives
await myCryptoFrancDerivative.lockAndMint(
  500 * 10,
  { from: owner }
);

// transfer 5000 XCHF-derivatives to "user"
await myCryptoFrancDerivative.transfer(
  user,
  500 * 10
  { from: owner }
);

assert.equals(await cryptoFranc.balanceOf(owner), 0);
assert.equals(await cryptoFranc.balanceOf(user), 0);
// "myCryptoFrancDerivative" contract has 500 XCHF in its reserve
assert.equals(await cryptoFranc.balanceOf(myCryptoFrancDerivative.address), 500);
assert.equals(await myCryptoFrancDerivative.balanceOf(owner), 0);
// "user" owns 5000 XCHF-derivatives
assert.equals(await myCryptoFrancDerivative.balanceOf(user), 5000);

// approve 5000 XCHF-derivatives to the MyCryptoFrancDerivative contract
await myCryptoFrancDerivative.approve(
  myCryptoFrancDerivative.address,
  5000,
  { from: user }
);

// "user" burns 5000 XCHF-derivatives and unlocks (receives) 500 XCHF in return
await myCryptoFrancDerivative.burnAndUnlock(
  500 * 10,
  { from: user }
);

assert.equals(await cryptoFranc.balanceOf(owner), 0);
// "user" owns 500 XCHF
assert.equals(await cryptoFranc.balanceOf(user), 500);
// "myCryptoFrancDerivative" contract has 0 XCHF in its reserve
assert.equals(await cryptoFranc.balanceOf(myCryptoFrancDerivative.address), 0);
assert.equals(await myCryptoFrancDerivative.balanceOf(owner), 0);
assert.equals(await myCryptoFrancDerivative.balanceOf(user), 0);
```

### ERC777 Usage

This example demonstrate the same process as the example above.
We create an ERC777 token collateralized by a base token (BASE).
such that 10 tokens are backed by 1 BASE:

```
pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC777/ERC777.sol";
import "erc20-erc777-collateralized/contracts/ERC777Collateralized.sol";

contract MyDerivative is ERC777, ERC777Collateralized(address(0x...), 1, 10) {
  
  function _mintAdapter(uint256 amount) internal {
    _mint(address(this), address(this), amount);
  }
}
```

We can interact with the contract like so:

```js
const owner = "0x...";
const user = "0x...";
const baseToken = await MyBaseToken.at("0x...");
const myDerivative = await MyDerivative.at("0x...");

// suppose "owner" has 500 BASE
assert.equals(await baseToken.balanceOf(owner), 500);
assert.equals(await baseToken.balanceOf(user), 0);
assert.equals(await myDerivative.balanceOf(owner), 0);
assert.equals(await myDerivative.balanceOf(user), 0);

// authorize the MyDerivative contract to act as an operator on behalf of "owner" on MyBaseToken
await baseToken.authorizeOperator(
  myDerivative.address,
  { from: owner }
);

// lock 500 BASE and mint 5000 derivatives
await myDerivative.lockAndMint(
  500 * 10,
  { from: owner }
);

// transfer 5000 derivatives to "user"
await myDerivative.send(
  user,
  500 * 10,
  "",
  { from: owner }
);

assert.equals(await baseToken.balanceOf(owner), 0);
assert.equals(await baseToken.balanceOf(user), 0);
// "myDerivative" contract has 500 BASE in its reserve
assert.equals(await baseToken.balanceOf(myDerivative.address), 500);
assert.equals(await myDerivative.balanceOf(owner), 0);
// "user" owns 5000 derivatives
assert.equals(await myDerivative.balanceOf(user), 5000);

// authorize the MyDerivative contract to act as an operator on behalf of "owner" on MyDerivative
await myDerivative.authorizeOperator(
  myDerivative.address,
  { from: user }
);

// "user" burns 5000 derivatives and unlocks (receives) 500 BASE in return
await myDerivative.burnAndUnlock(
  500 * 10,
  { from: user }
);

assert.equals(await baseToken.balanceOf(owner), 0);
// "user" owns 500 BASE
assert.equals(await baseToken.balanceOf(user), 500);
// "myDerivative" contract has 0 BASE in its reserve
assert.equals(await baseToken.balanceOf(myDerivative.address), 0);
assert.equals(await myDerivative.balanceOf(owner), 0);
assert.equals(await myDerivative.balanceOf(user), 0);
```
