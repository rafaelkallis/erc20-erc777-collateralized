// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Collateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
abstract contract Collateralized {
  
  address private _baseToken;
  uint256 private _reserve;
  uint256 private _xNom;
  uint256 private _xDenom;
  
  /**
   * token = (xNom / xDenom) * baseToken
   */
  constructor(address baseToken_, uint256 xNom_, uint256 xDenom_) {
    require(
      baseToken_ != address(0),
      "Collateralized: base token contract cannot be the 0 address"
    );
    require(
      xNom_ > 0,
      "Collatelarized: nominator must be greater than 0"
    );
    require(
      xDenom_ > 0,
      "Collatelarized: denominator must be greater than 0"
    );
    
    _baseToken = baseToken_;
    _reserve = 0;
    _xNom = xNom_;
    _xDenom = xDenom_;
  }

  /** 
   * @dev Locks tokens of the collateralized asset and mints 
   * `amount` tokens, increasing the total supply. 
   * Tokens can only be created if the message sender has
   * sufficient tokens of the base token, as determined by the
   * exchange rate.
   */
  function lockAndMint(uint256 amount) external virtual;
  
  /**
   * @dev Burns `amount` tokens from `sender`, reducing the
   * total supply. `recipient` is granted the equivaled amount of `_baseToken`.
   */
  function burnAndUnlock(uint256 amount) external virtual;

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
    return amount * _xDenom / _xNom;
  }

  function _increaseReserve(uint256 amount) internal {
    _reserve += amount;
  }

  function _decreaseReserve(uint256 amount) internal {
    _reserve -= amount;
  }
}
