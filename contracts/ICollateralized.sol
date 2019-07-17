pragma solidity ^0.5.0;

/**
 * @title ICollateralized
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */
interface ICollateralized {

  /** 
   * @dev Mints `amount` tokens and assigns them to `recipient`,
   * increasing the total supply. Tokens can only be created if
   * the caller has a sufficient allowance of `_baseToken`.
   */
  function lockAndMint(uint256 amount) external;
  
  /**
   * @dev Burns `amount` tokens from `sender`, reducing the
   * total supply. `recipient` is granted the equivaled amount of `_baseToken`.
   */
  function burnAndUnlock(uint256 amount) external;
}
