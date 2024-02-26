// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import  "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFTMarketplace is ERC721, Ownable, ERC721URIStorage{
    uint256 private nextTokenId;

    event PurchaseMade(address indexed buyer, uint256 indexed tokenId, uint256 price);

    struct Sale {
        address seller;
        string name;
        uint256 price;
        bool isActive;
    }

    enum UserRole {
        Admin,
        Seller, 
        Buyer
    }

    mapping(uint256 => Sale) public sales;
    mapping(address => UserRole) public userRoles;


    constructor(address initialOwner) ERC721("NFTMarketplace", "NFTMKPL")  Ownable(initialOwner) {}

    modifier onlySeller() {
        require(userRoles[msg.sender] == UserRole.Seller, "Caller is not a seller");
        _;
    }

    function setUserRole(address user, UserRole role) public onlyOwner {
        userRoles[user] = role;
    }

    function safeMint(address to, string memory uri) external  onlyOwner {
        uint256 _tokenId = nextTokenId++;
        _safeMint(to, _tokenId);
        _setTokenURI(_tokenId, uri);
    }

    function listForSale(uint256 tokenId, uint256 _price, string calldata _name) external onlySeller {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        sales[tokenId] = Sale(msg.sender, _name, _price, true);
    }

    function buy(uint256 tokenId) public payable {
        require(sales[tokenId].isActive, "NFT has been sole");
        require(msg.value >= sales[tokenId].price, "Insufficient funds");

        address seller = sales[tokenId].seller;

        payable(seller).transfer(sales[tokenId].price);
        
        _safeTransfer(seller, msg.sender, tokenId);

        sales[tokenId].isActive = false;

        emit PurchaseMade(msg.sender, tokenId, sales[tokenId].price);
    }



        // The following functions are overrides required by Solidity.
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
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
