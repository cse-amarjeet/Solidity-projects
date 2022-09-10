// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Allowance is Ownable {
    event allowanceChanged(address indexed forwho, address indexed fromwhom, uint oldAmount, uint newAmount);
    mapping (address=>uint) public allowance;

    modifier ownerOrAllowance(uint amount) {
        require(owner()==msg.sender || allowance[msg.sender]>=amount , "you are not allowed!!" );
        _;
    }

    function addAllowance(address who, uint amount) public onlyOwner  {
        //require(amount <= address(this).balance,"Not enough balance in smart contract to give allowance");
        emit allowanceChanged(who, msg.sender, allowance[who], amount);
        allowance[who]=amount;
    }
}

contract SimpleWallet is Allowance {
    event MoneySent(address indexed beneficiary, uint amount);
    event MoneyReceive(address indexed from, uint amount);
    function withdrawalMoney(address payable to, uint amount) public ownerOrAllowance(amount) {
        require(amount <= address(this).balance,"Not enough balance in smart contract to withdraw");
        if(owner() !=msg.sender){
            emit allowanceChanged(msg.sender, msg.sender, allowance[msg.sender], allowance[msg.sender]-amount);
            allowance[msg.sender] -=amount;
        }
        emit MoneySent(to, amount);
        to.transfer(amount);
    }

    function renounceOwnership() public pure override  {
        revert("this functionality is no more exist!!");
    }
    receive() external payable  {
        emit MoneyReceive(msg.sender, msg.value);
    }
}