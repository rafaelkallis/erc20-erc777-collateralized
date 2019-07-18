pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC777/ERC777.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";

contract ERC777Mintable is ERC777, MinterRole {

  function mint(address account, uint256 amount) public onlyMinter {
      _mint(address(this), account, amount, "", "");
  }
}
