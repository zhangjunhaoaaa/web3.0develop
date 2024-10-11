// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public admin; // Administrator address
    mapping(address => uint256) public deposits; // Records the deposit amount of each address
    address[3] public topDepositors; // Addresses of the top 3 depositors by amount

    constructor() {
        admin = msg.sender; // The address deploying the contract is set as the administrator
    }

    // Fallback function to receive ETH deposits, can deposit directly to the contract address via Metamask or other wallets
    receive() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        // Update the deposit amount of the user
        deposits[msg.sender] += msg.value;

        // Update the top 3 depositors
        updateTopDepositors(msg.sender);
    }

    // Withdraw funds, only the administrator can call this method
    function withdraw(uint256 amount) external {
        require(msg.sender == admin, "Only admin can withdraw");
        require(amount <= address(this).balance, "Insufficient contract balance");

        payable(admin).transfer(amount);
    }

    // Update the top 3 depositors
    function updateTopDepositors(address depositor) internal {
        // Current deposit amount of the user
        uint256 depositorAmount = deposits[depositor];

        for (uint256 i = 0; i < topDepositors.length; i++) {
            if (topDepositors[i] == depositor) {
                // If the current user is already in the top 3, sort the list
                sortTopDepositors();
                return;
            }
        }

        // If the current user is not in the top 3
        for (uint256 i = 0; i < topDepositors.length; i++) {
            if (deposits[topDepositors[i]] < depositorAmount) {
                // If the current user's deposit is more than any of the top 3, update the array and sort
                topDepositors[i] = depositor;
                sortTopDepositors();
                return;
            }
        }
    }

    // Sort the top 3 depositors
    function sortTopDepositors() internal {
        for (uint256 i = 0; i < topDepositors.length - 1; i++) {
            for (uint256 j = 0; j < topDepositors.length - i - 1; j++) {
                if (deposits[topDepositors[j]] < deposits[topDepositors[j + 1]]) {
                    address temp = topDepositors[j];
                    topDepositors[j] = topDepositors[j + 1];
                    topDepositors[j + 1] = temp;
                }
            }
        }
    }

    // Get the contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Get the addresses of the top 3 depositors
    function getTopDepositors() external view returns (address[3] memory) {
        return topDepositors;
    }
}
