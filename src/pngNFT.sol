// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import {ERC721} from 'solmate/tokens/ERC721.sol';
import {png} from './png.sol';
import {json} from './json.sol';

contract pngNFT is ERC721 {

    mapping (uint256 => bytes3[3]) public userPalettes;
    uint256 nextId;

    function mint(address to) public {
        _mint(to, nextId);
        bytes32 colours = keccak256(abi.encodePacked(nextId)); 
        bytes3[3] memory initialPalette;

        initialPalette[0] = bytes3(colours);
        initialPalette[1] = bytes3(colours << 3*8);
        initialPalette[2] = bytes3(colours << 6*8);
        userPalettes[nextId] = initialPalette;      
        
        nextId++;
    }

    function readPalette(uint256 id) public view returns (bytes3[3] memory) {
        return userPalettes[id];
    }

    function changePalette(uint256 id, bytes3 colour1, bytes3 colour2, bytes3 colour3) public {
        require(msg.sender == ownerOf(id), 'ONLY TOKEN HOLDER');

        bytes3[3] memory palette;

        palette[0] = colour1;
        palette[1] = colour2;
        palette[2] = colour3;

        userPalettes[id] = palette;

    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return json.formattedMetadata(
            'pngNFT',
            'pngNFT is an experimental project aimed at storing and rendering PNGs onchain',
            svgImg(id)
        );


    }

    function svgImg(uint256 id) public view returns (string memory) {

        return string.concat(
            '<svg width="100%" height="100%" version="1.1" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">  <image x="0" y="0" width="64" height="64" preserveAspectRatio="xMidYMid" xlink:href="',
            pngImg(id),
            '"/></svg>'
        );
    }
    
    function pngImg(uint256 id) public view returns (string memory) {
        
        uint32 width = 64;
        uint32 height = 64;

        bytes memory pixelArray = new bytes((width+1) * height);
        bytes3[] memory palette = new bytes3[](3);
        palette[0] = userPalettes[id][0];
        palette[1] = userPalettes[id][1];
        palette[2] = userPalettes[id][2];

        for (uint256 i = 0; i < 40; i++) {
            for (uint256 j = 0; j < 40; j++) {
                pixelArray[png.toIndex(i + 20, j+10, width)] = bytes1(0x01);
                pixelArray[png.toIndex(i + 15, j+15, width)] = bytes1(0x02);
                pixelArray[png.toIndex(i + 10, j+20, width)] = bytes1(0x03);
                }
        }

        return png.encodedPNG(uint32(64), uint32(64), palette, pixelArray, false);

    }

    constructor() ERC721('PNG',unicode"🎨") {}

}
