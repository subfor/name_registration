// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./StringUtils.sol";
import "hardhat/console.sol";

contract DomainRegistry is Ownable {
    
    mapping(string => address) public domainToOwner;
    uint public registrationFee = 1 ether;

    // Конструктор для задания начального владельца контракта
    constructor() Ownable(msg.sender) {}

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
        require(msg.value == registrationFee, "Incorrect registration fee");
        
        domainToOwner[stripedDomain] = msg.sender;
        
        // Перенаправляем плату на адрес владельца контракта
        payable(owner()).transfer(registrationFee);
    }

    function releaseDomain(string memory _domain) public {
        string memory stripedDomain = StringUtils.stripUrl(_domain);
        require(domainToOwner[stripedDomain] == msg.sender, "Only the domain owner can release it");
        
        domainToOwner[stripedDomain] = address(0);
    }

    function getDomainOwner(string memory _domain) public view returns (address) {
        string memory stripedDomain = StringUtils.stripUrl(_domain);
        return domainToOwner[stripedDomain];
    }
}
