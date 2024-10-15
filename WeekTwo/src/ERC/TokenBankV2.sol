// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Extend the ERC20 contract and add a transfer function with a hook function. For example, the function name is: transferWithCallback. During the transfer, if the target address is the contract address, the tokensReceived() method of the target address is called.
//Inherit TokenBank and write TokenBankV2, which supports the storage of extended ERC20 Token. Users can directly call transferWithCallback to save the extended ERC20 Token into TokenBankV2.
//(Note: TokenBankV2 needs to implement tokensReceived to implement deposit recording)

interface IERC777Receiver {
    function tokensReceived(address operator, address from, address to, uint256 amount, bytes calldata userData, bytes calldata operatorData) external;
}

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100_000_000 * (10 ** uint256(decimals));

        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function transferWithCallback(address _to, uint256 _value, bytes calldata _data) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        if (isContract(_to)) {
            IERC777Receiver(_to).tokensReceived(
                msg.sender,
                msg.sender,
                _to,
                _value,
                _data,
                "");
        }

        return true;
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

contract TokenBankV2 is IERC777Receiver {
    BaseERC20 public token;
    mapping(address => uint256) public deposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _tokenAddress) {
        token = BaseERC20(_tokenAddress);
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        require(msg.sender == address(token), "Invalid token");

        deposits[from] += amount;
        emit Deposit(from, amount);
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Deposit amount must be greater than zero");
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        deposits[msg.sender] += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Withdraw amount must be greater than zero");
        require(deposits[msg.sender] >= _amount, "Insufficient balance in TokenBankV2");

        deposits[msg.sender] -= _amount;
        require(token.transfer(msg.sender, _amount), "Token transfer failed");

        emit Withdraw(msg.sender, _amount);
    }
}
