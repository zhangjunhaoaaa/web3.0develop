// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//补充完整 Caller 合约 的 delegateSetValue 方法，调用 Callee 的 setValue 方法用于设置 value 值。要求：
//
//使用 delegatecall
//如果发送失败，抛出“delegate call failed”异常并回滚交易。

contract Callee {
    uint256 public value;

    function setValue(uint256 _newValue) public {
        value = _newValue;
    }
}

contract Caller {
    uint256 public value;

    function delegateSetValue(address callee, uint256 _newValue) public {
        // Encoding the function call
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", _newValue);

        // Performing the delegatecall
        (bool success, ) = callee.delegatecall(data);

        // Check for success and revert if failed
        require(success, "delegate call failed");
    }
}


