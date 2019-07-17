/**
 * @file erc20collateralized tests
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */

const ERC20CollateralizedMock = artifacts.require("ERC20CollateralizedMock");
const ERC20Mintable = artifacts.require("ERC20Mintable");

contract("ERC20Collateralized", (accounts) => {

  const baseTokenOwner = accounts[1];
  const collTokenOwner = accounts[2];

  let baseToken;
  let collToken;

  beforeEach(async () => {
    baseToken = await ERC20Mintable.new({ from: baseTokenOwner });
    collToken = await ERC20CollateralizedMock.new(
      baseToken.address,
      1000,
      1,
      { from: collTokenOwner }
    );
    await baseToken.mint(
      collTokenOwner, 
      1000, 
      { from: baseTokenOwner }
    );
    await baseToken.approve(
      collToken.address,
      500,
      { from: collTokenOwner }
    );

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(1000, await baseToken.balanceOf(collTokenOwner));
    
    assert.equal(0, await collToken.totalSupply());
  });

  it("lockAndMint", async () => {
    await collToken.lockAndMint(250 * 1000, { from: collTokenOwner });

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(750, await baseToken.balanceOf(collTokenOwner));
    assert.equal(250, await baseToken.balanceOf(collToken.address));

    assert.equal(250 * 1000, await collToken.totalSupply());
    assert.equal(250 * 1000, await collToken.balanceOf(collTokenOwner));
  });
  
  it("burnAndUnlock", async () => {
    await collToken.lockAndMint(500 * 1000, { from: collTokenOwner });
    
    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(500, await baseToken.balanceOf(collTokenOwner));
    assert.equal(500, await baseToken.balanceOf(collToken.address));

    assert.equal(500 * 1000, await collToken.totalSupply());
    assert.equal(500 * 1000, await collToken.balanceOf(collTokenOwner));

    await collToken.approve(
      collToken.address,
      250 * 1000,
      { from: collTokenOwner }
    );
    await collToken.burnAndUnlock(250 * 1000, { from: collTokenOwner });

    assert.equal(250 * 1000, await collToken.totalSupply());
    assert.equal(250 * 1000, await collToken.balanceOf(collTokenOwner));

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(750, await baseToken.balanceOf(collTokenOwner));
    assert.equal(250, await baseToken.balanceOf(collToken.address));
  });
});
