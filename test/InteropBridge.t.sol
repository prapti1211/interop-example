// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {ExampleContract} from "../src/ExampleContract.sol";
import {InteropBridge} from "../src/InteropBridge.sol";

contract TestInteropBridge is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Get the address of the deployed InteropBridge
        address interopBridgeAddress = vm.envAddress("INTEROP_BRIDGE_ADDRESS");
        
        // Deploy the example contract
        ExampleContract exampleContract = new ExampleContract(interopBridgeAddress);
        console.log("ExampleContract deployed at:", address(exampleContract));
        
        // Update the value locally
        exampleContract.updateValue(42);
        console.log("Updated value locally to:", exampleContract.value());
        
        // This part would be called on a different chain, but for testing we'll call it here
        // In a real scenario, you'd run this script on a different chain
        uint256 targetChainId = 10; // Example: Optimism's chain ID
        address targetContractAddress = address(exampleContract); // In reality, this would be an address on the target chain
        
        // Call the function to update value on another chain
        bytes32 msgHash = exampleContract.updateValueOnOtherChain(
            targetChainId,
            targetContractAddress,
            100
        );
        
        console.log("Cross-chain message sent with hash:", vm.toString(msgHash));
        
        vm.stopBroadcast();
    }
}