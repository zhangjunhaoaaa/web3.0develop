// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function deposit() external payable;
    function withdraw() external;
}

abstract contract Bank is IBank {
    mapping(address => uint256) private balances;

    function deposit() public payable override virtual  {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public override {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance");
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }

    function getBalance(address account) public view returns (uint256) {
        return balances[account];
    }
}


contract BigBank is Bank {
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    modifier minDeposit() {
        require(msg.value > 0.001 ether, "Deposit must be more than 0.001 ether");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function transferAdmin(address newAdmin) public onlyAdmin{
        require(newAdmin != address(0), "New admin is the zero address");
        admin = newAdmin;
    }


    function deposit() public payable override minDeposit {
        super.deposit();
    }
}



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function deposit() external payable;
    function withdraw() external;
}

contract Admin {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function adminWithdraw(IBank bank) public onlyOwner {
        bank.withdraw();
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}

//### Deployment and Operation Workflow
//
//1. **Deploy the  `BigBank`, and `Admin` contracts**:
//   - First, deploy the `BigBank` contract and obtain its address.
//   - Second, deploy the `Admin` contract and obtain its address.
//
//2. **Transfer Administrator Privilege**:
//   - Call the `transferAdmin` function of the `BigBank` contract to set the administrator address to the `Admin` contract's address.
//
//3. **Simulate User Deposits**:
//   - Multiple users call the `deposit` function of the `BigBank` contract to make deposits, with each deposit amount being greater than 0.001 ether.
//
//4. **Administrator Withdrawal**:
//   - The owner address of the `Admin` contract calls the `adminWithdraw` function to transfer the funds from the `BigBank` to the `Admin` contract's address.



