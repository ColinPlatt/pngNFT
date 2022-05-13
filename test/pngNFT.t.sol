// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import '../src/pngNFT.sol';

contract pngNFTTest is DSTest {

    pngNFT nft;

    function setUp() public {

        nft = new pngNFT();
        
    }

    function testMint() public {
        nft.mint(msg.sender);
        assertEq(nft.balanceOf(msg.sender),1);

        bytes3[3] memory idPalette = nft.readPalette(0);

        emit log_bytes(abi.encodePacked(idPalette[0], idPalette[1], idPalette[2]));
    }

    function testUri() public {
        nft.mint(msg.sender);

        emit log_string(nft.tokenURI(0));
    }

}
