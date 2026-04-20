// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {AssetMaster} from "../src/AssetMaster.sol";
import {ClassAShares} from "../src/ClassAShares.sol";
import {FractionalVault} from "../src/FractionalVault.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        ClassAShares classAShares = new ClassAShares(deployerAddress, deployerAddress);
        AssetMaster assetMaster = new AssetMaster(deployerAddress);
        FractionalVault vault = new FractionalVault(address(assetMaster), address(classAShares));

        bytes32 minterRole = classAShares.MINTER_ROLE();
        classAShares.grantRole(minterRole, address(vault));

        vm.stopBroadcast();

        console.log("=== Deployment completato ===");
        console.log("ClassAShares deployato a: ", address(classAShares));
        console.log("AssetMaster deployato a:  ", address(assetMaster));
        console.log("FractionalVault deployato a:", address(vault));
    }
}
