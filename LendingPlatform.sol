// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title LendingPlatform
 * @dev A simple platform for lending and borrowing a specific ERC20 token.
 * Interest is calculated annually.
 */
contract LendingPlatform {
    // --- State Variables ---

    /**
     * @notice The ERC20 token contract used for transactions within the platform.
     */
    IERC20 public token;

    /**
     * @notice The annual interest rate for borrowing.
     * @dev Stored as a percentage, e.g., 5 for 5%.
     */
    uint256 public interestRate;

    /**
     * @notice Maps a user's address to the amount of tokens they have lent.
     */
    mapping(address => uint256) public lendingBalance;

    /**
     * @notice Maps a user's address to the amount of tokens they have borrowed.
     */
    mapping(address => uint256) public borrowingBalance;

    /**
     * @notice Maps a user's address to the timestamp when their borrow period began.
     * @dev Used to calculate the duration of the loan for interest.
     */
    mapping(address => uint256) public borrowStartTime;

    // --- Constructor ---

    /**
     * @dev Initializes the contract by setting the token and interest rate.
     * @param _token The contract address of the ERC20 token for lending/borrowing.
     * @param _interestRate The annual interest rate for loans (e.g., 5 for 5%).
     */
    constructor(IERC20 _token, uint256 _interestRate) {
        token = _token;
        interestRate = _interestRate;
    }

    /**
     * @notice Allows a user to lend tokens to the platform.
     * @dev The user must first approve this contract to spend their tokens.
     * The function follows the checks-effects-interactions pattern for security.
     * @param _amount The amount of tokens to lend.
     */
    function lend(uint256 _amount) public {
        // Check: Ensure the amount to lend is greater than zero.
        require(_amount > 0, "Lend amount must be greater than zero");

        // Effect: Update the user's lending balance before the transfer.
        lendingBalance[msg.sender] += _amount;

        // Interaction: Transfer the specified amount of tokens from the user to this contract.
        // Note: The user (msg.sender) must have already called 'approve' on the MyToken
        // contract, giving this platform address permission to transfer their tokens.
        token.transferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @notice Allows a user to borrow tokens from the platform.
     * @dev A user cannot borrow if they have an existing outstanding loan.
     * The platform must have sufficient liquidity to cover the loan.
     * @param _amount The amount of tokens to borrow.
     */
    function borrow(uint256 _amount) public {
        // --- Checks ---
        // Ensure the amount to borrow is greater than zero.
        require(_amount > 0, "Borrow amount must be greater than zero");
        // Ensure the user does not have an existing loan.
        require(borrowingBalance[msg.sender] == 0, "You already have an outstanding loan");
        // Ensure the contract has enough tokens to lend out.
        require(token.balanceOf(address(this)) >= _amount, "Not enough tokens in the platform");

        // --- Effects ---
        // Update the user's borrowing balance.
        borrowingBalance[msg.sender] = _amount;
        // Record the start time of the loan for interest calculation.
        borrowStartTime[msg.sender] = block.timestamp;

        // --- Interaction ---
        // Transfer the tokens from this contract to the user.
        token.transfer(msg.sender, _amount);
    }

    /**
     * @notice Calculates the interest accrued on a loan based on its duration.
     * @dev This is a view function that does not modify state and can only be called internally.
     * The formula used is: interest = (Principal * AnnualRate * DurationInSeconds) / (SecondsInYear * 100).
     * @param _amount The principal amount of the loan.
     * @param _duration The duration of the loan in seconds.
     * @return uint256 The calculated interest amount.
     */
    function calculateInterest(uint256 _amount, uint256 _duration) internal view returns (uint256) {
        // The formula for interest calculation as specified in the project.
        // We divide by (365 days) to scale the annual interest rate to the loan's duration in seconds.
        // We divide by 100 because the interestRate is stored as a whole number (e.g., 5 for 5%).
        uint256 interest = (_amount * interestRate * _duration) / (365 days * 100);
        return interest;
    }

    /**
     * @notice Repays an outstanding loan along with accrued interest.
     * @dev The user must first approve this contract to spend the total repayment amount.
     * Resets the user's borrow balance and start time upon successful repayment.
     */
    function repay() public {
        // --- Setup & Checks ---
        uint256 borrowedAmount = borrowingBalance[msg.sender];
        uint256 startTime = borrowStartTime[msg.sender];

        // Ensure the user has an outstanding loan.
        require(borrowedAmount > 0, "You do not have a loan to repay");

        // --- Calculations ---
        // Calculate the loan's duration in seconds.
        uint256 duration = block.timestamp - startTime;
        // Use the helper function to calculate the interest owed.
        uint256 interest = calculateInterest(borrowedAmount, duration);
        // Determine the total repayment amount.
        uint256 totalRepayment = borrowedAmount + interest;

        // --- Effects ---
        // Reset the user's borrowing state *before* the external call to prevent re-entrancy.
        borrowingBalance[msg.sender] = 0;
        borrowStartTime[msg.sender] = 0;

        // --- Interaction ---
        // Pull the total repayment amount from the user's wallet to this contract.
        // The user must have called 'approve' on MyToken for at least `totalRepayment`.
        token.transferFrom(msg.sender, address(this), totalRepayment);
    }
}