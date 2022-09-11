pragma solidity ^0.4.17;

contract campaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }
    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}


contract Campaign {
    struct Request {  //use for create withdrawal request
        string description;
        uint value;
        address recipient;
        bool complete;
        mapping(address => bool) approvals; //store address of contributer how have voted yes
        uint approvalCount;
    }
    Request[] public requests;   // array of struct Request of fund withdrawal
    address public manager;
    uint public minimunContribution;
    mapping(address => bool) public approvers; //address of all contributer who donate more then minimum amount
    uint public approversCount = 0;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function Campaign(uint minimun, address creator) public {  //constructor
        manager = creator;
        minimunContribution=minimun;  //set minimum amount of contribution
    }

    function contribute() public payable {  //contributer call this function for donation
        require(msg.value > minimunContribution); // check amount is greater then minimum
        approvers[msg.sender]=true;  // store the address of contributer
        approversCount++;
    }

    function createRequest(string description, uint value, address recipient) public restricted {
        //this function only call by manager for creating fund withdrawal request
        //after manager create the withdrawal request all the contributer can vote 
        Request memory newRequest =  Request({
            description:description,
            value:value,
            recipient:recipient,
            complete: false,
            approvalCount:0
        });
        requests.push(newRequest);
    }

    function approveRequest(uint index) public {  
        //this call by contributer for voting and contributer have to pass the index of request
        Request storage request = requests[index];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);
        request.approvals[msg.sender]=true;
        request.approvalCount++; //= requests[index].approvalCount +1;
    }

    function finalizeRequest(uint index) public restricted {
        //this function call by manager for finilize the request after 
        // minimum 50% of contibuter voted yes

        Request storage request = requests[index];
        require(!request.complete);
        require((approversCount/2)< requests[index].approvalCount );
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummery() public view returns (
        uint, uint, uint, uint, address
    ) {
        return (
            minimunContribution,
            this.balance,
            requests.length,
            approversCount,
            manager
        );
    }

    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }

}