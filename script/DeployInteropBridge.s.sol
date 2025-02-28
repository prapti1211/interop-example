// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import {CreateX} from "../lib/createx/src/CreateX.sol";
import {ICreateX} from "../lib/createx/src/ICreateX.sol";
import {InteropBridge} from "../src/InteropBridge.sol";

contract DeployInteropBridge is Script {
    // This salt will be used for deterministic deployment across all chains
    bytes32 constant DEPLOYMENT_SALT = bytes32(uint256(0x123456));
    
    // You can deploy this once and use the same address, or use the official CreateX address
    // For Ethereum mainnet, CreateX is at 0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed
    address constant CREATEX_ADDRESS = 0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Get the bytecode of the InteropBridge contract
        bytes memory initCode = abi.encodePacked(
            type(InteropBridge).creationCode
        );
        
        // Use the established CreateX instance
        ICreateX createX = ICreateX(CREATEX_ADDRESS);
        
        // Deploy using fixed salt
        address interopBridge = createX.deployCreate2(DEPLOYMENT_SALT, initCode);
        
        console.log("InteropBridge deployed at:", interopBridge);
        
        // Compute the address (should be the same on all chains)
        bytes32 initCodeHash = keccak256(initCode);
        address computedAddress = createX.computeCreate2Address(DEPLOYMENT_SALT, initCodeHash);
        console.log("Computed address for other chains:", computedAddress);
        
        vm.stopBroadcast();
    }
}