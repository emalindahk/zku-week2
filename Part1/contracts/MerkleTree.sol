//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = new uint256[](8);
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint256 midx = index;
        hashes[index] = hashedLeaf;
        index++;

        for( uint256 i = 0; i < hashes.length; i++ ) {
            if( hashes[i] == 0 ) {
                continue;
            }
            uint256 left = hashes[i];
            uint256 right = hashes[i+1];
            if( i % 2 == 0 ) {
                hashes[midx] = PoseidonT3.poseidon([left, right]);
            } else {
                hashes[midx] = PoseidonT3.poseidon([right, left]);
            }
        }
        return midx;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input);
    }
}
