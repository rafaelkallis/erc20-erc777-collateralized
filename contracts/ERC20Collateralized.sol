pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title ERC20Collateralized
 */
contract ERC20Collateralized is ERC20Mintable, ERC20Burnable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  IERC20 baseToken;

  uint256 xNom;
  uint256 xDenom;

  /**
   * token = (xNom / xDenom) * baseToken
   */
  constructor(IERC20 _baseToken, uint256 _xNom, uint256 _xDenom) public {
    require(address(_baseToken) != address(0));
    require(_xNom > 0);
    require(_xDenom > 0);
    baseToken = _baseToken;
    xNom = _xNom;
    xDenom = _xDenom;
  }
  
  /** 
   * @dev Creates `amount` tokens and assigns them to `to`,
   * increasing the total supply. Tokens can only be created if
   * the caller has a sufficient allowance of `baseToken`.
   * 
   *
   * Emits a `Transfer` event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   * - `amount` must be <= baseToken.allowance(msg.sender, address(this)).
   */
  function mint(address to, uint256 amount) public onlyMinter returns (bool) {
    baseToken.safeTransferFrom(msg.sender, address(this), _toBase(amount));
    return super.mint(to, amount);
  }

  /**
   * @dev Destoys `amount` tokens from the callee, reducing the
   * total supply. The callee is given `amount` tokens of `baseToken`.
   *
   * Emits a `Transfer` event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `amount` must be <= this.balanceOf(amount).
   */
  function burn(uint256 amount) public {
    super.burn(amount);
    baseToken.safeApprove(msg.sender, _toBase(amount));
  }
  
  /**
   * @dev Destoys `amount` tokens from `account`, reducing the
   * total supply. `account` is given `amount` tokens of `baseToken`.
   *
   * Emits a `Transfer` event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `amount` must be <= this.balanceOf(account).
   */
  function burnFrom(address account, uint256 amount) public {
    super.burnFrom(account, amount);
    baseToken.safeApprove(account, _toBase(amount));
  }

  /**
   * baseAmount = amount * (1 / (xNom / xDenom))
   */
  function _toBase(uint256 amount) internal view returns (uint256) {
    return amount.mul(xDenom).div(xNom);
  }
  
  /**
   * amount = baseAmount * (xNom / xDenom)
   */
  function _fromBase(uint256 baseAmount) internal view returns (uint256) {
    return baseAmount.mul(xNom).div(xDenom);
  }
}
