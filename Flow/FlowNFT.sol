// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@4.9.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.9.3/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.9.3/utils/Counters.sol";
import "@openzeppelin/contracts@4.9.3/interfaces/IERC2981.sol";
import "@openzeppelin/contracts@4.9.3/access/Ownable.sol";

contract FlowNFT is ERC721, ERC721URIStorage, IERC2981, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Royalty parameters
    address private wallet1; // First royalty recipient
    address private wallet2; // Second royalty recipient
    uint256 private royaltyPercentage; // Secondary royalty percentage (basis points, e.g., 1000 = 10%)
    uint256 public mintPrice; // Initial mint price in wei (e.g., 0.1 ether)
    uint256 public immutable maxSupply; // Maximum number of NFTs that can be minted

    constructor(address _wallet1, address _wallet2, uint256 _royaltyPercentage, uint256 _mintPrice, uint256 _maxSupply) 
        ERC721("FlowNFT", "FNFT") Ownable() {
        wallet1 = _wallet1;
        wallet2 = _wallet2;
        royaltyPercentage = _royaltyPercentage;
        mintPrice = _mintPrice;
        maxSupply = _maxSupply;
    }

    // Set mint price (only owner)
    function setMintPrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
    }

    // Mint a new NFT with initial sale distribution and supply check
    function safeMint(address to, string memory uri) public payable {
        require(_tokenIdCounter.current() < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment for mint");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        // Distribute initial sale funds equally
        uint256 splitAmount = msg.value / 2;
        payable(wallet1).transfer(splitAmount);
        payable(wallet2).transfer(msg.value - splitAmount); // Handles odd amounts
    }

    // View total minted supply
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    // EIP-2981 royalty info for secondary sales
    function royaltyInfo(uint256 /*_tokenId*/, uint256 _salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        uint256 totalRoyalty = (_salePrice * royaltyPercentage) / 10000; // Basis points
        return (address(this), totalRoyalty); // Send to contract for later distribution
    }

    // Distribute accumulated royalties (from secondary sales) to two wallets
    function distributeRoyalties() external {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to distribute");
        uint256 splitAmount = balance / 2;
        payable(wallet1).transfer(splitAmount);
        payable(wallet2).transfer(balance - splitAmount); // Handles odd amounts
    }

    // Override tokenURI
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // Override supportsInterface
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, IERC165)
        returns (bool)
    {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    // Override _burn
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}