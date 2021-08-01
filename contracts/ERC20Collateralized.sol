// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./Collateralized.sol";

/**
 * @title ERC20Collateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
abstract contract ERC20Collateralized is Context, IERC20, Collateralized, AccessControl {
  using SafeERC20 for IERC20;
  
  bytes32 public constant LOST_TOKEN_CLAIMER_ROLE = keccak256("LOST_TOKEN_CLAIMER_ROLE");

  constructor(address baseToken_, uint256 xNom_, uint256 xDenom_) Collateralized(baseToken_, xNom_, xDenom_) {}
  
  /** 
   * @dev See `Collateralized.lockAndMint`.
   */
  function lockAndMint(uint256 amount) external virtual override {
    IERC20(baseToken()).safeTransferFrom(_msgSender(), address(this), _toBase(amount));
    _mintAdapter(_msgSender(), amount);
    _increaseReserve(_toBase(amount));
  }
  
  /** 
   * @dev See `Collateralized.burnAndUnlock`.
   */
  function burnAndUnlock(uint256 amount) external virtual override {
    _burnAdapter(_msgSender(), amount);
    _decreaseReserve(_toBase(amount));
    IERC20(baseToken()).safeTransfer(_msgSender(), _toBase(amount));
  }

  function claimLostTokens() public onlyRole(LOST_TOKEN_CLAIMER_ROLE) {
    uint256 lostTokens = IERC20(baseToken()).balanceOf(address(this)) - reserve();
    IERC20(baseToken()).transfer(_msgSender(), lostTokens);
  }

  function _mintAdapter(address to, uint256 amount) internal virtual;
  function _burnAdapter(address from, uint256 amount) internal virtual;
}
