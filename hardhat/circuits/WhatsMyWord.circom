pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/gates.circom";

template HitAndBlow() {
    // Public inputs
    signal input pubGuessA;
    signal input pubGuessB;
    signal input pubGuessC;
    signal input pubGuessD;
    signal input pubGuessE;
    signal input pubGuessF;

    signal input isGuessA;
    signal input isGuessB;
    signal input isGuessC;
    signal input isGuessD;
    signal input isGuessE;
    signal input isGuessF;

    signal input pubNumHit;
    signal input pubNumBlow;
    signal input pubNumExists;
    signal input pubSolnHash;

    // Private inputs
    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;
    signal input privSolnD;
    signal input privSolnE;
    signal input privSolnF;
    signal input privSalt;

    // Output
    signal output solnHashOut;

    var guess[6] = [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubGuessE, pubGuessF];
    var soln[6] =  [privSolnA, privSolnB, privSolnC, privSolnD, privSolnE, privSolnF];
    var j = 0;
    var k = 0;
    component lessThan[12];
    component equalGuess[6];
    component equalSoln[6];
    component Ors[12];
    component isEqual99[6];

    // Create a constraint that the solution digits are in the range 0 to 25 and guess digits are in the range 0 to 25 or equal to 99.
    for (j=0; j<6; j++) {
        lessThan[j] = LessThan(5);
        lessThan[j].in[0] <== guess[j];
        lessThan[j].in[1] <== 26;
        isEqual99[j] = IsEqual();
        isEqual99[j].in[0] <== guess[j];
        isEqual99[j].in[1] <== 99;
        Ors[j] = OR()
        Ors[j].a = lessThan[j].out;
        Ors[j].b = isEqual99[j].out;

        Ors[j].out === 1;

        lessThan[j+6] = LessThan(5);
        lessThan[j+6].in[0] <== soln[j+6];
        lessThan[j+6].in[1] <== 26;
        lessThan[j+6].out === 1;
    }

    // Count hit & blow
    var hit = 0;
    var blow = 0;
    component equalHB[36];

    for (j=0; j<4; j++) {
        for (k=0; k<4; k++) {
            if(!isEqual99[k]) {
              equalHB[4*j+k] = IsEqual();
              equalHB[4*j+k].in[0] <== soln[j];
              equalHB[4*j+k].in[1] <== guess[k];
              blow += equalHB[4*j+k].out;
              if (j == k) {
                  hit += equalHB[4*j+k].out;
                  blow -= equalHB[4*j+k].out;
              }
            }
        }
    }

    // Create a constraint around the number of hit
    component equalHit = IsEqual();
    equalHit.in[0] <== pubNumHit;
    equalHit.in[1] <== hit;
    equalHit.out === 1;
    
    // Create a constraint around the number of blow
    component equalBlow = IsEqual();
    equalBlow.in[0] <== pubNumBlow;
    equalBlow.in[1] <== blow;
    equalBlow.out === 1;

    // figuring out how to compare partial pubSolnHash with privSolnHash.
    
    // // Verify that the hash of the private solution matches pubSolnHash
    // component poseidon = Poseidon(6);
    // poseidon.inputs[0] <== privSalt;
    // poseidon.inputs[1] <== privSolnA;
    // poseidon.inputs[2] <== privSolnB;
    // poseidon.inputs[3] <== privSolnC;
    // poseidon.inputs[4] <== privSolnD;
    // poseidon.inputs[5] <== privSolnE;
    // poseidon.inputs[6] <== privSolnF;

    // solnHashOut <== poseidon.out;
    // pubSolnHash === solnHashOut;
 }

 component main {public [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubNumHit, pubNumBlow, pubSolnHash]} = HitAndBlow();