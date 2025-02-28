// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {InteropBridge} from "./InteropBridge.sol";

/**
 * @title ExampleContract
 * @notice Example contract to demonstrate cross-chain communication
 * @dev Works with the InteropBridge contract
 */
contract ExampleContract {
    // The bridge contract
    InteropBridge public interopBridge;
    
    // State variables
    uint256 public value;
    uint256 public lastSourceChainId;
    address public lastSender;
    
    // Events
    event ValueUpdated(uint256 newValue, uint256 sourceChainId, address sender);
    event CrossChainUpdateRequested(uint256 targetChainId, uint256 newValue, bytes32 msgHash);
    
    /**
     * @notice Constructor
     * @param _interopBridge Address of the InteropBridge contract
     */
    constructor(address _interopBridge) {
        interopBridge = InteropBridge(_interopBridge);
    }
    
    /**
     * @notice Update the value on a remote chain
     * @param targetChainId The chain ID where the value should be updated
     * @param targetContract The address of the ExampleContract on the target chain
     * @param newValue The new value to set
     * @return msgHash The hash of the cross-chain message
     */
    function updateValueOnRemoteChain(
        uint256 targetChainId,
        address targetContract,
        uint256 newValue
    ) external returns (bytes32) {
        // Encode the function call for the remote chain
        bytes memory data = abi.encodeWithSelector(
            this.receiveValueUpdate.selector,
            newValue,
            block.chainid,
            msg.sender
        );
        
        // Call the interop bridge to send the message to the target chain
        bytes32 msgHash = interopBridge.automate(targetChainId, targetContract, data);
        
        emit CrossChainUpdateRequested(targetChainId, newValue, msgHash);
        
        return msgHash;
    }
    
    /**
     * @notice Receive a value update from another chain
     * @dev Can only be called by the InteropBridge contract
     * @param newValue The new value to set
     * @param sourceChainId The chain ID where the update originated
     * @param sender The address that initiated the update on the source chain
     */
    function receiveValueUpdate(
        uint256 newValue,
        uint256 sourceChainId,
        address sender
    ) external {
        // Ensure only the InteropBridge can call this function
        require(msg.sender == address(interopBridge), "Only InteropBridge can call");
        
        // Update the state variables
        value = newValue;
        lastSourceChainId = sourceChainId;
        lastSender = sender;
        
        // Emit event
        emit ValueUpdated(newValue, sourceChainId, sender);
    }
    
    /**
     * @notice Check if a cross-chain message has been executed
     * @param msgHash The hash of the message to check
     * @return True if the message has been executed
     */
    function isMessageExecuted(bytes32 msgHash) external view returns (bool) {
        return interopBridge.isMessageExecuted(msgHash);
    }
    
    /**
     * @notice Update the value locally (for testing purposes)
     * @param newValue The new value to set
     */
    function updateValueLocally(uint256 newValue) external {
        value = newValue;
        lastSourceChainId = block.chainid;
        lastSender = msg.sender;
        
        emit ValueUpdated(newValue, block.chainid, msg.sender);
    }
}