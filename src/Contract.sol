// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC721UDS} from "UDS/tokens/ERC721UDS.sol";
import {AccessControlUDS} from "UDS/auth/AccessControlUDS.sol";
import {OwnableUDS} from "UDS/auth/OwnableUDS.sol";
import {PausableUDS} from "UDS/auth/PausableUDS.sol";
import {UUPSUpgrade} from "UDS/proxy/UUPSUpgrade.sol";
import {Initializable} from "UDS/auth/Initializable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

error NotPauser();
error TokenTransferWhilePaused();
error IncorrectSignature();

contract WagumiSBTMVP is
    UUPSUpgrade,
    Initializable,
    OwnableUDS,
    AccessControlUDS,
    PausableUDS,
    ERC721UDS
{
    using ECDSA for bytes32;

    /// @dev keccak256('PAUSER_ROLE')
    bytes32 public constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    /// EIP 5192: https://github.com/ethereum/EIPs/blob/7711f47ffe2969ab4462d848bca475e2ec857feb/EIPS/eip-5192.md
    /// @dev keccak256('MINTER_ROLE')
    bytes32 public constant MINTER_ROLE =
        0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6;
    bytes4 constant SOULBOUND_VALUE = bytes4(keccak256("soulbound")); // 0x9e7ed7f8;

    function init() public virtual initializer {
        __Ownable_init();
        __ERC721_init("Wagumi DAO Soul Bound Token", "WDSBT");

        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(PAUSER_ROLE, msg.sender);
        grantRole(MINTER_ROLE, msg.sender);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "URI";
    }

    function mint(uint256 tokenId, bytes calldata signature) public onlyOwner {
        if (!verifySig(signature, tokenId)) revert IncorrectSignature();

        _mint(msg.sender, tokenId);
    }

    function pause() public {
        if (!hasRole(PAUSER_ROLE, msg.sender)) revert NotPauser();

        _pause();
    }

    function unpause() public {
        if (!hasRole(PAUSER_ROLE, msg.sender)) revert NotPauser();

        _unpause();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUDS, ERC721UDS)
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    function verifySig(bytes memory signature, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        address signingAddress;
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, tokenId));
        signingAddress = messageHash.toEthSignedMessageHash().recover(
            signature
        );
        return hasRole(MINTER_ROLE, signingAddress);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override(ERC721UDS) notPaused {
        /// @dev Pause status won't block mint operation
        if (from != address(0)) revert TokenTransferWhilePaused();

        super.transferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override(ERC721UDS) notPaused {
        /// @dev Pause status won't block mint operation
        if (from != address(0)) revert TokenTransferWhilePaused();

        super.safeTransferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual override(ERC721UDS) notPaused {
        /// @dev Pause status won't block mint operation
        if (from != address(0)) revert TokenTransferWhilePaused();

        super.safeTransferFrom(from, to, id, data);
    }

    function _authorizeUpgrade() internal override onlyOwner {}
}
