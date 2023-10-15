// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library StringUtils {

    function isValidFirstLevelDomain(string memory _domain) internal pure returns (bool) {
        bytes memory domainBytes = bytes(_domain);
        for (uint i = 0; i < domainBytes.length; i++) {
            if (domainBytes[i] == '.') {
                return false;
            }
        }
        return true;
    }

    function toLowerCase(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        for (uint i = 0; i < bStr.length; i++) {
            // If the char is an uppercase letter (between 'A' and 'Z')
            if (uint8(bStr[i]) >= 65 && uint8(bStr[i]) <= 90) {
                bStr[i] = bytes1(uint8(bStr[i]) + 32);
            }
        }
        return string(bStr);
    }

    function substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function stripUrl(string memory _url) internal pure returns (string memory) {
        string memory lowerCaseDomain = toLowerCase(_url); 
        if (hasPrefix(lowerCaseDomain, "http://")) {
            return substring(lowerCaseDomain, 7, bytes(lowerCaseDomain).length);
        }
        
        if (hasPrefix(lowerCaseDomain, "https://")) {
            return substring(lowerCaseDomain, 8, bytes(lowerCaseDomain).length);
        }
        // console.log(lowerCaseDomain);
        return lowerCaseDomain;
    }


    function hasPrefix(string memory _string, string memory _prefix) internal pure returns (bool) {
        bytes memory stringBytes = bytes(_string);
        bytes memory prefixBytes = bytes(_prefix);
        
        if (stringBytes.length < prefixBytes.length) {
            return false;
        }

        for (uint i = 0; i < prefixBytes.length; i++) {
            if (stringBytes[i] != prefixBytes[i]) {
                return false;
            }
        }
        return true;
    }


    function getParentDomain(string memory _domain) internal pure returns (string memory) {
        string memory stripedDomain = stripUrl(_domain);

        if(isValidFirstLevelDomain(stripedDomain)) {
            return stripedDomain;
        } else {
            bytes memory domainBytes = bytes(stripedDomain);
            uint firstDotIndex = 0;
            for(uint i = 0; i < domainBytes.length; i++) {
                if(domainBytes[i] == '.') {
                    firstDotIndex = i;
                    break;
                }
            }
            return substring(_domain, firstDotIndex + 1, bytes(_domain).length);
        }
    }
    

}