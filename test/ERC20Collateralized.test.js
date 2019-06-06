/**
 * @file erc20 collateralized tests
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */

const ERC20Collateralized = artifacts.require("ERC20Collateralized");
const ERC20Mintable = artifacts.require("ERC20Mintable");

contract("ERC20Collateralized", (accounts) => {

  const baseTokenOwner = accounts[1];
  const collTokenOwner = accounts[2];
  const user = accounts[3];

  let baseToken;
  let collToken;

  beforeEach(async () => {
    baseToken = await ERC20Mintable.new(
      { from: baseTokenOwner }
    );
    collToken = await ERC20Collateralized.new(
      baseToken.address,
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
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(1000, await baseToken.balanceOf(collTokenOwner));
    assert.equal(0, await baseToken.balanceOf(user));
    assert.equal(0, await baseToken.balanceOf(collToken.address));
    
    assert.equal(0, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(0, await collToken.balanceOf(user));
  });

  it("mint", async () => {
    await collToken.mint(
      user,
      250,
      { from: collTokenOwner }
    );

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(750, await baseToken.balanceOf(collTokenOwner));
    assert.equal(0, await baseToken.balanceOf(user));
    assert.equal(250, await baseToken.balanceOf(collToken.address));

    assert.equal(250, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(250, await collToken.balanceOf(user));
  });
  
  it("burn", async () => {
    await collToken.mint(
      user,
      500,
      { from: collTokenOwner }
    );

    await collToken.burn(
      250,
      { from: user }
    );
    await baseToken.transferFrom(
      collToken.address,
      user,
      250,
      { from: user }
    );

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(500, await baseToken.balanceOf(collTokenOwner));
    assert.equal(250, await baseToken.balanceOf(user));
    assert.equal(250, await baseToken.balanceOf(collToken.address));

    assert.equal(250, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(250, await collToken.balanceOf(user));
  });

  it("burnFrom", async () => {});
});
