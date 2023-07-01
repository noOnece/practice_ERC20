// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pausable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;
    address host;

    constructor() {
        _paused = false;
        host = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == host);
        _;
  }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function isPaused() public view returns (bool) {
        return _paused;
    }
}