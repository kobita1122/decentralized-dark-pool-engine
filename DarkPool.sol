// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DarkPool is ReentrancyGuard {
    struct OrderCommitment {
        address user;
        bytes32 commitmentHash;
        bool revealed;
        bool processed;
    }

    mapping(bytes32 => OrderCommitment) public orders;
    
    event OrderCommitted(address indexed user, bytes32 indexed commitmentHash);
    event OrderSettled(bytes32 orderHashA, bytes32 orderHashB, uint256 price, uint256 volume);

    function commitOrder(bytes32 _commitmentHash) external {
        require(orders[_commitmentHash].user == address(0), "Commitment exists");
        
        orders[_commitmentHash] = OrderCommitment({
            user: msg.sender,
            commitmentHash: _commitmentHash,
            revealed: false,
            processed: false
        });

        emit OrderCommitted(msg.sender, _commitmentHash);
    }

    function settleMatch(
        bytes32 hashA,
        bytes32 hashB,
        address userA,
        address userB,
        address tokenA, // Token user A gives
        address tokenB, // Token user B gives
        uint256 amountA,
        uint256 amountB,
        bytes32 saltA,
        bytes32 saltB
    ) external nonReentrant {
        // Verify commitments
        require(keccak256(abi.encode(userA, tokenA, tokenB, amountA, saltA)) == hashA, "Invalid reveal A");
        require(keccak256(abi.encode(userB, tokenB, tokenA, amountB, saltB)) == hashB, "Invalid reveal B");
        
        require(!orders[hashA].processed && !orders[hashB].processed, "Already processed");

        orders[hashA].processed = true;
        orders[hashB].processed = true;

        // Atomic Swap
        IERC20(tokenA).transferFrom(userA, userB, amountA);
        IERC20(tokenB).transferFrom(userB, userA, amountB);

        emit OrderSettled(hashA, hashB, amountA / amountB, amountA);
    }
}
