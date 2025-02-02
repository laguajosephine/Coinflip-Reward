// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error SeedTooShort();

contract CoinflipV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    string public seed;
    IERC20 public dauToken; // Reference to the Dauphine (DAU) token

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address dauTokenAddress) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __Ownable_init_unchained(initialOwner);
        _transferOwnership(initialOwner);

        seed = "It is a good practice to rotate seeds often in gambling"; // Default seed value
        dauToken = IERC20(dauTokenAddress); // Set DAU token contract
    }

    /// @notice Checks user input against contract generated guesses
    /// @param Guesses is a fixed array of 10 elements which holds the user's guesses. The guesses are either 1 or 0 for heads or tails
    /// @param winnerAddress is the wallet address that will receive rewards if the user wins
    /// @return true if user correctly guesses each flip, otherwise false
    function userInput(uint8[10] calldata Guesses, address winnerAddress) external returns (bool) {
        uint8[10] memory generatedFlips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != generatedFlips[i]) {
                return false;
            }
        }

        // If the user wins, reward them with DAU tokens
        RewardUser(winnerAddress);
        return true;
    }

    /// @notice allows the owner of the contract to change the seed to a new one, with rotation
    /// @param NewSeed is a string which represents the new seed
    /// @param rotations is the number of times to rotate the seed string
    function seedRotation(string memory NewSeed, uint rotations) public onlyOwner {
        bytes memory newSeedBytes = bytes(NewSeed);
        uint seedLength = newSeedBytes.length;

        if (seedLength < 10) {
            revert SeedTooShort();
        }

        // Normalize the number of rotations in case it's greater than the seed length
        rotations = rotations % seedLength;

        // Perform the rotation logic
        if (rotations > 0) {
            bytes memory rotatedSeed = new bytes(seedLength);
            for (uint i = 0; i < seedLength; i++) {
                rotatedSeed[i] = newSeedBytes[(i + seedLength - rotations) % seedLength];
            }
            seed = string(rotatedSeed);
        } else {
            seed = NewSeed;
        }
    }

    /// @notice Rewards the user with 5 DAU tokens
    /// @param winnerAddress The address of the user who won
    function RewardUser(address winnerAddress) internal {
        require(winnerAddress != address(0), "Invalid address");
        require(dauToken.transfer(winnerAddress, 5 * 10**18), "Reward transfer failed");
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
