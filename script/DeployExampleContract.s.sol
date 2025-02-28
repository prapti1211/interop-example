// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import {ExampleContract} from "../src/ExampleContract.sol";

contract DeployExampleContract is Script {
    // Use the address of the deployed InteropBridge
    address constant INTEROP_BRIDGE = 0x7b77AC0269c523d7678F113F61C2ECBff6F0e7dC;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the ExampleContract with the InteropBridge address
        ExampleContract exampleContract = new ExampleContract(INTEROP_BRIDGE);
        
        console.log("ExampleContract deployed at:", address(exampleContract));
        
        vm.stopBroadcast();
    }
}