const { expect } = require("chai");
const { ethers } = require("hardhat");
// const { utils } = ethers;

describe("DomainRegistry", function () {
  let DomainRegistry, domainRegistry, owner, addr1, addr2;

  beforeEach(async () => {
    DomainRegistry = await ethers.getContractFactory("DomainRegistry");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    domainRegistry = await DomainRegistry.deploy();
  });

  it("should allow a user to register a first level domain", async () => {
    await domainRegistry.connect(owner).registerDomain("example", { value: ethers.parseEther("1") });
    const domainOwner = await domainRegistry.getDomainOwner("example");
    expect(domainOwner).to.equal(owner.address);
  });

  it("should not allow registration of a domain if deposit is incorrect", async () => {
    await expect(domainRegistry.connect(owner).registerDomain("example", { value: ethers.parseEther("0.5") }))
      .to.be.revertedWith("Incorrect deposit amount");
  });

  it("should not allow registration of already registered domain", async () => {
    await domainRegistry.connect(owner).registerDomain("example", { value: ethers.parseEther("1") });
    await expect(domainRegistry.connect(addr1).registerDomain("example", { value: ethers.parseEther("1") }))
      .to.be.revertedWith("Domain already registered");
  });

  it("should not allow registration of a domain if parent domain is not exist", async () => {
    await domainRegistry.connect(owner).registerDomain("com", { value: ethers.parseEther("1") });
    await expect(domainRegistry.connect(addr1).registerDomain("example.biz", { value: ethers.parseEther("1") }))
      .to.be.revertedWith("Invalid domain");
  });

  it("should allow registration of a domain if parent domain exist", async () => {
    await domainRegistry.connect(owner).registerDomain("com", { value: ethers.parseEther("1") });
    await domainRegistry.connect(addr1).registerDomain("example.com", { value: ethers.parseEther("1") });
    const domainOwner = await domainRegistry.getDomainOwner("example.com");
    expect(domainOwner).to.equal(addr1.address);
  });

  it("should allow registration of a domain from URL if parent domain exist", async () => {
    await domainRegistry.connect(owner).registerDomain("com", { value: ethers.parseEther("1") });
    await domainRegistry.connect(addr1).registerDomain("https://example.com", { value: ethers.parseEther("1") });
    const domainOwner = await domainRegistry.getDomainOwner("example.com");
    expect(domainOwner).to.equal(addr1.address);
  });

  it("should allow the domain owner to release the domain", async () => {
    await domainRegistry.connect(owner).registerDomain("example", { value: ethers.parseEther("1") });
    await domainRegistry.connect(owner).releaseDomain("example");
    const domainOwner = await domainRegistry.getDomainOwner("example");
    expect(domainOwner).to.equal(ethers.ZeroAddress);
  });

  it("should not allow non-owners to release the domain", async () => {
    await domainRegistry.connect(owner).registerDomain("example", { value: ethers.parseEther("1") });
    await expect(domainRegistry.connect(addr1).releaseDomain("example"))
      .to.be.revertedWith("Only the domain owner can release it");
  });

  // Добавьте дополнительные тесты по мере необходимости...
});
