// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
//In this contract I try to paly with transection with ether, and try to store transection releted information
//on blockchain in better way.
contract EtherTransectionLog {
    struct Payment {
        uint amount;
        uint timestamp;
    }
    struct Balance {
        uint totalBalance;
        uint numPayments;
        mapping (uint=>Payment) payments;
    }

    mapping (address=>Balance) public reciveAmount;

    function sendMoney() public payable {
        reciveAmount[msg.sender].totalBalance += msg.value;
        Payment memory payment = Payment(msg.value, block.timestamp);
        reciveAmount[msg.sender].payments[reciveAmount[msg.sender].numPayments] = payment;
        reciveAmount[msg.sender].numPayments++;
    } 
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdrawMoney(address payable _to, uint _amount) public {
        require(reciveAmount[msg.sender].totalBalance >= _amount, "Not enough Balance");
        reciveAmount[msg.sender].totalBalance -=_amount;
        _to.transfer(_amount);
    }
    function transferAllMoney() public {
        uint balancetowithdraw = reciveAmount[msg.sender].totalBalance;
        require(balancetowithdraw >100,"You have less then 100 wei, for withdraw minimum 101 wei needed!!" );
        reciveAmount[msg.sender].totalBalance =0;
        payable (msg.sender).transfer(balancetowithdraw);
    }
    receive() external payable {
        sendMoney();
    }
     fallback() external payable {
        sendMoney();
    }
}