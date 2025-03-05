// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "../TestContract.sol";

contract DeployTestContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        TestContract testContract = new TestContract();
        
        vm.stopBroadcast();
        
        console.log("TestContract deployed at:", address(testContract));
    }
}
