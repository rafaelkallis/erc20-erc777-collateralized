pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Collateralized.sol";

/**
 * @title ERC20Collateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract ERC20Collateralized is IERC20, Collateralized, Ownable {
  using SafeERC20 for IERC20;

  constructor(address baseToken, uint256 xNom, uint256 xDenom) public Collateralized(baseToken, xNom, xDenom) {}
  
  /** 
   * @dev See `Collateralized.lockAndMint`.
   */
  function lockAndMint(uint256 amount) public {
    IERC20(baseToken()).safeTransferFrom(msg.sender, address(this), _toBase(amount));
    _mintAdapter(amount);
    _increaseReserve(_toBase(amount));
    SafeERC20.safeTransfer(this, msg.sender, amount);
  }
  
  /** 
   * @dev See `Collateralized.burnAndUnlock`.
   */
  function burnAndUnlock(uint256 amount) public {
    SafeERC20.safeTransferFrom(this, msg.sender, address(this), amount);
    _decreaseReserve(_toBase(amount));
    _burnAdapter(amount);
    IERC20(baseToken()).safeTransfer(msg.sender, _toBase(amount));
  }

  function claimLostTokens() public onlyOwner {
    uint256 lostTokens = IERC20(baseToken()).balanceOf(address(this)).sub(reserve());
    IERC20(baseToken()).transfer(msg.sender, lostTokens);
  }

  function _mintAdapter(uint256 amount) internal;
  function _burnAdapter(uint256 amount) internal;
}
