// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MyToken
 * @dev A simple ERC20 token for the lending platform.
 * The entire initial supply is minted to the deployer of the contract.
 */
contract MyToken is ERC20 {
    /**
     * @dev Sets the values for {name}, {symbol}, and {decimals}.
     * Mints the initial supply of tokens to the contract deployer.
     * @param _initialSupply The total amount of tokens to be minted upon deployment.
     */
    constructor(uint256 _initialSupply) ERC20("MyToken", "MTK") {
        // Mint the initial supply of tokens to the address that deployed the contract.
        // The `_initialSupply` should be provided with 18 decimals in mind.
        // For example, to mint 1,000 tokens, the input should be 1000 * 10 ** 18.
        _mint(msg.sender, _initialSupply);
    }
}