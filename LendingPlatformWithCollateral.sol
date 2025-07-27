// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title LendingPlatformWithCollateral
 * @dev A lending platform that requires users to deposit ETH as collateral.
 */
contract LendingPlatformWithCollateral {
    // --- State Variables ---
    IERC20 public token;
    uint256 public interestRate;

    mapping(address => uint256) public lendingBalance;
    mapping(address => uint256) public borrowingBalance;
    mapping(address => uint256) public borrowStartTime;

    /**
     * @notice New mapping to track the ETH collateral deposited by each user.
     * @dev Collateral is stored in Wei (the smallest unit of Ether).
     */
    mapping(address => uint256) public ethCollateral;


    // --- Constructor ---
    /**
     * @dev Initializes the contract with the token address and interest rate.
     * @param _token The address of the ERC20 token contract.
     * @param _interestRate The annual interest rate (e.g., 5 for 5%).
     */
    constructor(IERC20 _token, uint256 _interestRate) {
        token = _token;
        interestRate = _interestRate;
    }

    /**
     * @notice Allows a user to deposit ETH to be used as collateral.
     * @dev This function is marked as `payable` to enable it to receive Ether.
     * The amount of ETH sent with the transaction (`msg.value`) is added
     * to the user's collateral balance.
     */
    function depositCollateral() public payable {
        // Ensure the user is depositing a positive amount of Ether.
        require(msg.value > 0, "Collateral deposit must be greater than zero");

        // Increase the user's collateral balance by the amount of Ether they sent.
        ethCollateral[msg.sender] += msg.value;
    }

    /**
     * @notice Allows a user to withdraw their deposited ETH collateral.
     * @dev A user cannot withdraw any collateral if they have an outstanding loan.
     * This function follows the checks-effects-interactions pattern for security.
     * @param _amount The amount of ETH (in Wei) to withdraw.
     */
    function withdrawCollateral(uint256 _amount) public {
        // --- Checks ---
        // Ensure the user has enough collateral to cover the withdrawal.
        require(ethCollateral[msg.sender] >= _amount, "Withdrawal amount exceeds collateral balance");
        
        // CRITICAL CHECK: Ensure the user has no outstanding debt before allowing withdrawal.
        require(borrowingBalance[msg.sender] == 0, "Cannot withdraw collateral with an outstanding loan");

        // --- Effects ---
        // Decrease the user's collateral balance *before* the transfer to prevent re-entrancy attacks.
        ethCollateral[msg.sender] -= _amount;

        // --- Interaction ---
        // Send the specified amount of Ether to the user.
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    /**
     * @notice Allows a user with collateral to borrow tokens from the platform.
     * @dev The user must have deposited ETH collateral to be eligible for a loan.
     * @param _amount The amount of tokens to borrow.
     */
    function borrow(uint256 _amount) public {
        // --- Checks ---
        require(_amount > 0, "Borrow amount must be greater than zero");
        require(borrowingBalance[msg.sender] == 0, "You already have an outstanding loan");
        require(token.balanceOf(address(this)) >= _amount, "Not enough tokens in the platform");
        
        // --- NEW COLLATERAL CHECK ---
        // In a real-world platform, you'd use a price oracle here to ensure the
        // value of the collateral exceeds the value of the loan by a set ratio.
        // For this project, we'll keep it simple and just check that some collateral exists.
        require(ethCollateral[msg.sender] > 0, "No collateral deposited");

        // --- Effects ---
        // Update the user's borrowing balance and record the start time.
        borrowingBalance[msg.sender] = _amount;
        borrowStartTime[msg.sender] = block.timestamp;

        // --- Interaction ---
        // Transfer the tokens from this contract to the user.
        token.transfer(msg.sender, _amount);
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