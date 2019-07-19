pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC777/ERC777.sol";
import "../ERC777Collateralized.sol";

/**
 * @title ERC777CollateralizedMock
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract ERC777CollateralizedMock is ERC777("", "", new address[](0)), ERC777Collateralized {

  constructor(address baseToken, uint256 xNom, uint256 xDenom) public ERC777Collateralized(baseToken, xNom, xDenom) {}

  function _mintAdapter(uint256 amount) internal {
    _mint(address(this), address(this), amount, "", "");
  }
}
