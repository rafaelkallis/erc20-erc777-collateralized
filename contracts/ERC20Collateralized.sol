pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./ICollateralized.sol";

/**
 * @title ERC20Collateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract ERC20Collateralized is IERC20, ICollateralized, Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  IERC20 private _baseToken;
  uint256 private _reserve;
  uint256 private _xNom;
  uint256 private _xDenom;

  /**
   * token = (xNom / xDenom) * baseToken
   */
  constructor(address baseToken, uint256 xNom, uint256 xDenom) public {
    require(
      baseToken != address(0),
      "ERC20Collateralized: base token contract cannot be the 0 address"
    );
    require(
      xNom > 0,
      "ERC20Collatelarized: nominator must be greater than 0."
    );
    require(
      xDenom > 0,
      "ERC20Collatelarized: denominator must be greater than 0."
    );

    _baseToken = IERC20(baseToken);
    _reserve = 0;
    _xNom = xNom;
    _xDenom = xDenom;
  }

  function baseToken() public view returns (address) {
    return address(_baseToken);
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
   * @dev See `ICollateralized.lockAndMint`.
   */
  function lockAndMint(uint256 amount) public {
    _baseToken.safeTransferFrom(msg.sender, address(this), _toBase(amount));
    _mintAdapter(amount);
    _reserve = _reserve.add(_toBase(amount));
    SafeERC20.safeTransfer(this, msg.sender, amount);
  }
  
  /** 
   * @dev See `ICollateralized.burnAndUnlock`.
   */
  function burnAndUnlock(uint256 amount) public {
    SafeERC20.safeTransferFrom(this, msg.sender, address(this), amount);
    _reserve = _reserve.sub(_toBase(amount));
    _burnAdapter(amount);
    _baseToken.safeTransfer(msg.sender, _toBase(amount));
  }

  function claimLostTokens() public onlyOwner {
    uint256 lostTokens = _baseToken.balanceOf(address(this)).sub(_reserve);
    _baseToken.transfer(msg.sender, lostTokens);
  }

  /**
   * baseAmount = amount * (1 / (xNom / xDenom))
   */
  function _toBase(uint256 amount) private view returns (uint256) {
    return amount.mul(_xDenom).div(_xNom);
  }

  function _mintAdapter(uint256 amount) internal;
  function _burnAdapter(uint256 amount) internal;
}
