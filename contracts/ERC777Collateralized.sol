pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC777/IERC777Recipient.sol";
import "openzeppelin-solidity/contracts/token/ERC777/IERC777.sol";
import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./ICollateralized.sol";

/**
 * @title ERC777Collateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
contract ERC777Collateralized is IERC777, ICollateralized, IERC777Recipient, Ownable {
  using SafeMath for uint256;
  
  IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  IERC777 private _baseToken;
  uint256 private _reserve;
  uint256 private _xNom;
  uint256 private _xDenom;

  /**
   * token = (xNom / xDenom) * baseToken
   */
  constructor(address baseToken, uint256 xNom, uint256 xDenom) public {
    require(
      baseToken != address(0),
      "ERC777Collateralized: base token contract cannot be the 0 address"
    );
    require(
      _erc1820.getInterfaceImplementer(baseToken, keccak256("ERC777Token")) != address(0),
      "ERC777Collatelarized: base token contract is not an ERC777Token contract."
    );
    require(
      xNom > 0,
      "ERC777Collatelarized: nominator must be greater than 0."
    );
    require(
      xDenom > 0,
      "ERC777Collatelarized: denominator must be greater than 0."
    );

    _baseToken = IERC777(baseToken);
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
    _baseToken.operatorSend(
      msg.sender,
      address(this),
      _toBase(amount),
      "ERC777Collateralized: lock",
      ""
    ); 
    _mintAdapter(amount);
    _reserve = _reserve.add(_toBase(amount));
    this.send(
      msg.sender,
      amount,
      "ERC777Collateralized: mint"
    );
  }
  
  /**
   * @dev See `ICollateralized.burnAndUnlock`.
   */
  function burnAndUnlock(uint256 amount) public {
    _baseToken.operatorSend(
      msg.sender,
      address(this),
      amount,
      "ERC777Collateralized: burn",
      ""
    );
    _reserve = _reserve.sub(_toBase(amount));
    _burnAdapter(amount);
    _baseToken.send(msg.sender, _toBase(amount), "ERC777Collateralized: unlock");
  }
  
  function claimLostTokens() public onlyOwner {
    uint256 lostTokens = _baseToken.balanceOf(address(this)).sub(_reserve);
    _baseToken.send(msg.sender, lostTokens, "ERC777Collateralized: claim lost tokens");
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
