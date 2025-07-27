# Decentralized Lending Platform (Solidity & Ethereum)

This project is a decentralized lending platform developed on the Ethereum blockchain using Solidity. It demonstrates fundamental concepts of DeFi, including ERC20 token management, lending, borrowing, repayment with interest, and collateral management using Ether. The platform is designed to run and be interacted with within the Remix Ethereum IDE.

## Project Goals

The primary goals of this project include:
* Understanding and implementing ERC20 token standards (`MyToken`).
* Developing core lending and borrowing logic (`LendingPlatform`).
* Implementing a collateral mechanism using Ether (`LendingPlatformWithCollateral`) to secure loans.
* Gaining practical experience with smart contract deployment and interaction on a simulated blockchain environment (Remix VM).
* Applying security best practices such as the Checks-Effects-Interactions (CEI) pattern to prevent common vulnerabilities like reentrancy.
* Utilizing essential Solidity system variables like `msg.sender` and `block.timestamp` for transaction context and loan duration calculations.

## Features

* **ERC20 Token Creation:** Custom `MyToken` for platform transactions.
* **Token Lending:** Users can lend `MyToken` to the platform.
* **Token Borrowing:** Users can borrow `MyToken` from the platform, requiring ETH collateral.
* **Loan Repayment:** Borrowers can repay their loans, including accrued interest based on loan duration.
* **ETH Collateral Management:**
    * Deposit Ether as collateral.
    * Withdraw Ether collateral once loans are fully repaid.
* **Interest Calculation:** Simple annual interest calculation based on loan duration.

## Technologies Used

* **Solidity:** Smart Contract Programming Language (`^0.8.0`)
* **Ethereum Blockchain:** Underlying network (simulated using Remix VM)
* **Remix Ethereum IDE:** For development, compilation, deployment, and interaction.
* **OpenZeppelin Contracts:** For secure and standard ERC20 implementation.

## Contract Structure

The project comprises three Solidity smart contracts:

1.  **`MyToken.sol`**
    * An ERC20 compliant token.
    * Mints an initial supply to the contract deployer.
    * Serves as the primary asset for lending and borrowing within the platform.

2.  **`LendingPlatform.sol`**
    * The foundational lending logic.
    * Allows users to `lend`, `borrow`, and `repay` `MyToken`.
    * Calculates interest on loans.
    * (Note: This contract is included as per assignment requirements, but the `LendingPlatformWithCollateral.sol` is the primary focus for advanced features).

3.  **`LendingPlatformWithCollateral.sol`**
    * Extends the `LendingPlatform` functionality by requiring ETH collateral for borrowing.
    * Includes functions for `depositCollateral()` and `withdrawCollateral()`.
    * The `borrow()` function enforces a collateral requirement.

## Deployment Guide (Using Remix IDE)

To deploy and interact with the contracts, follow these steps in Remix:

1.  **Open Remix IDE:** Go to [Remix Ethereum IDE](https://remix.ethereum.org/).
2.  **Create Files:** In the "File Explorers" tab, create the three files: `MyToken.sol`, `LendingPlatform.sol`, and `LendingPlatformWithCollateral.sol`, and paste the respective code into them.
3.  **Compile Contracts:**
    * Go to the "Solidity Compiler" tab (third icon on the left).
    * Ensure the compiler version is `0.8.0` or compatible.
    * Compile `MyToken.sol`, `LendingPlatform.sol`, and `LendingPlatformWithCollateral.sol` one by one.
4.  **Go to "Deploy & Run Transactions" Tab:**
    * Click the "Deploy & Run Transactions" tab (fourth icon on the left).
    * Set "ENVIRONMENT" to **"Remix VM Cancun"**.
    * Ensure an account with sufficient ETH is selected (the default Remix VM accounts come pre-funded).

### Deployment Order:

#### 1. Deploy `MyToken.sol`
* Select `MyToken` from the `CONTRACT` dropdown.
* In the `_initialSupply` field, enter `1000000000000000000000` (for 1000 tokens with 18 decimals).
* Click **"Deploy"**.
* **Important:** Copy the address of the newly deployed `MyToken` contract from the "Deployed Contracts" section.

#### 2. Deploy `LendingPlatform.sol` (Optional, for full assignment compliance)
* Select `LendingPlatform` from the `CONTRACT` dropdown.
* In the constructor fields:
    * `_token`: Paste the address of your deployed `MyToken` contract.
    * `_interestRate`: Enter `5` (for 5%).
* Click **"Deploy"**.

#### 3. Deploy `LendingPlatformWithCollateral.sol` (Main platform for testing)
* Select `LendingPlatformWithCollateral` from the `CONTRACT` dropdown.
* In the constructor fields:
    * `_token`: Paste the address of your deployed `MyToken` contract.
    * `_interestRate`: Enter `5` (for 5%).
* Click **"Deploy"**.

## Interaction Guide (Testing the Collateralized Platform)

We will use two Remix VM accounts to simulate interaction:
* **Account 1 (Lender):** The first default account (e.g., `0x5B38...`). This account initially holds all `MyToken`s.
* **Account 2 (Borrower):** The second default account (e.g., `0xAb84...`). This account will deposit ETH collateral and borrow `MyToken`.

#### 1. User 1 (Lender) Lends Tokens to `LendingPlatformWithCollateral`

* **Ensure Account 1 is selected** in the "ACCOUNT" dropdown.
* **Approve Tokens (on `MyToken` contract):**
    * Expand your deployed `MyToken` contract.
    * Call `approve(spender: LendingPlatformWithCollateral_Address, amount: 500000000000000000000)` (for 500 MyTokens). Transact.
* **Lend Tokens (on `LendingPlatformWithCollateral` contract):**
    * Expand your deployed `LendingPlatformWithCollateral` contract.
    * Call `lend(_amount: 500000000000000000000)`. Transact.
    * (Verify `MyToken` balance of `LendingPlatformWithCollateral` and `lendingBalance` of Account 1).

#### 2. User 2 (Borrower) Deposits ETH Collateral

* **Switch to Account 2** in the "ACCOUNT" dropdown.
* **Deposit Collateral (on `LendingPlatformWithCollateral` contract):**
    * In the "Value" field (near the Account dropdown), enter `2` and set units to "Ether".
    * Call `depositCollateral()`. Transact.
    * (Verify `ethCollateral` of Account 2).

#### 3. User 2 (Borrower) Borrows Tokens

* **Ensure Account 2 is selected.**
* **Borrow Tokens (on `LendingPlatformWithCollateral` contract):**
    * Call `borrow(_amount: 100000000000000000)` (for 0.1 MyToken). Transact.
    * (Verify `borrowingBalance` and `borrowStartTime` of Account 2, and `MyToken` balance of Account 2).

#### 4. User 2 (Borrower) Repays Loan

* **Ensure Account 2 is selected.**
* *(Optional: Allow some time to pass to accrue noticeable interest.)*
* **Approve Repayment (on `MyToken` contract):**
    * Expand your deployed `MyToken` contract.
    * Call `approve(spender: LendingPlatformWithCollateral_Address, amount: 150000000000000000)` (for 0.15 MyToken to cover principal + interest and potential gas). **Ensure Account 2 has sufficient MyTokens in its balance to cover this amount** (you might need Account 1 to `transfer` more `MyToken` to Account 2 if its balance is just the borrowed amount). Transact.
* **Repay Loan (on `LendingPlatformWithCollateral` contract):**
    * Call `repay()`. Transact.
    * (Verify `borrowingBalance` and `borrowStartTime` of Account 2 are reset to 0).

#### 5. User 2 (Borrower) Withdraws ETH Collateral

* **Ensure Account 2 is selected.**
* **Withdraw Collateral (on `LendingPlatformWithCollateral` contract):**
    * Call `withdrawCollateral(_amount: 2000000000000000000)` (for 2 Ether in Wei). Transact.
    * (Verify `ethCollateral` of Account 2 is 0, and Account 2's ETH balance has increased).

## Security and Best Practices

* **Checks-Effects-Interactions (CEI) Pattern:** All critical functions (`lend`, `borrow`, `repay`, `withdrawCollateral`) strictly follow the CEI pattern. State changes are applied *before* any external calls are made, significantly mitigating reentrancy vulnerabilities.
* **Input Validation:** Robust `require` statements are used to validate function parameters and ensure proper contract state transitions.
* **Clear Code and Comments:** The codebase is designed for high readability with comprehensive NatSpec and inline comments, detailing logic flow and security considerations.

## Potential Enhancements / Future Work

* **Collateralization Ratio Enforcement:** Implement a more dynamic collateral check in `borrow` that uses a configurable ratio (e.g., 150%) relative to the loan amount, instead of just checking for existence of collateral. This would require integrating a price oracle (e.g., Chainlink) for real-time asset valuation in a production environment.
* **Proportional Collateral Release:** Enhance the `repay` function to directly release a proportional amount of collateral to the borrower as the loan is repaid, rather than requiring a separate `withdrawCollateral` call for the full amount post-repayment.
* **Events:** Emit events for key actions (e.g., `LoanBorrowed`, `CollateralDeposited`) to provide easily trackable data for off-chain applications and analytics.
* **Access Control/Admin Functions:** Introduce modifiers (e.g., `onlyOwner` from OpenZeppelin) for potential administrative functions like updating the interest rate.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Acknowledgements

* [Remix Ethereum IDE](https://remix.ethereum.org/) - For providing an excellent browser-based development environment.
* [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/4.x/) - For battle-tested smart contract implementations, particularly the ERC20 standard.
