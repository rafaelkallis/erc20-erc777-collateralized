/**
 * @file erc20 collateralized tests
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */

const ERC20Collateralized = artifacts.require("ERC20Collateralized");
const ERC20Mintable = artifacts.require("ERC20Mintable");

contract("ERC20Collateralized", (accounts) => {

  const baseTokenOwner = accounts[1];
  const collTokenOwner = accounts[2];

  let baseToken;
  let collToken;

  beforeEach(async () => {
    baseToken = await ERC20Mintable.new(
      { from: baseTokenOwner }
    );
    collToken = await ERC20Collateralized.new(
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
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(1000, await baseToken.balanceOf(collTokenOwner));
    assert.equal(0, await baseToken.balanceOf(collToken.address));
    
    assert.equal(0, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
  });

  it("mint", async () => {
    const user = accounts[3];
    assert.equal(0, await collToken.balanceOf(user));
    assert.equal(0, await baseToken.balanceOf(user));

    await collToken.mint(
      user,
      250 * 1000,
      { from: collTokenOwner }
    );

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(750, await baseToken.balanceOf(collTokenOwner));
    assert.equal(0, await baseToken.balanceOf(user));
    assert.equal(250, await baseToken.balanceOf(collToken.address));

    assert.equal(250 * 1000, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(250 * 1000, await collToken.balanceOf(user));
  });
  
  it("burn", async () => {
    const user = accounts[3];
    assert.equal(0, await collToken.balanceOf(user));
    assert.equal(0, await baseToken.balanceOf(user));

    await collToken.mint(
      user,
      500 * 1000,
      { from: collTokenOwner }
    );
    
    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(500, await baseToken.balanceOf(collTokenOwner));
    assert.equal(0, await baseToken.balanceOf(user));
    assert.equal(500, await baseToken.balanceOf(collToken.address));

    assert.equal(500 * 1000, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(500 * 1000, await collToken.balanceOf(user));

    await collToken.burn(
      250 * 1000,
      { from: user }
    );
    
    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(500, await baseToken.balanceOf(collTokenOwner));
    assert.equal(0, await baseToken.balanceOf(user));
    assert.equal(500, await baseToken.balanceOf(collToken.address));
    assert.equal(250, await baseToken.allowance(collToken.address, user));

    assert.equal(250 * 1000, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(250 * 1000, await collToken.balanceOf(user));

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

    assert.equal(250 * 1000, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(250 * 1000, await collToken.balanceOf(user));
  });

  it("burnFrom", async () => {
    const user1 = accounts[3];
    assert.equal(0, await collToken.balanceOf(user1));
    assert.equal(0, await baseToken.balanceOf(user1));
    const user2 = accounts[4];
    assert.equal(0, await collToken.balanceOf(user2));
    assert.equal(0, await baseToken.balanceOf(user2));
    
    await collToken.mint(
      user1,
      500 * 1000,
      { from: collTokenOwner }
    );
    await collToken.approve(
      user2,
      250 * 1000,
      { from: user1 }
    );
    
    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(500, await baseToken.balanceOf(collTokenOwner));
    assert.equal(0, await baseToken.balanceOf(user1));
    assert.equal(0, await baseToken.balanceOf(user2));
    assert.equal(500, await baseToken.balanceOf(collToken.address));

    assert.equal(500 * 1000, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(500 * 1000, await collToken.balanceOf(user1));
    assert.equal(0, await collToken.balanceOf(user2));

    await collToken.burnFrom(
      user1,
      250 * 1000,
      { from: user2 }
    );

    assert.equal(250 * 1000, await collToken.totalSupply());
    assert.equal(0, await collToken.balanceOf(baseTokenOwner));
    assert.equal(0, await collToken.balanceOf(collTokenOwner));
    assert.equal(250 * 1000, await collToken.balanceOf(user1));
    assert.equal(250 * 1000, await collToken.balanceOf(user1));
    
    await baseToken.transferFrom(
      collToken.address,
      user2,
      250,
      { from: user1 }
    );

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(0, await baseToken.balanceOf(baseTokenOwner));
    assert.equal(500, await baseToken.balanceOf(collTokenOwner));
    assert.equal(0, await baseToken.balanceOf(user1));
    assert.equal(250, await baseToken.balanceOf(user2));
    assert.equal(250, await baseToken.balanceOf(collToken.address));
  });
});
