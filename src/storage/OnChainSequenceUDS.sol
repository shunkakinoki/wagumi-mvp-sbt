// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@0xsequence/sstore2/contracts/SSTORE2Map.sol";

// ------------- storage

bytes32 constant DIAMOND_STORAGE_ONCHAIN_SEQUENCE = keccak256(
    "diamond.storage.onchain.sequence"
);

function s() pure returns (OnChainSequenceDS storage diamondStorage) {
    bytes32 slot = DIAMOND_STORAGE_ONCHAIN_SEQUENCE;
    assembly { diamondStorage.slot := slot } // prettier-ignore
}

struct OnChainSequenceDS {
    mapping(uint256 => string) onChainStorage;
}

contract OnChainSequenceUDS {
    /* ------------- internal ------------- */

    function _storeOnChain(uint256 tokenId, string calldata dataURI) internal {
        // WIP NEED TO FIX THIS
        s().onChainStorage[tokenId] = keccak256(tokenId);
        SSTORE2Map.write(keccak256(tokenId), abi.encode(dataURI));
    }
}
