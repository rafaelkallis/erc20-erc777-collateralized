// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "../ERC777Collateralized.sol";

/**
 * @title ERC777CollateralizedMock
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract ERC777CollateralizedMock is ERC777, ERC777Collateralized {

  constructor(address baseToken, uint256 xNom, uint256 xDenom) 
    ERC777("", "", new address[](0))
    ERC777Collateralized(baseToken, xNom, xDenom) {}

  function _mintAdapter(address to, uint256 amount, bytes memory data) internal virtual override(ERC777Collateralized) {
    _mint(to, amount, data, "");
  }

  function totalSupply() public view virtual override(IERC777, ERC777) returns (uint256) {
      return super.totalSupply();
  }

  function balanceOf(address tokenHolder) public view virtual override(IERC777, ERC777) returns (uint256) {
    return super.balanceOf(tokenHolder);
  }
}
