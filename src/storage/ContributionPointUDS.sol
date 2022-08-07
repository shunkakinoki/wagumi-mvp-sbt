// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ------------- storage

bytes32 constant DIAMOND_STORAGE_CONTRIBUTION_POINT = keccak256(
    "diamond.storage.contribution.point"
);

function s() pure returns (ContributionPointDS storage diamondStorage) {
    bytes32 slot = DIAMOND_STORAGE_CONTRIBUTION_POINT;
    assembly { diamondStorage.slot := slot } // prettier-ignore
}

struct ContributionPointDS {
    mapping(address => uint256) contributionPointStorage;
}

contract ContributionPointUDS {
    /* ------------- internal ------------- */

    function _setMemberContributionPoint(address member, uint256 point)
        internal
    {
        s().contributionPointStorage[member] = point;
    }
}
