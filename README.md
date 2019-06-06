#### work in progress!

### ERC20Collateralized

Extension of `ERC20` that adds a reserve of a foreign `ERC20`
token to collateralize the token. The amount of tokens cannot
exceed the amount of reserve tokens. The set of accounts with 
the `MinterRole` have permission to increase the reserve and 
mint additional tokens. Every token-holder can burn tokens and
receive an equivalued share of the reserve token.
