import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";

const addresses = [
    "0xe4535dfs897d8sd8ds8sd8gdg87fg8g8h8gfh8fg",
    "0x934dsfssgf8fg7d8f7g8df7g8df7g8dfhghkhfgh",
    "0x3sdafsdfsdf9sdfsdgfdg84fgdgdfgdfgdfgdfg8",
    "0x495B66acb3c45CFdD139842383212B6cE2d532bB",
    "0xE1D246c4001b0b0674195fe22Bf3f1ea0458a3A7"];

const leaves = addresses.map(x => keccak256(x.toLowerCase()));
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
const buf2hex = x => "0x" + x.toString("hex");

// get the leaf node of address of person attempting to mint NFT
const leaf = keccak256(addresses[4].toLowerCase())
const proof = tree.getProof(leaf).map(x => buf2hex(x.data))

console.log(buf2hex(tree.getRoot()));
console.log(proof);
console.log("=======================================================")
// wanna print something thats easy to paste into solidity
// vscode adds extra formatting and single quotes...
let start = "[";
let middle = "";
let end = "]";
for (let i = 0; i < proof.length; i++) {
    if (i == proof.length - 1) {
        middle += `"${proof[i]}"`;
    } else {
        middle += `"${proof[i]}",`;
    }
}
console.log(start + middle + end);
// example formatted proof: ["0xb0eb63e77f6491c59bb603be8db0a0c4481df35a99343f5a36e291d461b57017"]
