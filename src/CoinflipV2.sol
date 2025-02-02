// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

error SeedTooShort();

/// @title Coinflip 10 in a Row (UUPS Upgradable)
/// @author Tianchan Dong
/// @notice Contract used as part of the course Solidity and Smart Contract development
contract CoinflipV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    
    string public seed;

    /// @dev Replaces constructor for UUPS upgradability
    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    /// @notice Checks user input against contract generated guesses
    /// @param Guesses A fixed array of 10 elements (1 for heads, 0 for tails)
    /// @return True if user correctly guesses all flips, false otherwise
    function userInput(uint8[10] calldata Guesses) external view returns (bool) {
        uint8[10] memory generatedFlips = getFlips();

        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != generatedFlips[i]) {
                return false;
            }
        }
        return true;
    }

    /// @notice Allows the owner to change the seed
    /// @param NewSeed The new seed string
    function seedRotation(string memory NewSeed) public onlyOwner {
        bytes memory seedBytes = bytes(NewSeed);
        if (seedBytes.length < 10) {
            revert SeedTooShort();
        }
        seed = NewSeed;
    }

    /// @notice Generates 10 random flips by hashing characters of the seed
    /// @return A fixed 10-element array of uint8 values (1 or 0)
    function getFlips() public view returns (uint8[10] memory) {
        bytes memory seedBytes = bytes(seed);
        uint seedLength = seedBytes.length;
        uint8[10] memory flips;

        uint interval = seedLength / 10;
        for (uint i = 0; i < 10; i++) {
            uint randomNum = uint(keccak256(abi.encode(seedBytes[i * interval], block.timestamp)));
            flips[i] = (randomNum % 2 == 0) ? 1 : 0;
        }
        return flips;
    }

    /// @dev Required for UUPS upgradability, restricts upgrades to the owner
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}