const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DomainRegistry", function () {
  let DomainRegistry, domainRegistry, owner, addr1, addr2;
  beforeEach(async function () {
    DomainRegistry = await ethers.getContractFactory("DomainRegistry");
    [owner, addr1, addr2] = await ethers.getSigners();
    domainRegistry = await DomainRegistry.deploy();
  });
  


  it("Should allow registering a valid domain", async function () {
    await domainRegistry.connect(addr1).registerDomain("com", { value: ethers.parseEther("1") });
    expect(await domainRegistry.getDomainOwner("com")).to.equal(addr1.address);
  });

  it("Should not allow registering an invalid domain", async function () {
    await expect(domainRegistry.connect(addr1).registerDomain("business.com", { value: ethers.parseEther("1") }))
      .to.be.revertedWith("Invalid domain format");
  });

  it("Should not allow registering a domain with incorrect deposit", async function () {
    await expect(domainRegistry.connect(addr1).registerDomain("com", { value: ethers.parseEther("0.5") }))
      .to.be.revertedWith("Incorrect deposit amount");
  });

  it("Should not allow registering an already registered domain", async function () {
    await domainRegistry.connect(addr1).registerDomain("com", { value: ethers.parseEther("1") });
    await expect(domainRegistry.connect(addr2).registerDomain("com", { value: ethers.parseEther("1") }))
      .to.be.revertedWith("Domain already registered");
  });

  it("Should allow releasing a domain by the owner", async function () {
    await domainRegistry.connect(addr1).registerDomain("com", { value: ethers.parseEther("1") });
    await domainRegistry.connect(addr1).releaseDomain("com");
    expect(await domainRegistry.getDomainOwner("com")).to.equal(ethers.ZeroAddress);
  });

  it("Should not allow releasing a domain by non-owner", async function () {
    await domainRegistry.connect(addr1).registerDomain("com", { value: ethers.parseEther("1") });
    await expect(domainRegistry.connect(addr2).releaseDomain("com"))
      .to.be.revertedWith("Only the domain owner can release it");
  });
});
