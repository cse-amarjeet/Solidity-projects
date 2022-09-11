//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

//           Ether is send to Contract
//                 |
//           is msg.data empty?
//              /       \
//             yes      No
//             /         \
//    receive() exist?    fallback()
//       /       \
//     yes        No
//     /           \
//  receive()      fallback()

contract Fallback {
    event Log(string func, address sender, uint value, bytes data);

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }
   
}