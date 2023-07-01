//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EIP712 {

    bytes32 private DOMAIN_SEPARATOR;
    
    bytes32 private constant _TYPE_HASH =
    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    uint256 private immutable _ChainId;
    address private immutable _ContractAddress;

    bytes32 private immutable _name;
    bytes32 private immutable _version;
    constructor(string memory name, string memory version) {
        _name = keccak256(bytes(name));
        _version = keccak256(bytes(version));
        _ContractAddress = address(this);

        _ChainId = block.chainid;
        DOMAIN_SEPARATOR = _buildDomainSeparator();
        
    }

    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _name, _version, _ChainId, _ContractAddress));
    }
    
    function _toTypedDataHash(bytes32 structHash) public view returns (bytes32) {
                bytes32 digest = keccak256(
            abi.encodePacked(
                bytes("\x19\x01"),
                _domainSeparator(),
                structHash
            )
        );
        return digest;
        
    }

}
