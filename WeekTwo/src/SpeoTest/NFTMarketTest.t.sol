// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "ds-test/test.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "../src/MyNFT.sol"; 
import "../src/NFTMarket.sol";
import "forge-std/Vm.sol"; 


contract ERC20Mock is ERC20 {
    constructor() ERC20("Test Token", "TTK") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}

// 测试合约
contract NFTMarketTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS); // 获取虚拟机实例

    MyNFT public nft; // NFT合约实例
    ERC20Mock public token; // 模拟的ERC20代币合约实例
    NFTMarket public market; // NFT市场合约实例
    address public owner; // 合约所有者
    address public addr1; // 测试地址1
    address public addr2; // 测试地址2

    // 初始化函数
    function setUp() public {
        owner = address(this); // 合约部署者地址
        addr1 = address(1); // 设置测试地址1
        addr2 = address(2); // 设置测试地址2

        nft = new MyNFT("TestNFT", "TNFT"); // 部署NFT合约
        token = new ERC20Mock(); // 部署模拟ERC20代币合约
        market = new NFTMarket(address(token), address(nft)); // 部署NFT市场合约

        nft.mintTo(owner); // 给合约部署者铸造一个NFT
        nft.mintTo(addr1); // 给测试地址1铸造一个NFT
    }

    // 测试上架NFT成功
    //forge test --match-path test/NFTMarketTest.t.sol --match-test testListNFT

    function testListNFT() public {
        uint256 tokenId = 0;
        nft.approve(address(market), tokenId); // 批准市场合约管理NFT
        market.list(tokenId, 100 * 10 ** 18); // 上架NFT，价格为100 TTK

        (address seller, uint256 price) = market.listings(tokenId); // 获取上架信息
        assertEq(seller, owner); // 验证卖家地址
        assertEq(price, 100 * 10 ** 18); // 验证上架价格
    }

    // 测试非所有者上架NFT失败
    function testFailListNFTNotOwner() public {
        uint256 tokenId = 0;
        vm.prank(addr1); // 模拟由测试地址1调用
        market.list(tokenId, 100 * 10 ** 18); // 尝试上架NFT
    }

    // 测试购买NFT成功
    function testBuyNFT() public {
        uint256 tokenId = 0;
        nft.approve(address(market), tokenId); // 批准市场合约管理NFT
        market.list(tokenId, 100 * 10 ** 18); // 上架NFT

        token.transfer(addr1, 200 * 10 ** 18); // 给测试地址1转移代币
        vm.prank(addr1); // 模拟由测试地址1调用
        token.approve(address(market), 100 * 10 ** 18); // 批准市场合约管理代币
        vm.prank(addr1); // 模拟由测试地址1调用
        market.buyNFT(tokenId); // 购买NFT

        assertEq(nft.ownerOf(tokenId), addr1); // 验证NFT所有者为测试地址1
    }

    // 测试购买NFT时代币不足失败
    function testFailBuyNFTNotEnoughTokens() public {
        uint256 tokenId = 0;
        nft.approve(address(market), tokenId); // 批准市场合约管理NFT
        market.list(tokenId, 100 * 10 ** 18); // 上架NFT

        token.transfer(addr1, 50 * 10 ** 18); // 给测试地址1转移50代币
        vm.prank(addr1); // 模拟由测试地址1调用
        token.approve(address(market), 100 * 10 ** 18); // 批准市场合约管理代币
        vm.prank(addr1); // 模拟由测试地址1调用
        market.buyNFT(tokenId); // 尝试购买NFT，应失败
    }

    // 测试重复购买NFT失败
    function testFailBuyNFTAlreadySold() public {
        uint256 tokenId = 0;
        nft.approve(address(market), tokenId); // 批准市场合约管理NFT
        market.list(tokenId, 100 * 10 ** 18); // 上架NFT

        token.transfer(addr1, 200 * 10 ** 18); // 给测试地址1转移代币
        vm.prank(addr1); // 模拟由测试地址1调用
        token.approve(address(market), 100 * 10 ** 18); // 批准市场合约管理代币
        vm.prank(addr1); // 模拟由测试地址1调用
        market.buyNFT(tokenId); // 购买NFT

        vm.prank(addr2); // 模拟由测试地址2调用
        token.approve(address(market), 100 * 10 ** 18); // 批准市场合约管理代币
        vm.prank(addr2); // 模拟由测试地址2调用
        market.buyNFT(tokenId); // 尝试重复购买NFT，应失败
    }

    // 测试随机价格上架和购买NFT
    function testRandomBuySell() public {
        for (uint256 i = 0; i < 10; i++) {
            uint256 tokenId = nft.nextTokenId(); // 获取下一个NFT的ID
            nft.mintTo(owner); // 给合约部署者铸造一个NFT

            uint256 price = uint256(keccak256(abi.encodePacked(block.timestamp, tokenId))) % 10000 * 10 ** 18; // 生成随机价格
            nft.approve(address(market), tokenId); // 批准市场合约管理NFT
            market.list(tokenId, price); // 上架NFT

            address buyer = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, tokenId))) % (10 ** 40))); // 生成随机买家地址
            token.transfer(buyer, price); // 给买家转移代币
            vm.prank(buyer); // 模拟由买家调用
            token.approve(address(market), price); // 批准市场合约管理代币
            vm.prank(buyer); // 模拟由买家调用
            market.buyNFT(tokenId); // 买家购买NFT

            assertEq(nft.ownerOf(tokenId), buyer); // 验证NFT所有者为买家
        }
    }

    // 确保市场合约中没有代币余额
    function testMarketHasNoTokens() public {
        assertEq(token.balanceOf(address(market)), 0); // 验证初始余额为0

        uint256 tokenId = 0;
        nft.approve(address(market), tokenId); // 批准市场合约管理NFT
        market.list(tokenId, 100 * 10 ** 18); // 上架NFT

        token.transfer(addr1, 200 * 10 ** 18); // 给测试地址1转移代币
        vm.prank(addr1); // 模拟由测试地址1调用
        token.approve(address(market), 100 * 10 ** 18); // 批准市场合约管理代币
        vm.prank(addr1); // 模拟由测试地址1调用
        market.buyNFT(tokenId); // 购买NFT

        assertEq(token.balanceOf(address(market)), 0); // 验证交易后余额仍为0
    }
}
