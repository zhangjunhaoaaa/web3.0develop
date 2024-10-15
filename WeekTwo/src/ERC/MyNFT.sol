// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Use the ERC721 standard (reusable OpenZepplin library) to issue your own NFT contract and mint several NFTs with pictures.
//Please upload the images and Meta Json data to the decentralized storage service, and please post the NFT link in OpenSea.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    string public baseTokenURI;

    constructor(string memory _baseTokenURI) ERC721("MyNFT", "MNFT") {
        baseTokenURI = _baseTokenURI;
    }

    function mintTo(address recipient) public onlyOwner {
        uint256 tokenId = nextTokenId;
        _mint(recipient, tokenId);
        nextTokenId++;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }
}
