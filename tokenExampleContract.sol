// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;
//this contract only for owner 
contract owned {
    address owner;
    constructor() {
        owner=msg.sender;
    }
    modifier onlyOwner() {
        require(owner==msg.sender,"You are not owner");
        _;
    }

}
// Now second contract is starts here that is  actual token contract
contract FirstToken is owned {
    mapping (address=>uint) public tokenBalance;
 
    uint tokenPrice = 1 ether;

    constructor() {
        tokenBalance[owner]=100;
    }
    event tokensSent(address _from, address _to, uint _amount);
    
    function createNewToken() public onlyOwner {
        tokenBalance[owner]++;
    }

    function burnToken() public onlyOwner {
        tokenBalance[owner]--;
    }

    function purchageToken() public payable {
        require((tokenBalance[owner]*tokenPrice)/msg.value>0, "not enough token to buy");
        assert(tokenBalance[msg.sender]< tokenBalance[msg.sender]+(msg.value / tokenPrice));
        assert(tokenBalance[owner]>(tokenBalance[owner]-msg.value/tokenPrice));
        tokenBalance[msg.sender]+=msg.value/tokenPrice;
    }

    function sendToken(address _to,uint _amount) public {
        require(tokenBalance[msg.sender]>=_amount, "not enough amount in your accunt");
        require(tokenBalance[_to]< tokenBalance[_to]+_amount);
        require(tokenBalance[msg.sender]>tokenBalance[msg.sender]-_amount);
        tokenBalance[msg.sender]-=_amount;
        tokenBalance[_to]+=_amount;

        emit tokensSent(msg.sender, _to, _amount);

    }

}

//0xfaa0a264