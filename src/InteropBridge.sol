// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CrossDomainMessageLib} from "../lib/interop-lib/src/libraries/CrossDomainMessageLib.sol";
import {PredeployAddresses} from "../lib/interop-lib/src/libraries/PredeployAddresses.sol";
import {IL2ToL2CrossDomainMessenger} from "../lib/interop-lib/src/interfaces/IL2ToL2CrossDomainMessenger.sol";

/**
 * @title InteropBridge
 * @notice Contract to facilitate cross-chain function calls
 * @dev This contract should be deployed with the same address on all chains
 */
contract InteropBridge {
    // Events
    event CrossChainFunctionCalled(
        uint256 indexed targetChainId,
        address indexed targetContract,
        bytes4 functionSelector,
        bytes data,
        bytes32 msgHash
    );
    
    event CrossChainCallReceived(
        uint256 indexed sourceChainId,
        address indexed sourceContract,
        address indexed targetContract, 
        bytes data
    );
    
    // Errors
    error CallFailed(address target, bytes reason);
    error InvalidCaller();
    error CannotSendToSameChain();
    
    // State variables
    mapping(bytes32 => bool) public executedMessages;
    
    /**
     * @notice Call a function on a contract deployed on another chain
     * @param targetChainId The chain ID where the function should be executed
     * @param targetContract The address of the contract to call on the target chain
     * @param data The calldata to execute on the target contract
     */
    function automate(
        uint256 targetChainId,
        address targetContract,
        bytes calldata data
    ) external returns (bytes32) {
        // Ensure we're not trying to send to the same chain
        if (targetChainId == block.chainid) {
            revert CannotSendToSameChain();
        }
        
        // Encode the cross-chain message
        bytes memory message = abi.encodeWithSelector(
            this.executeRemoteCall.selector,
            block.chainid,   // source chain ID
            msg.sender,      // original caller/contract
            targetContract,  // target contract to call
            data             // function data to execute
        );
        // Send the message through the cross-domain messenger
        bytes32 msgHash = IL2ToL2CrossDomainMessenger(PredeployAddresses.L2_TO_L2_CROSS_DOMAIN_MESSENGER)
            .sendMessage(
                uint256(uint160(address(this))),  // The interop contract on the target chain
                address(uint160(bytes20(message))), // Convert bytes to address
                abi.encodePacked(uint256(1000000)) // Convert gas limit to bytes
            );
        emit CrossChainFunctionCalled(
            targetChainId,
            targetContract,
            bytes4(data),
            data,
            msgHash
        );
        
        return msgHash;
    }
    
    /**
     * @notice Execute a function call that was sent from another chain
     * @dev This function can only be called by the L2ToL2CrossDomainMessenger
     * @param sourceChainId The chain ID where the call originated
     * @param sourceContract The contract that initiated the call
     * @param targetContract The contract to call on this chain
     * @param data The calldata to execute
     */
    function executeRemoteCall(
        uint256 sourceChainId,
        address sourceContract,
        address targetContract,
        bytes calldata data
    ) external returns (bool, bytes memory) {
        // Ensure the caller is the cross-domain messenger
        CrossDomainMessageLib.requireCallerIsCrossDomainMessenger();
        
        // Verify this is a cross-chain call from our counterpart contract
        if (IL2ToL2CrossDomainMessenger(PredeployAddresses.L2_TO_L2_CROSS_DOMAIN_MESSENGER)
            .crossDomainMessageSender() != address(this)) {
            revert InvalidCaller();
        }
        
        // Emit an event for the received cross-chain call
        emit CrossChainCallReceived(
            sourceChainId,
            sourceContract,
            targetContract,
            data
        );
        
        // Execute the call on the target contract
        (bool success, bytes memory result) = targetContract.call(data);
        if (!success) {
            revert CallFailed(targetContract, result);
        }
        
        return (success, result);
    }
    
    /**
     * @notice Check if a cross-chain message has been executed successfully
     * @param msgHash The hash of the message to check
     * @return True if the message has been executed successfully
     */
    function isMessageExecuted(bytes32 msgHash) external view returns (bool) {
        return IL2ToL2CrossDomainMessenger(PredeployAddresses.L2_TO_L2_CROSS_DOMAIN_MESSENGER)
            .successfulMessages(msgHash);
    }
    
    /**
     * @notice Wait for a cross-chain message to be executed
     * @dev This function will revert if the message has not been executed
     * @param msgHash The hash of the message to wait for
     */
    function waitForMessage(bytes32 msgHash) external view {
        CrossDomainMessageLib.requireMessageSuccess(msgHash);
    }
}