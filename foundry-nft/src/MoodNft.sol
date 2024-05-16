// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    // errors
    error MoodNft__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    // mapping(uint256 => string) s_tokenIdToUri;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    enum Mood {
        SAD,
        HAPPY
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(
        string memory sadSvgImageUri,
        string memory happySvgImageUri
    ) ERC721("MoodNft", "MNFT") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgImageUri;
        s_happySvgImageUri = happySvgImageUri;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.SAD;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenId) public {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }
            s_tokenIdToMood[tokenId] = s_tokenIdToMood[tokenId] == Mood.SAD ? Mood.HAPPY : Mood.SAD;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[tokenId] == Mood.SAD) {
            imageUri = s_sadSvgImageUri;
        } else {
            imageUri = s_happySvgImageUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            name(),
                            '", "description": "An NFT that represents owner moods.", "attributes": [{"trait_type" : "moodiness". "value": 100}], "image": "',
                            imageUri,
                            '"}'
                        )
                    )
                )
            )
        );
        // return
    }
}
