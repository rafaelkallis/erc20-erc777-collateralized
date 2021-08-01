// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "./Collateralized.sol";

/**
 * @title ERC777Collateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
abstract contract ERC777Collateralized is Context, IERC777, IERC777Recipient, Collateralized, AccessControl {
  
  bytes32 public constant LOST_TOKEN_CLAIMER_ROLE = keccak256("LOST_TOKEN_CLAIMER_ROLE");
  IERC1820Registry private constant _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  constructor(address baseToken_, uint256 xNom_, uint256 xDenom_) Collateralized(baseToken_, xNom_, xDenom_) {
    require(
      _erc1820.getInterfaceImplementer(baseToken_, keccak256("ERC777Token")) != address(0),
      "ERC777Collatelarized: base token contract is not an ERC777Token contract."
    );
    
    _erc1820.setInterfaceImplementer(
      address(this),
      keccak256("ERC777TokensRecipient"),
      address(this)
    );
  }

  /**
   * @dev See `Collateralized.lockAndMint`.
   */
  function lockAndMint(uint256 amount) external virtual override {
    IERC777(baseToken()).operatorSend(
      _msgSender(),
      address(this),
      _toBase(amount),
      "ERC777Collateralized: lock",
      ""
    ); 
    _increaseReserve(_toBase(amount));
    _mintAdapter(_msgSender(), amount, "ERC777Collateralized: mint");
  }
  
  /**
   * @dev See `Collateralized.burnAndUnlock`.
   */
  function burnAndUnlock(uint256 amount) external virtual override {
    this.operatorBurn(
      _msgSender(),
      amount,
      "ERC777Collateralized: burn",
      ""
    );
    _decreaseReserve(_toBase(amount));
    IERC777(baseToken()).send(
      _msgSender(), 
      _toBase(amount), 
      "ERC777Collateralized: unlock"
    );
  }
  
  function claimLostTokens() public onlyRole(LOST_TOKEN_CLAIMER_ROLE) {
    uint256 lostTokens = IERC777(baseToken()).balanceOf(address(this)) - reserve();
    IERC777(baseToken()).send(
      _msgSender(), 
      lostTokens, 
      "ERC777Collateralized: claim lost tokens"
    );
  }
  
  function tokensReceived(
    address operator,
    address,
    address,
    uint,
    bytes memory,
    bytes memory
  ) external view override {
    require(
      operator == address(this),
      "ERC777Collateralized: tokens can be received only if they were sent by this contract" 
    );
  }

  function _mintAdapter(address to, uint256 amount, bytes memory data) internal virtual;
}
