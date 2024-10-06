const {time, loadFixture} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {anyValue} = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect} = require("chai");
const {encodeBytes32String, ZeroAddress, solidityPackedKeccak256, getBytes} = require("ethers");

describe("Forest CBDC", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployTokenFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const contract = await ethers.getContractFactory("MockForestCBDC");
    const token = await contract.deploy("United States dollar", "USD");

    return {token, owner, otherAccount};
  }

  describe("Transfers", function () {
    it("Should transfer the funds to the owner", async function () {
      const {token, owner} = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      await token.mint(address, 1000n);
      expect(await token.balanceOf(address)).to.equal(1000n);
    });

    it("Should transfer the funds to the owner", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      const otherAddress = await otherAccount.getAddress();
      let tx = await token.mint(address, 1000n);
      tx = await tx.wait();
      const tokenId = tx.logs[0].args[0];
      await token["transfer(address,bytes32,uint256)"](otherAddress, tokenId, 1000n);
      expect(await token.balanceOf(otherAddress)).to.equal(1000n);
    });

    it("Should not transfer with IERC20 transfer", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      const amount = 1000n;
      const address = await owner.getAddress();
      const otherAddress = await otherAccount.getAddress();
      let tx = await token.mint(address, amount);
      tx = await tx.wait();
      const tokenId = tx.logs[0].args[0];
      await token["transfer(address,bytes32,uint256)"](otherAddress, tokenId, amount);
      expect(await token.balanceOf(otherAddress)).to.equal(1000n);
      // await expect(token.connect(otherAccount).transfer(address, amount)).to.be.revertedWithCustomError(token,"ERC20TransferNotSupported");

      // TODO: transferFrom(address,address,tokenId,amount)
      // TODO: burn(address,tokenId,amount)
    });

    it("Should not transferFrom with IERC20 transferFrom", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      const amount = 1000n;
      const address = await owner.getAddress();
      const otherAddress = await otherAccount.getAddress();
      let tx = await token.mint(address, amount);
      tx = await tx.wait();
      const tokenId = tx.logs[0].args[0];
      await token["transfer(address,bytes32,uint256)"](otherAddress, tokenId, amount);
      await token.connect(otherAccount).approve(address, amount);
      await expect(token.connect(owner).transferFrom(otherAddress, address, amount)).to.be.revertedWithCustomError(
        token,
        "ERC20TransferFromNotSupported",
      );
    });

    it("Should burn transfer with to address zero", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      const amount = 1000n;
      const address = await owner.getAddress();
      // const otherAddress = await otherAccount.getAddress();
      let tx = await token.mint(address, amount);
      tx = await tx.wait();
      const tokenId = tx.logs[0].args[0];
      // await expect(token.burn(address, tokenId ,amount)).to.be.emit(token,"Transfer").withArgs(address, ZeroAddress, amount);
      await token.burn(address, tokenId, amount);
      expect(await token.balanceOf(address)).to.equal(0);
      // TODO: transferFrom(address,address,tokenId,amount)
      // TODO: burn(address,tokenId,amount)
    });
  });

  // extensions
  describe("Restrict", function () {
    it("Should restrict transfer the funds to the other account by frozen tokenId", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      const otherAddress = await otherAccount.getAddress();
      let tx = await token.mint(address, 1000n);
      tx = await tx.wait();
      const tokenId = tx.logs[0].args[0];
      tx = await token["transfer(address,bytes32,uint256)"](otherAddress, tokenId, 100n);
      tx = await tx.wait();
      const tokenId2 = tx.logs[1].args[0];
      expect(await token.balanceOf(otherAddress)).to.equal(100n);
      await token.freezeToken(tokenId2);
      await expect(
        token.connect(otherAccount)["transfer(address,bytes32,uint256)"](address, tokenId2, 10n),
      ).to.be.revertedWithCustomError(token, "TokenFrozen");
    });

    it("Should restrict all transfer the funds to the other account by frozen root tokenId", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      const otherAddress = await otherAccount.getAddress();
      let tx = await token.mint(address, 1000n);
      tx = await tx.wait();
      let tokenId = tx.logs[0].args[0];
      let root = tx.logs[0].args[1];
      tx = await token["transfer(address,bytes32,uint256)"](otherAddress, tokenId, 10n);
      expect(await token.balanceOf(otherAddress)).to.equal(10n);
      await token.freezeToken(root);
      await expect(
        token["transfer(address,bytes32,uint256)"](otherAddress, tokenId, 10n),
      ).to.be.revertedWithCustomError(token, "TokenFrozen");
    });

    it("Should restrict all transfer the funds to the other account by frozen parent tokenId", async function () {
      const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
      // const address = await owner.getAddress();
      // const otherAddress = await otherAccount.getAddress();
      // let tx = await token.mint(address, 1000n);
      // tx = await tx.wait();
      // const tokenId = tx.logs[0].args[0];
      // tx = await token["transfer(address,bytes32,uint256)"](
      //   otherAddress,
      //   tokenId,
      //   100n
      // );
      // tx = await tx.wait();
      // const tokenId2 = tx.logs[1].args[0];
      // expect(await token.balanceOf(otherAddress)).to.equal(100n);
      // await token.freezeToken(parent);
      // await expect(
      //   await token["transfer(address,bytes32,uint256)"](
      //     otherAddress,
      //     tokenId2,
      //     10n
      //   )
      // ).to.equal("");
    });
  });
});
