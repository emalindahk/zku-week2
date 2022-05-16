pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template TreeLayer(height) {
  var nItems = 1 << height;
  signal input ins[nItems * 2];
  signal output outs[nItems];

  component hash[nItems];
  for(var i = 0; i < nItems; i++) {
    hash[i] = Poseidon(2);
    hash[i].inputs[0] <== ins[i * 2];
    hash[i].inputs[1] <== ins[i * 2 + 1];
    hash[i].out ==> outs[i];
  }
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
  signal input leaves[2**n];
  signal output root;

//[assignment] insert your code here to calculate the Merkle root from 2^n leaves
  component layers[n];
  for(var level = n - 1; level >= 0; level--) {
    layers[level] = TreeLayer(level);
    for(var i = 0; i < (1 << (level + 1)); i++) {
      layers[level].ins[i] <== level == n - 1 ? leaves[i] : layers[level + 1].outs[i];
    }
  }
  root <== layers[0].outs[0];
}


template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal


    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    signal levelHashes[n + 1];
    levelHashes[0] <== leaf;

    component pHasher[n];
    component mux[n];

    for (var i = 0; i < n; i++){
      path_index[i] * (1 - path_index[i]) === 0;

      pHasher[i] = Poseidon(2);
      mux[i] = MultiMux1(2);

      mux[i].c[0][0] <== levelHashes[i];
      mux[i].c[0][1] <== path_elements[i];

      mux[i].c[1][0] <== path_elements[i];
      mux[i].c[1][1] <== levelHashes[i];

      mux[i].s <== path_index[i];
      pHasher[i].inputs[0] <== mux[i].out[0];
      pHasher[i].inputs[1] <== mux[i].out[1];

      levelHashes[i + 1] <== pHasher[i].out;
    }

    root <== levelHashes[n]; 
}
