// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract FirstContract{

    constructor(){

    }

    uint256 public counter;


    function  getCounter() public view returns (uint256){
        return  counter;
    }


    function add(uint256 x) public {
        counter +=x;
    }

}