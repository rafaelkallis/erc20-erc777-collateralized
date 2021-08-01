// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../ERC20Collateralized.sol";

/**
 * @title ERC20CollateralizedMock
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract ERC20CollateralizedMock is ERC20, ERC20Collateralized {

  constructor(address baseToken_, uint256 xNom_, uint256 xDenom_) 
    ERC20("", "")
    ERC20Collateralized(baseToken_, xNom_, xDenom_) {}

  function _mintAdapter(address to, uint256 amount) internal virtual override {
    _mint(to, amount);
  }
  
  function _burnAdapter(address from, uint256 amount) internal virtual override {
    _burn(from, amount);
  }
}
