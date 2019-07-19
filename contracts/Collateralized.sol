pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Collateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract Collateralized {
  using SafeMath for uint256;
  
  address private _baseToken;
  uint256 private _reserve;
  uint256 private _xNom;
  uint256 private _xDenom;
  
  /**
   * token = (xNom / xDenom) * baseToken
   */
  constructor(address baseToken, uint256 xNom, uint256 xDenom) public {
    require(
      baseToken != address(0),
      "Collateralized: base token contract cannot be the 0 address"
    );
    require(
      xNom > 0,
      "ERC777Collatelarized: nominator must be greater than 0."
    );
    require(
      xDenom > 0,
      "ERC777Collatelarized: denominator must be greater than 0."
    );
    
    _baseToken = baseToken;
    _reserve = 0;
    _xNom = xNom;
    _xDenom = xDenom;
  }

  /** 
   * @dev Locks tokens of the collateralized asset and mints 
   * `amount` tokens, increasing the total supply. 
   * Tokens can only be created if the message sender has
   * sufficient tokens of the base token, as determined by the
   * exchange rate.
   */
  function lockAndMint(uint256 amount) public;
  
  /**
   * @dev Burns `amount` tokens from `sender`, reducing the
   * total supply. `recipient` is granted the equivaled amount of `_baseToken`.
   */
  function burnAndUnlock(uint256 amount) public;

  function baseToken() public view returns (address) {
    return _baseToken;
  }
  
  function reserve() public view returns (uint256) {
    return _reserve;
  }
  
  function xNom() public view returns (uint256) {
    return _xNom;
  }
  
  function xDenom() public view returns (uint256) {
    return _xDenom;
  }

  /**
   * baseAmount = amount * (1 / (xNom / xDenom))
   */
  function _toBase(uint256 amount) internal view returns (uint256) {
    return amount.mul(_xDenom).div(_xNom);
  }

  function _increaseReserve(uint256 amount) internal {
    _reserve = _reserve.add(amount);
  }

  function _decreaseReserve(uint256 amount) internal {
    _reserve = _reserve.sub(amount);
  }
}
