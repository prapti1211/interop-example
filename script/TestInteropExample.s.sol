// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import {ExampleContract} from "../src/ExampleContract.sol";

contract TestInteropExample is Script {
    // Chain IDs
    uint256 constant CHAIN_A_ID = 420120000;
    uint256 constant CHAIN_B_ID = 420120001;
    
    // Deployed contract addresses (to be filled after deployment)
    address constant EXAMPLE_CONTRACT_CHAIN_A = 0xBEc49fA140aCaA83533fB00A2BB19bDdd0290f25; // Replace with actual address after deployment
    address constant EXAMPLE_CONTRACT_CHAIN_B = 0xB0D4afd8879eD9F52b28595d31B441D079B2Ca07; // Replace with actual address after deployment
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Get the ExampleContract instance on the current chain
        ExampleContract exampleContract;
        address targetContract;
        uint256 targetChainId;
        
        if (block.chainid == CHAIN_A_ID) {
            exampleContract = ExampleContract(EXAMPLE_CONTRACT_CHAIN_A);
            targetContract = EXAMPLE_CONTRACT_CHAIN_B;
            targetChainId = CHAIN_B_ID;
        } else if (block.chainid == CHAIN_B_ID) {
            exampleContract = ExampleContract(EXAMPLE_CONTRACT_CHAIN_B);
            targetContract = EXAMPLE_CONTRACT_CHAIN_A;
            targetChainId = CHAIN_A_ID;
        } else {
            revert("Unsupported chain ID");
        }
        
        // Test updating value on the target chain
        uint256 newValue = 42;
        bytes32 msgHash = exampleContract.updateValueOnRemoteChain(
            targetChainId,
            targetContract,
            newValue
        );
        
        console.log("Cross-chain update requested");
        console.log("Message hash:", vm.toString(msgHash));
        console.log("New value:", newValue);
        console.log("Target chain ID:", targetChainId);
        console.log("Target contract:", targetContract);
        
        vm.stopBroadcast();
    }
}