const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addrs;

  beforeEach(async function () {
    const SubscriptionNFT = await ethers.getContractFactory("SubscriptionNFT");
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    hardhatSubscriptionNFT = await SubscriptionNFT.deploy();
  });

  it("Active user's subscription number should change", async function () {

    expect(await hardhatSubscriptionNFT.getUserNFTS(addr1.address, addr2.address)).to.equal(0);

    await hardhatSubscriptionNFT.mint(addr1.address, addr2.address);


    expect(await hardhatSubscriptionNFT.getUserNFTS(addr1.address, addr2.address)).to.equal(1);

    let expiration1 = await hardhatSubscriptionNFT.getUserSubscription(addr1.address, addr2.address)

    console.log(expiration1)

    await hardhatSubscriptionNFT.mint(addr1.address, addr2.address);
    expect(await hardhatSubscriptionNFT.getUserNFTS(addr1.address, addr2.address)).to.equal(2);
    let expiration2 = await hardhatSubscriptionNFT.getUserSubscription(addr1.address, addr2.address)

    console.log(expiration2)

    // expect(await hardhatSubscriptionNFT.ownerOf(1)).to.equal(addr2.address);
    // await hardhatSubscriptionNFT.connect(addr2).transferFrom(addr2.address, addr3.address, 1)

    // expiration1 = await hardhatSubscriptionNFT.getUserSubscription(addr1.address, addr3.address)

    // console.log(expiration1)

    await hardhatSubscriptionNFT.connect(addr2).transferFrom(addr2.address, addr3.address, 2)

    expiration1 = await hardhatSubscriptionNFT.getUserSubscription(addr1.address, addr3.address)

    console.log(expiration1)

    await hardhatSubscriptionNFT.connect(addr2).transferFrom(addr2.address, addr3.address, 1)

    expiration1 = await hardhatSubscriptionNFT.getUserSubscription(addr1.address, addr3.address)

    console.log(expiration1)

    expiration1 = await hardhatSubscriptionNFT.getUserSubscription(addr1.address, addr2.address)

    console.log(expiration1)



    await hardhatSubscriptionNFT.connect(addr3).transferFrom(addr3.address, addr2.address, 2)

    expiration1 = await hardhatSubscriptionNFT.getUserSubscription(addr1.address, addr3.address)
    expiration2 = await hardhatSubscriptionNFT.getUserSubscription(addr1.address, addr2.address)

    console.log(expiration1)
    console.log(expiration2)


    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
