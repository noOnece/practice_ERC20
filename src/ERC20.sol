// SPDX-License-Identifier: MIT

import "./Pausable.sol";
import "./EIP712.sol";

pragma solidity ^0.8.0;

contract ERC20 is Pausable,EIP712 {
    mapping(address => uint256) private balances;
    mapping(address => uint256) private _nonces;
    mapping(address => mapping(address => uint256)) private allowances; 
    bytes32 private constant _PERMIT_TYPE_HASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    uint256 private _totalSupply;
    address public owner;
    string private name;
    string private symbol;
    uint8 private _decimals;
    
    constructor(string memory _name,string memory _symbol) EIP712(_name,"1") {
        _decimals = 18; 
        _totalSupply = 0;
        name = _name;
        symbol = _symbol;
        _mint(msg.sender,100 ether);
        owner = msg.sender;
    }

    function pause() public virtual whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() public virtual whenPaused onlyOwner {
        _unpause();
    }

    function nonces(address _owner) public view returns (uint256) {
        return _nonces[_owner];
    }

    function permit(address _owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s) public virtual {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        require(owner != address(0), "ERC20: Invalid owner address");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPE_HASH, _owner, spender, value, nonces(_owner), deadline));

        bytes32 hash = _toTypedDataHash(structHash);

        address signer = ecrecover(hash, v, r, s);
        require( signer != address(0) && signer == _owner, "INVALID_SIGNER");

        _approve(_owner,spender, value);
        _nonces[_owner]++;
    }

   
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event approval(address indexed owner, address indexed spender, uint256 value);

    
    function transfer(address _to, uint256 _value) external whenNotPaused returns (bool success) {
        require(_to != address(0), "transfer to the zero address");
        require(balances[msg.sender] >= _value, "value exceeds balance");
        unchecked {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
        require(_spender != address(0), "approve to the zero address");

        allowances[msg.sender][_spender] = _value;
        emit approval(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address _owner, address _spender, uint _value) private {
        require(_spender != address(0), "approve to the zero address");

        allowances[_owner][_spender] = _value;
        emit approval(_owner, _spender, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }


    function transferFrom(address _from, address _to, uint256 _value) external  whenNotPaused returns (bool success) {
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        require(balances[_from] >= _value);
        require(allowances[_from][msg.sender] >= _value);

        unchecked {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowances[_from][msg.sender] -= _value;
        }

        emit Transfer(_from, _to, _value);

        return true;
    }

    function _mint(address _owner, uint256 _value) internal whenNotPaused {
        require(_owner != address(0), "mint to the zero address");

        _totalSupply += _value;
        balances[_owner] += _value;
        emit Transfer(address(0), _owner, _value);
    }

    function _burn(address _owner, uint256 _value) internal whenNotPaused {
        require(_owner != address(0), "burn from the zero address");
        require(balances[_owner] >= _value, "burn amount exceeds balance");

        unchecked {
            balances[_owner] -= _value;
            _totalSupply -= _value;
        }

        emit Transfer(_owner, address(0), _value);
    }

    


}