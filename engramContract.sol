// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts@4.4.2/utils/Strings.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract Engram is ERC721A, Ownable, ERC2981 {

    enum Status {
        pausedSale,
        publicSale,
        privateSale
    }

    uint256 public immutable maxSupply;
    uint256 public immutable maxMints;
    uint256 public publicMintRate;
    uint256 public privateMintRate;
    string private _baseTokenURI;
    Status public status;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI_,
        address payable royaltyReciever,
        uint96 royaltyBasisPoints,
        uint256 maxSupply_,
        uint256 maxMints_,
        uint256 publicMintRate_,
        uint256 privateMintRate_
    ) 
        ERC721A(name, symbol) {
            _baseTokenURI = baseURI_;
            _setDefaultRoyalty(royaltyReciever, royaltyBasisPoints);
            maxSupply = maxSupply_;
            maxMints = maxMints_;
            publicMintRate = 1 ether * publicMintRate_ / 100;
            privateMintRate = 1 ether * privateMintRate_ / 100;
        }

    function publicMint(uint256 _quantity) external payable {
        require(status == Status.publicSale, "Public sale hasn't started yet!");
        require(_quantity + _numberMinted(msg.sender) <= maxMints, "Exceeded the mint limit!");
        require(totalSupply() + _quantity <= maxSupply, "Not enough passes left!");
        require(msg.value >= (publicMintRate * _quantity), "Not enough ether sent! Please try again...");
        _safeMint(msg.sender, _quantity);
    }

    function privateMint(uint256 _quantity) external payable {
        require(status == Status.privateSale, "Private sale hasn't started yet!");
        require(_quantity + _numberMinted(msg.sender) <= maxMints, "Exceeded the mint limit!");
        require(totalSupply() + _quantity <= maxSupply, "Not enough passes left!");
        require(msg.value >= (privateMintRate * _quantity), "Not enough ether sent! Please try again...");
        _safeMint(msg.sender, _quantity);
    }

    function teamMint(uint256 _quantity, address _recipient) external onlyOwner {
        require(totalSupply() + _quantity <= maxSupply, "Not enough passes left!");
        _safeMint(_recipient, _quantity);
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function changeBaseURI(string calldata baseURI) external onlyOwner {
         _baseTokenURI = baseURI;
    }

    function setStatus(Status _status) external onlyOwner {
        status = _status;
    }

    function setPublicMintRate(uint256 _mintRate) public onlyOwner {
       publicMintRate = 1 ether * _mintRate / 100;
    }

    function setPrivateMintRate(uint256 _mintRate) public onlyOwner {
       privateMintRate = 1 ether * _mintRate / 100;
    }

    function setDefaultRoyalty(address receiver, uint96 basisPoints) public virtual onlyOwner {
        _setDefaultRoyalty(receiver, basisPoints);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI_ = _baseURI();
        return bytes(baseURI_).length > 0 ? string(abi.encodePacked(baseURI_, Strings.toString(tokenId), ".json")) : "";
    }

    function supportsInterface (
        bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return ERC721A.supportsInterface(interfaceId) || 
        ERC2981.supportsInterface(interfaceId);
    }
}
