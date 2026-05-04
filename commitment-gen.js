const { ethers } = require("ethers");

/**
 * Generates an order commitment hash and the salt needed for the reveal phase.
 */
function createOrderCommitment(user, tokenIn, tokenOut, amountIn) {
    const salt = ethers.randomBytes(32);
    const hash = ethers.keccak256(
        ethers.AbiCoder.defaultAbiCoder().encode(
            ["address", "address", "address", "uint256", "bytes32"],
            [user, tokenIn, tokenOut, amountIn, salt]
        )
    );

    return {
        commitmentHash: hash,
        salt: ethers.hexlify(salt)
    };
}

module.exports = { createOrderCommitment };
