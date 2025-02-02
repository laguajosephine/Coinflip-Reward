// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error SeedTooShort();

contract CoinflipV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    string public seed;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __Ownable_init_unchained(initialOwner);
        _transferOwnership(initialOwner);
        seed = "It is a good practice to rotate seeds often in gambling"; // Default seed value
    }

    /// @notice Checks user input against contract generated guesses
    /// @param Guesses is a fixed array of 10 elements which holds the user's guesses. The guesses are either 1 or 0 for heads or tails
    /// @return true if user correctly guesses each flip correctly or false otherwise
    function userInput(uint8[10] calldata Guesses) external view returns(bool){
        uint8[10] memory generatedFlips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != generatedFlips[i]) {
                return false;
            }
        }
        return true;
    }

    /// @notice allows the owner of the contract to change the seed to a new one
    /// @param NewSeed is a string which represents the new seed
/// @notice allows the owner of the contract to change the seed to a new one, with rotation
/// @param NewSeed is a string which represents the new seed
/// @param rotations is the number of times to rotate the seed string
    function seedRotation(string memory NewSeed, uint rotations) public onlyOwner {
        bytes memory newSeedBytes = bytes(NewSeed);
        uint seedLength = newSeedBytes.length;

        if (seedLength < 10){
            revert SeedTooShort();
        }

    // Normalize the number of rotations in case it's greater than the seed length
        rotations = rotations % seedLength;

    // Perform the rotation logic
        if (rotations > 0) {
        // Rotating the string
            bytes memory rotatedSeed = new bytes(seedLength);

        // Copying the rotated parts of the string
            for (uint i = 0; i < seedLength; i++) {
                rotatedSeed[i] = newSeedBytes[(i + seedLength - rotations) % seedLength];
            }

        // Set the rotated seed
            seed = string(rotatedSeed);
        } else {
        // If no rotations, just set the seed directly
            seed = NewSeed;
    }
}


    /// @notice This function generates 10 random flips by hashing characters of the seed
    /// @return a fixed 10 element array of type uint8 with only 1 or 0 as its elements
    function getFlips() public view returns (uint8[10] memory) {
        bytes memory seedBytes = bytes(seed);
        uint seedLength = seedBytes.length;
        uint8[10] memory flips;
        uint interval = seedLength / 10;

        for (uint i = 0; i < 10; i++) {
            uint randomNum = uint(keccak256(abi.encode(seedBytes[i * interval])));
            flips[i] = uint8(randomNum % 2); // Even -> 0, Odd -> 1
        }

        return flips;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
