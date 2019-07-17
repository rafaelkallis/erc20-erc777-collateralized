pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "../ERC20Collateralized.sol";

/**
 * @title ERC20CollateralizedMock
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract ERC20CollateralizedMock is ERC20, ERC20Collateralized {

  constructor(address baseToken, uint256 xNom, uint256 xDenom) public ERC20Collateralized(baseToken, xNom, xDenom) {}

  function _mintAdapter(uint256 amount) internal {
    _mint(address(this), amount);
  }
  
  function _burnAdapter(uint256 amount) internal {
    _burn(address(this), amount);
  }
}
