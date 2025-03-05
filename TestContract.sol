// TestContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestContract {
    uint256 public value;
    string public message;
    event ValueUpdated(uint256 value, string message);
    
    function setValue(uint256 _value, string memory _message) external {
        value = _value;
        message = _message;
        emit ValueUpdated(_value, _message);
    }
}