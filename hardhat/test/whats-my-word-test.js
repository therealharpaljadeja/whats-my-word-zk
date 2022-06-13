//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected
const chai = require("chai");
const path = require("path");
const buildPoseidon = require("circomlibjs").buildPoseidon;

const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("What's my word test", function () {
	it("Check if the code breaker broke the code", async () => {
		const circuit = await wasm_tester(
			path.join(__dirname, "../circuits/WhatsMyWord.circom")
		);
		await circuit.loadConstraints();
		let poseidon = await buildPoseidon();
		let F = poseidon.F;
		let res = poseidon([1213123, 99, 1, 13, 99, 99, 99]);

		const INPUT = {
			pubGuessA: "99", // _
			pubGuessB: "1", // A
			pubGuessC: "13", // M
			pubGuessD: "99", // _
			pubGuessE: "99", // _
			pubGuessE: "99", // _
			pubGuessF: "99", // _
			isGuessA: false,
			isGuessB: true,
			isGuessC: true,
			isGuessD: false,
			isGuessE: false,
			isGuessF: false,
			pubSolnHash: F.toObject(res),
			pubNumHit: "2",
			pubNumBlow: "0",
			privSolnA: "7", // G
			privSolnB: "1", // A
			privSolnC: "13", // M
			privSolnD: "5", // E
			privSolnE: "18", // R
			privSolnF: "17", // S
			privSalt: "1213123",
		};
		const witness = await circuit.calculateWitness(INPUT, true);
		assert(F.eq(F.e(witness[1]), F.e(res)));
	});
});
