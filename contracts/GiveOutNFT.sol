pragma solidity ^0.8.3;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


 contract GiveOutNFT is ERC721URIStorage { 
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct GiveitOutNFTSource {
        address creator;

        string metadataUri;
    }

    mapping (uint256 => GiveitOutNFTSource) public idToGiveitOutNFTSource;

    mapping (uint256 => bool) public nftMinted;

    constructor () ERC721("GiveitOut","LkYU"){}

    function createToken(string memory metadataUri, uint256 giveawayId) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, metadataUri);
        idToGiveitOutNFTSource[newItemId] = GiveitOutNFTSource( msg.sender, metadataUri);
        nftMinted[giveawayId] = true;
        return newItemId;
    }

    function tokenSource(uint256 _tokenId)
        public
        view
        returns (
            address creator,
            string memory metadataUri)
        {
          GiveitOutNFTSource memory GiveitOutNFTSource = idToGiveitOutNFTSource[_tokenId];
          return (GiveitOutNFTSource.creator, GiveitOutNFTSource.metadataUri);
        }


    function getNftMinted (uint256 giveawayId) public view returns(bool){
        return nftMinted[giveawayId];
    }
}
