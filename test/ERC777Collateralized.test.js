/**
 * @file erc777collateralized tests
 * @author Rafael Kallis <rk@rafaelkallis.com>
 */

const { singletons } = require("@openzeppelin/test-helpers");

const ERC777CollateralizedMock = artifacts.require("ERC777CollateralizedMock");
const ERC777MintableMock = artifacts.require("ERC777MintableMock");

contract("ERC777Collateralized", ([_, registryFunder, baseTokenOwner, collTokenOwner, user]) => {

  let erc1820;
  let baseToken;
  let collToken;

  beforeEach(async () => {
    erc1820 = await singletons.ERC1820Registry(registryFunder);
    baseToken = await ERC777MintableMock.new({ from: baseTokenOwner });
    collToken = await ERC777CollateralizedMock.new(
      baseToken.address,
      1000,
      1,
      { from: collTokenOwner }
    );
    await baseToken.mint(
      user, 
      1000, 
      { from: baseTokenOwner }
    );

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(1000, await baseToken.balanceOf(user));
    
    assert.equal(0, await collToken.totalSupply());
  });

  it("lockAndMint", async () => {
    await baseToken.authorizeOperator(collToken.address, { from: user });
    await collToken.lockAndMint(250 * 1000, { from: user });

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(750, await baseToken.balanceOf(user));
    assert.equal(250, await baseToken.balanceOf(collToken.address));

    assert.equal(250 * 1000, await collToken.totalSupply());
    assert.equal(250 * 1000, await collToken.balanceOf(user));
  });
  
  it("burnAndUnlock", async () => {
    await baseToken.authorizeOperator(collToken.address, { from: user });
    await collToken.lockAndMint(500 * 1000, { from: user });
    
    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(500, await baseToken.balanceOf(user));
    assert.equal(500, await baseToken.balanceOf(collToken.address));

    assert.equal(500 * 1000, await collToken.totalSupply());
    assert.equal(500 * 1000, await collToken.balanceOf(user));

    await collToken.authorizeOperator(collToken.address, { from: user });
    await collToken.burnAndUnlock(250 * 1000, { from: user });

    assert.equal(250 * 1000, await collToken.totalSupply());
    assert.equal(250 * 1000, await collToken.balanceOf(user));

    assert.equal(1000, await baseToken.totalSupply());
    assert.equal(750, await baseToken.balanceOf(user));
    assert.equal(250, await baseToken.balanceOf(collToken.address));
  });
});
