// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract Lottery {
    address public manager;
    address[] public players;

    constructor() {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > .01 ether); //check the minimum eth send by player should be >0.01
        players.push(msg.sender);  // push address of player to player[]
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    function pickWinner() public restricted {
        uint index = random() % players.length;
        payable (players[index]).transfer(address(this).balance);
        players = new address[](0);
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }
    receive() external payable {
        enter();
    }
    fallback() external payable {
        enter();
    }
}