const {time, loadFixture} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {anyValue} = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect} = require("chai");
const {ZeroAddress} = require("ethers");

describe("ERC20 CBDC", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployTokenFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const contract = await ethers.getContractFactory("MockERC20CBDC");
    const token = await contract.deploy("United States dollar", "USD");

    return {token, owner, otherAccount};
  }

  describe("Transfers", function () {
    it("Should mint the funds to the owner", async function () {
      const {token, owner} = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      await token.mint(address, 1000n);
      expect(await token.balanceOf(address)).to.equal(1000n);
    });

    it("Should transfer the funds from the account to other account", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      const otherAddress = await otherAccount.getAddress();
      let tx = await token.mint(address, 1000n);
      tx = await tx.wait();
      await token.transfer(otherAddress, 1000n);
      expect(await token.balanceOf(otherAddress)).to.equal(1000n);
    });

    it("Should transferFrom the funds from the account to other account", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      const otherAddress = await otherAccount.getAddress();
      await token.mint(address, 1000n);
      await token.connect(owner).approve(otherAddress, 1000n);
      expect(await token.allowance(address, otherAddress)).to.equal(1000n);
      await token.connect(otherAccount).transferFrom(address, otherAddress, 1000n);
      expect(await token.balanceOf(otherAddress)).to.equal(1000n);
    });
  });

  // extensions
  // transfer
  // transferFrom
});
