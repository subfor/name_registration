// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    require(startIndex <= endIndex, "Invalid indexes");

    string memory result = new string(endIndex - startIndex);
    assembly {
        let strPtr := add(str, 0x20)
        let resPtr := add(result, 0x20)
        let length := sub(endIndex, startIndex)

        for { let i := 0 } lt(i, length) { i := add(i, 1) } {
            // Read the byte from the source string
            let byteData := mload(add(strPtr, div(add(i, startIndex), 32)))
            // Isolate the relevant byte and store it in the result
            mstore8(add(resPtr, i), and(shr(mul(sub(31, mod(add(i, startIndex), 32)), 8), byteData), 0xff))
        }
    }
    return result;
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
        
        bool isMatch = true;

        assembly {
            let strPtr := add(stringBytes, 0x20) // указатель на первый байт строки
            let prefixPtr := add(prefixBytes, 0x20) // указатель на первый байт префикса

            let strLength := mload(stringBytes) // длина строки
            let prefixLength := mload(prefixBytes) // длина префикса

            // Если длина строки меньше длины префикса, то это точно не префикс
            if lt(strLength, prefixLength) {
                isMatch := 0
            }

            // Проходим по каждому байту префикса и сравниваем его с соответствующим байтом строки
            for { let i := 0 } and(isMatch, lt(i, prefixLength)) { i := add(i, 1) } {
                let strByte := byte(0, mload(add(strPtr, i)))
                let prefixByte := byte(0, mload(add(prefixPtr, i)))

                // Если байты не совпадают, завершаем проверку
                if iszero(eq(strByte, prefixByte)) {
                    isMatch := 0
                }
            }
        }

        return isMatch;
    }

    function getParentDomain(string memory _domain) internal pure returns (string memory) {
        string memory stripedDomain = stripUrl(_domain);
        bytes memory domainBytes = bytes(stripedDomain);

        if (isValidFirstLevelDomain(stripedDomain)) {
            return stripedDomain;
        } else {
            uint firstDotIndex = 0xFFFFFFFFFFFFFFFF; // максимальное значение uint256

            assembly {
                let domainPtr := add(domainBytes, 0x20) // указатель на первый байт домена
                let domainLength := mload(domainBytes) // длина домена
                
                for { let i := 0 } lt(i, domainLength) { i := add(i, 1) } {
                    // 0x2e - это ASCII значение для '.'
                    if eq(byte(0, mload(add(domainPtr, i))), 0x2e) {
                        firstDotIndex := i
                        break
                    }
                }
            }

            if (firstDotIndex != 0xFFFFFFFFFFFFFFFF) {
                return substring(stripedDomain, firstDotIndex + 1, domainBytes.length);
            }
        }

        return ""; // если ни одно из условий не выполнено, вернем пустую строку
    }
}