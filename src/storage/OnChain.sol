// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ------------- storage

bytes32 constant DIAMOND_STORAGE_ONCHAIN = keccak256("diamond.storage.onchain");

function s() pure returns (OnChainDS storage diamondStorage) {
    bytes32 slot = DIAMOND_STORAGE_ONCHAIN;
    assembly { diamondStorage.slot := slot } // prettier-ignore
}

struct OnChainDS {
    mapping(uint256 => string) onChainStorage;
}

contract OnChainUDS {
    /* ------------- internal ------------- */

    function _storeOnChain(uint256 tokenId, string calldata dataURI) internal {
        s().onChainStorage[tokenId] = dataURI;
    }
}
