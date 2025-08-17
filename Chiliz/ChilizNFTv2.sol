// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@4.9.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.9.3/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.9.3/utils/Counters.sol";
import "@openzeppelin/contracts@4.9.3/interfaces/IERC2981.sol";
import "@openzeppelin/contracts@4.9.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.9.3/utils/Address.sol";
import "@openzeppelin/contracts@4.9.3/security/ReentrancyGuard.sol";

/// @notice Initial sale splits: 5% devs, 25% creators, 70% charity.
///         Secondary royalty: 10% to revenue-share contract (which handles its own distribution logic).
contract ChilizNFTv2 is ERC721, ERC721URIStorage, IERC2981, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using Address for address payable;

    Counters.Counter private _tokenIdCounter;

    // --- Constants ---
    uint96 private constant BPS = 10_000;            // basis points denominator
    uint96 private constant DEV_BPS = 500;           // 5%
    uint96 private constant CREATOR_BPS = 2_500;     // 25%
    uint96 private constant CHARITY_BPS = 7_000;     // 70%
    uint96 private constant ROYALTY_BPS = 1_000;     // 10% secondary sale royalty

    // --- Addresses ---
    address payable public devWallet;        // developers' wallet (5%)
    address payable public creatorWallet;    // content creators' wallet (25%)
    address payable public charityWallet;    // charity wallet (70%)
    address public revenueShare;             // receives 10% royalties per EIP-2981

    // --- Sale params ---
    uint256 public mintPrice;                // initial mint price in wei (e.g., 0.1 ether)
    uint256 public immutable maxSupply;      // max # of NFTs that can be minted

    // --- Events ---
    event MintPriceUpdated(uint256 newPrice);
    event WalletsUpdated(address devWallet, address creatorWallet, address charityWallet);
    event RevenueShareUpdated(address revenueShare);

    constructor(
        address payable _devWallet,
        address payable _creatorWallet,
        address payable _charityWallet,
        address _revenueShare,
        uint256 _mintPrice,
        uint256 _maxSupply
    ) ERC721("ChilizNFTv2", "CNFT") Ownable() {
        require(_devWallet != address(0) && _creatorWallet != address(0) && _charityWallet != address(0), "Zero addr");
        require(_revenueShare != address(0), "Zero revenue share");
        devWallet = _devWallet;
        creatorWallet = _creatorWallet;
        charityWallet = _charityWallet;
        revenueShare = _revenueShare;
        mintPrice = _mintPrice;
        maxSupply = _maxSupply;
        // Sanity check: 5 + 25 + 70 = 100%
        assert(uint256(DEV_BPS) + uint256(CREATOR_BPS) + uint256(CHARITY_BPS) == BPS);
    }

    // --- Admin setters ---
    function setMintPrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
        emit MintPriceUpdated(_newPrice);
    }

    function setWallets(
        address payable _devWallet,
        address payable _creatorWallet,
        address payable _charityWallet
    ) external onlyOwner {
        require(_devWallet != address(0) && _creatorWallet != address(0) && _charityWallet != address(0), "Zero addr");
        devWallet = _devWallet;
        creatorWallet = _creatorWallet;
        charityWallet = _charityWallet;
        emit WalletsUpdated(_devWallet, _creatorWallet, _charityWallet);
    }

    function setRevenueShare(address _revenueShare) external onlyOwner {
        require(_revenueShare != address(0), "Zero address");
        revenueShare = _revenueShare;
        emit RevenueShareUpdated(_revenueShare);
    }

    // --- Minting ---
    /// @notice Mint a new NFT. Proceeds are split 5/25/70 among dev/creator/charity.
    /// @dev Any excess ETH above mintPrice is accepted and split according to the same ratios.
    function safeMint(address to, string memory uri) public payable nonReentrant {
        require(_tokenIdCounter.current() < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment for mint");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        // Split the entire payment (supports tipping above mintPrice)
        uint256 total = msg.value;
        uint256 devAmt = (total * DEV_BPS) / BPS;
        uint256 creatorAmt = (total * CREATOR_BPS) / BPS;
        // Send the remainder to charity to avoid rounding dust
        uint256 charityAmt = total - devAmt - creatorAmt;

        devWallet.sendValue(devAmt);
        creatorWallet.sendValue(creatorAmt);
        charityWallet.sendValue(charityAmt);
    }

    // --- Views ---
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    // --- EIP-2981 ---
    /// @notice Royalty info for secondary sales per EIP-2981.
    /// @dev Always returns the revenueShare address and 10% of sale price.
    function royaltyInfo(uint256 /* _tokenId */, uint256 _salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        uint256 amount = (_salePrice * ROYALTY_BPS) / BPS;
        return (revenueShare, amount);
    }

    // --- Overrides ---
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, IERC165)
        returns (bool)
    {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
