// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DomainRegistry {
    
    mapping(string => address) public domainToOwner;
    mapping(address => uint) public ownerBalance;
    uint public domainDeposit = 1 ether;

    function isValidFirstLevelDomain(string memory _domain) internal pure returns (bool) {
        bytes memory domainBytes = bytes(_domain);
        for (uint i = 0; i < domainBytes.length; i++) {
            if (domainBytes[i] == '.') {
                return false;
            }
        }
        return true;
    }

    function registerDomain(string memory _domain) public payable {
        require(isValidFirstLevelDomain(_domain), "Invalid domain format");
        require(msg.value == domainDeposit, "Incorrect deposit amount");
        require(domainToOwner[_domain] == address(0), "Domain already registered");
        
        domainToOwner[_domain] = payable(msg.sender);
        ownerBalance[msg.sender] += msg.value;
    }

    function releaseDomain(string memory _domain) public {
        require(domainToOwner[_domain] == msg.sender, "Only the domain owner can release it");
        
        payable(msg.sender).transfer(domainDeposit);
        ownerBalance[msg.sender] -= domainDeposit;
        domainToOwner[_domain] = address(0);
    }

    function getDomainOwner(string memory _domain) public view returns (address) {
        return domainToOwner[_domain];
    }
}
