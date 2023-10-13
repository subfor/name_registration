// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./StringUtils.sol";

contract DomainRegistry {
    
    mapping(string => address) public domainToOwner;
    mapping(address => uint) public ownerBalance;
    uint public domainDeposit = 1 ether;


    function isValidForRegistration(string memory _domain) internal view returns (bool) {
        string memory parentDomain = StringUtils.getParentDomain(_domain);

        if (StringUtils.isValidFirstLevelDomain(_domain)) {
            return (getDomainOwner(_domain) == address(0));
        } else {
            return (getDomainOwner(parentDomain) != address(0));
        }
    }
    function registerDomain(string memory _domain) public payable {
        string memory stripedDomain = StringUtils.stripUrl(_domain);
        
        require(domainToOwner[stripedDomain] == address(0), "Domain already registered");
        require(isValidForRegistration(stripedDomain), "Invalid domain");
        require(msg.value == domainDeposit, "Incorrect deposit amount");
        
        domainToOwner[stripedDomain] = payable(msg.sender);
        ownerBalance[msg.sender] += msg.value;
    }


    function releaseDomain(string memory _domain) public {
        string memory stripedDomain = StringUtils.stripUrl(_domain);
        require(domainToOwner[stripedDomain] == msg.sender, "Only the domain owner can release it");
        
        payable(msg.sender).transfer(domainDeposit);
        ownerBalance[msg.sender] -= domainDeposit;
        domainToOwner[stripedDomain] = address(0);
    }

    function getDomainOwner(string memory _domain) public view returns (address) {
        string memory stripedDomain = StringUtils.stripUrl(_domain);
        return domainToOwner[stripedDomain];
    }
}