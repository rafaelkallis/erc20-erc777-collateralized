// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ERC777MintableMock is ERC777, AccessControl {

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor() ERC777("", "", new address[](0)) {
    _setupRole(MINTER_ROLE, _msgSender());
  }

  function mint(address account, uint256 amount) external onlyRole(MINTER_ROLE) {
      _mint(account, amount, "", "");
  }
}
