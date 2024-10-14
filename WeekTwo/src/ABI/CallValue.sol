// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

//补充完整 Caller 合约的 callSetValue 方法，用于设置 Callee 合约的 value 值。要求：
//
//使用 call 方法调用用 Callee 的 setValue 方法，并附带任意 Ether
//如果发送失败，抛出“call function failed”异常并回滚交易。
//如果发送成功，则返回 true

contract Callee {
    uint256 value;

    function getValue() public view returns(uint256){
        return value;
    }

    function setValue(uint256 value_)public payable{
        require(msg.value>0);
        value=value_;
    }

}


contract Caller{

    function callSetValue(address callee,uint256  value) public payable returns(bool){
        bytes memory payload=abi.encodeWithSignature("setValue(uint256)",value);

        uint256  ethValue = msg.value > 0 ? msg.value : 1 ether;

        (bool success,)= callee.call{value:ethValue}(payload);

        require(success,"call function failed");

        return success;
    }


    receive() external payable{}
}

//test example
//pragma solidity ^0.8.0;
//
//import {Test} from "forge-std/Test.sol";
//
//contract TestContract is Test {
//    Callee public callee;
//    Caller public caller;
//
//    function setUp() public {
//        callee = new Callee();
//        caller = new Caller();
//    }
//
//    function testFuzz_callSetValue(uint256 x) public {
//        // 发送 ether 给 caller
//        vm.deal(address(caller), 1 ether);
//
//        bool success = caller.callSetValue(address(callee), x);
//
//        assertEq(success, true);
//        assertEq(x, callee.getValue());
//    }
//
//    function test_should_fail_when_not_enough_ether(uint256 x, uint256 etherVallue) public {
//        vm.assume(etherVallue < 1 ether);
//
//        // 发送 ether 给 caller
//        vm.deal(address(caller), etherVallue);
//
//        vm.expectRevert("call function failed");
//
//        // caller 发送 ether
//        caller.callSetValue(address(callee), x);
//    }
//}