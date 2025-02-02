// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { Coinflip } from "../src/Coinflip.sol";
import { CoinflipV2 } from "../src/CoinflipV2.sol";
import { DauphineToken } from "../src/DauphineToken.sol"; // Import token contract
import { Script } from "forge-std/Script.sol"; // Correct import for scripts
import {Test, console2} from "forge-std/Test.sol";

contract Deploy is Script {
    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy Dauphine Token contract
        DauphineToken dauphineToken = new DauphineToken();
        console2.log("DauphineToken deployed at:", address(dauphineToken));

        // Deploy Coinflip contract
        Coinflip coinflip = new Coinflip();
        console2.log("Coinflip contract deployed at:", address(coinflip));

        // Optionally, deploy CoinflipV2 if needed
        CoinflipV2 coinflipV2 = new CoinflipV2();
        console2.log("CoinflipV2 contract deployed at:", address(coinflipV2));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
