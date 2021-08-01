// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ERC20MintableMock is ERC20, AccessControl {

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor() ERC20("", "") {
    _setupRole(MINTER_ROLE, _msgSender());
  }

  function mint(address account, uint256 amount) external onlyRole(MINTER_ROLE) {
      _mint(account, amount);
  }
}
