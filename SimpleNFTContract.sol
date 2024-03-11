//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "ERC721.sol";
import {DefaultOperatorFilterer} from "DefaultOperatorFilterer.sol";
import {Ownable} from "Ownable.sol";
import "Strings.sol";
import "ERC2981.sol";

contract simpleNFTContract is ERC721, DefaultOperatorFilterer, Ownable, ERC2981{

using Strings for uint256;
address royaltyAddress;
string private baseURI;
string public baseExtension = ".json";
string public preRevealURI;
uint96 royaltyFeesInBips;

uint256 public maxSupply = 1000;
uint256 public price = 0.1 ether;
uint256 public maxPerWallet = 1000;
bool public paused = false;
bool public revealed = true;
uint256 public totalSupply;

constructor(string memory _name, string memory _symbol, string memory _initBaseURI, string memory _preRevealedURI) 
ERC721 (_name, _symbol) {
    setBaseURI(_initBaseURI);
    setPreRevealedURI(_preRevealedURI);
    setRoyaltyInfo(owner(),1000);
    royaltyAddress = owner();
}

function mint(uint256 tokenId) public payable {
    require(totalSupply + 1 <= maxSupply, "No More NFTs to Mint");
    require(!_exists(tokenId),"Token Already Minted");
    require(tokenId > 0, "Token Ids should be greater than 0");

    if(msg.sender != owner()){
        require(!paused, "The Contract is Paused");
        require(msg.value >= price, "Not enough eth Sent");        
    }

    totalSupply++;
    _safeMint(msg.sender, tokenId);

}

function getTokenStatus(uint256 tokenID) external view returns (bool) {
    return _exists(tokenID);
}

function withdraw() public payable onlyOwner {
    (bool main,) = payable(owner()).call{value:address(this).balance}("");
    require(main);
}

function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
    _requireMinted(tokenId);

    require(_exists(tokenId), "ERC721 Metadata: URI query for noneexistent token" );

    if(revealed == false) {
        return preRevealURI;
    }

    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension)):"";

}

function setApprovalForAll(address operator, bool approved) public override  onlyAllowedOperatorApproval(operator){
    super.setApprovalForAll(operator, approved);
}

function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator){
    super.approve(operator, tokenId);
}

function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from){
    super.transferFrom(from, to, tokenId);
}

function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from){
    super.safeTransferFrom(from, to, tokenId);
}

function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override onlyAllowedOperator(from){
    super.safeTransferFrom(from, to, tokenId, data);
}

function setBaseURI(string memory _newBaseURI) public onlyOwner{
    baseURI = _newBaseURI;
}

function setPreRevealedURI(string memory _newPreRevealedURI) public onlyOwner{
    preRevealURI = _newPreRevealedURI;
}

function setRoyaltyInfo(address _reveiver, uint96 _royalyFeesInBips)public onlyOwner{
    royaltyAddress = _reveiver;
    royaltyFeesInBips = _royalyFeesInBips;
}

function setPause(bool _state) external onlyOwner {
    paused = _state;
}

function setBaseExtension(string memory _newBaseExtension) external onlyOwner {
    baseExtension = _newBaseExtension;
}

function toggleReveal() external onlyOwner {
    if(revealed == false) {
        revealed = true;
    }else{
        revealed = false;
    }
}

function setMaxSupply(uint256 _maxSupply) external onlyOwner {
    maxSupply = _maxSupply;
}

function setMaxPerWallet(uint256 _maxPerWallet) external onlyOwner {
    maxPerWallet = _maxPerWallet;
}

function setPrice(uint256 _price) external onlyOwner {
    price = _price;
}

function setRoyaltyAddress(address _royaltyAddress) external onlyOwner {
    royaltyAddress = _royaltyAddress;
}

function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool){
    return super.supportsInterface(interfaceId);
}

}