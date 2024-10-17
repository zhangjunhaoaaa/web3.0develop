// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket  {
    struct Listing {
        address seller;
        uint256 price;
    }

    IERC20 public paymentToken;
    IERC721 public nftContract;

    mapping(uint256 => Listing) public listings;

    event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event Purchased(address indexed buyer, uint256 indexed tokenId, uint256 price);

    constructor(address _paymentTokenAddress, address _nftContractAddress) {
        paymentToken = IERC20(_paymentTokenAddress);
        nftContract = IERC721(_nftContractAddress);
    }


    //Listing functionality, allowing NFT holders to list their NFTs and set a price.
    function list(uint256 tokenId, uint256 price) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "NFTMarket: Only the owner can list the NFT");
        require(price > 0, "NFTMarket: Price must be greater than zero");

        //transfer NFT To MarketContract
        nftContract.transferFrom(msg.sender, address(this), tokenId);

        listings[tokenId] = Listing({seller: msg.sender, price: price});

        emit Listed(msg.sender, tokenId, price);
    }


    //Purchase function that allows users to pay a specified number of tokens to purchase NFTs.
    function buyNFT(uint256 tokenId) public {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "NFTMarket: NFT is not listed");
        require(paymentToken.transferFrom(msg.sender, listing.seller, listing.price), "NFTMarket: Payment token transfer failed");
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        delete listings[tokenId];
        emit Purchased(msg.sender, tokenId, listing.price);
    }


    //Implement the receiver method required by ERC20 extended Token.
    function tokensReceived(
        address /*operator*/,
        address from,
        address /*to*/,
        uint256 amount,
        bytes calldata userData,
        bytes calldata /*operatorData*/
    ) external  {
        require(msg.sender == address(paymentToken), "NFTMarket: Invalid token");

        uint256 tokenId = abi.decode(userData, (uint256));
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "NFTMarket: NFT is not listed");
        require(amount == listing.price, "NFTMarket: Incorrect payment amount");

        nftContract.transferFrom(address(this), from, tokenId);

        delete listings[tokenId];

        emit Purchased(from, tokenId, listing.price);
    }
}
