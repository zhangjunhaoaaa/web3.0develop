// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//补充完整 Caller 合约的 callGetData 方法，使用 staticcall 调用 Callee 合约中 getData 函数，并返回值。
//当调用失败时，抛出“staticcall function failed”异常。

contract Callee {
    function getData() public pure returns (uint256) {
        return 42;
    }
}

contract Caller {
    function callGetData(address callee) public view returns (uint256 data) {
        (bool success, bytes memory returnedData) = callee.staticcall(
            abi.encodeWithSignature("getData()")
        );
        require(success, "staticcall function failed");

        data = abi.decode(returnedData, (uint256));
    }
}
