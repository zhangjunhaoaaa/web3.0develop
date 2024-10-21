// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 定义一个多签钱包合约
contract MultiSigWallet {
    // 钱包的所有者地址数组
    address[] public owners;
    // 达到执行交易所需的确认数量
    uint public threshold;
    // 用于检查是否为所有者的映射
    mapping(address => bool) public isOwner;

    // 定义提案结构体
    struct Proposal {
        address to; // 接收地址
        uint value; // 转账金额
        bytes data; // 调用数据
        bool executed; // 是否已执行
        uint confirmations; // 确认数
    }

    // 提案数组
    Proposal[] public proposals;
    // 每个提案的确认情况
    mapping(uint => mapping(address => bool)) public confirmations;

    // 仅允许所有者调用的修饰符
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    // 合约构造函数，初始化所有者和确认门槛
    constructor(address[] memory _owners, uint _threshold) {
        require(_owners.length > 0, "Owners required");
        require(_threshold > 0 && _threshold <= _owners.length, "Invalid threshold");

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        threshold = _threshold;
    }

    // 提交一个新的提案
    function submitProposal(address _to, uint _value, bytes memory _data) public onlyOwner {
        proposals.push(Proposal({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            confirmations: 0
        }));
    }

    // 确认一个提案
    function confirmProposal(uint _index) public onlyOwner {
        Proposal storage proposal = proposals[_index];
        require(!confirmations[_index][msg.sender], "Proposal already confirmed");
        require(!proposal.executed, "Proposal already executed");

        confirmations[_index][msg.sender] = true;
        proposal.confirmations += 1;
    }

    // 执行一个已确认的提案
    function executeProposal(uint _index) public {
        Proposal storage proposal = proposals[_index];
        require(proposal.confirmations >= threshold, "Not enough confirmations");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        (bool success, ) = proposal.to.call{value: proposal.value}(proposal.data);
        require(success, "Transaction failed");
    }

    // 接受ETH的函数
    receive() external payable {}
}
