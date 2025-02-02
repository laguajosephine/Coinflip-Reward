// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { Coinflip } from "../src/Coinflip.sol";
import { CoinflipV2 } from "../src/CoinflipV2.sol";
import { DauphineToken } from "../src/DauphineToken.sol"; // Import your token contract
import { Script } from "forge-std/Script";

contract Deploy is Script {
    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy Dauphine Token
        DauphineToken dauphineToken = new DauphineToken();
        console.log("DauphineToken deployed at:", address(dauphineToken));

        // Deploy Coinflip contract
        Coinflip coinflip = new Coinflip();
        console.log("Coinflip contract deployed at:", address(coinflip));

        // Optionally deploy CoinflipV2 contract if needed
        CoinflipV2 coinflipV2 = new CoinflipV2();
        console.log("CoinflipV2 contract deployed at:", address(coinflipV2));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
