// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank bank;

    function setUp() public {
        bank = new Bank();
    }

    function testDepositETH() public {
        //初始化变量 user 为一个地址，initialBalance 为用户在合约中的初始余额。
        address user = address(111111);
        uint initialBalance = bank.balanceOf(user);
        ////设置存款金额 depositAmount 为 1 ether。
        uint depositAmount = 1 ether;

        //使用 vm.label 为用户地址添加标签，方便调试。
        vm.label(user, "User");

        //使用 vm.expectEmit 设置预期的 Deposit 事件，确保事件参数与实际参数匹配。
        vm.expectEmit(true, true, false, true);
        emit Bank.Deposit(user, depositAmount);

        //使用 vm.prank 模拟 user 进行交易。
        vm.prank(user);

        // 调用 depositETH 函数进行存款操作。
        bank.depositETH{value: depositAmount}();

        // 断言存款后的余额是否符合预期。
        uint finalBalance = bank.balanceOf(user);
        assertEq(finalBalance, initialBalance + depositAmount, "Balance after deposit is incorrect");

        // Debugging logs
        emit log_named_uint("Initial Balance", initialBalance);
        emit log_named_uint("Deposit Amount", depositAmount);
        emit log_named_uint("Final Balance", finalBalance);
    }
}
