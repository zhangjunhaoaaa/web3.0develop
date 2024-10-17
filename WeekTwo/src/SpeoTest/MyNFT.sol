// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract MyNFT is ERC721{
    uint256 public nextTokenId;
    string public baseTokenURI;
    address public owner;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        owner = msg.sender;
        baseTokenURI = "";
    }

    function mintTo(address recipient) public  {
        require(owner == msg.sender , "no contracts");
        uint256 tokenId = nextTokenId;
        _mint(recipient, tokenId);
        nextTokenId++;
    }

    function _baseURI() internal override view returns (string memory) {
        return baseTokenURI;
    }
}
