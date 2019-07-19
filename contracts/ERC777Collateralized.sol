pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC777/IERC777Recipient.sol";
import "openzeppelin-solidity/contracts/token/ERC777/IERC777.sol";
import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Collateralized.sol";

/**
 * @title ERC777Collateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract ERC777Collateralized is IERC777, Collateralized, IERC777Recipient, Ownable {
  
  IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  constructor(address baseToken, uint256 xNom, uint256 xDenom) public Collateralized(baseToken, xNom, xDenom) {
    require(
      _erc1820.getInterfaceImplementer(baseToken, keccak256("ERC777Token")) != address(0),
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
  function lockAndMint(uint256 amount) public {
    IERC777(baseToken()).operatorSend(
      msg.sender,
      address(this),
      _toBase(amount),
      "ERC777Collateralized: lock",
      ""
    ); 
    _increaseReserve(_toBase(amount));
    _mintAdapter(amount);
    this.send(
      msg.sender,
      amount,
      "ERC777Collateralized: mint"
    );
  }
  
  /**
   * @dev See `Collateralized.burnAndUnlock`.
   */
  function burnAndUnlock(uint256 amount) public {
    this.operatorBurn(
      msg.sender,
      amount,
      "ERC777Collateralized: burn",
      ""
    );
    _decreaseReserve(_toBase(amount));
    IERC777(baseToken()).send(msg.sender, _toBase(amount), "ERC777Collateralized: unlock");
  }
  
  function claimLostTokens() public onlyOwner {
    uint256 lostTokens = IERC777(baseToken()).balanceOf(address(this)).sub(reserve());
    IERC777(baseToken()).send(msg.sender, lostTokens, "ERC777Collateralized: claim lost tokens");
  }
  
  function tokensReceived(
    address operator,
    address,
    address,
    uint,
    bytes memory,
    bytes memory
  ) public {
    require(
      operator == address(this),
      "ERC777Collateralized: tokens can be received only if they were sent by this contract." 
    );
  }

  function _mintAdapter(uint256 amount) internal;
}
