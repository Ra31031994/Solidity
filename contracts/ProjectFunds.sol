// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CampaignFactory {
    Campaign[] public deployedCampaigns;

    function createCampaign(uint goal, uint deadline, string memory name) public {
        Campaign newCampaign = new Campaign(goal, deadline, name, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (Campaign[] memory) {
        return deployedCampaigns;
    }
    
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    event RequestCreated(string description, uint value, address indexed recipient);

    Request[] public requests;
    address public manager;
    uint public goal;
    uint public deadline;
    string public name;
    mapping(address => uint) public contributors;
    uint public contributorCount;
    mapping(address => bool) public approvers;
    uint public approverCount;

    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function.");
        _;
    }

    constructor(uint campaignGoal, uint campaignDeadline, string memory campaignName, address creator) {
        manager = creator;
        goal = campaignGoal;
        deadline = campaignDeadline;
        name = campaignName;
    }

    function contribute() public payable {
        require(msg.value > 0, "You must send some Ether.");
        require(block.timestamp < deadline, "The campaign has ended.");
        contributors[msg.sender] += msg.value;
        contributorCount++;
        if (!approvers[msg.sender]) {
            approvers[msg.sender] = true;
            approverCount++;
        }
    }

    function createRequest(string memory description, uint value, address payable recipient) public restricted {
    Request storage newRequest = requests.push();
    newRequest.description = description;
    newRequest.value = value;
    newRequest.recipient = recipient;
    newRequest.complete = false;
    newRequest.approvalCount = 0;
    
    // Initialize the approvals mapping separately
    // mapping(address => bool) storage approvals = newRequest.approval;
   for (uint i = 0; i < approverCount; i++) {
    address currentApprover = getAddressAtIndex(i);
    newRequest.approvals[currentApprover] = false;
}
    emit RequestCreated(newRequest.description, newRequest.value, newRequest.recipient);
    // Assign the newRequest to the requests array
    // requests.push(newRequest);
}

    function approveRequest(uint index) public {
        Request storage request = requests[index];
        require(request.approvals[msg.sender], "You must be an approver to call this function.");
        require(!request.approvals[msg.sender], "You have already voted for this request.");
        request.approvals[msg.sender] = true;
        request.approvalCount++;

        // emit RequestApproved(index,msg.sender);
    }

    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        require(!request.complete, "This request has already been completed.");
        require(request.approvalCount > (approverCount / 2), "Not enough approvals to finalize this request.");
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary() public view returns (uint, uint, uint, uint, uint, uint, string memory) {
        return (
            goal,
            address(this).balance,
            contributorCount,
            approverCount,
            requests.length,
            deadline,
            name
        );
    }

    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
    function getAddressAtIndex(uint index) public view returns (address) {
    uint i = 0;
    for (uint j = 0; j < approverCount; j++) {
        if (approvers[address(uint160(index + j + 1))]) {
            i++;
        }
        if (i > index) {
            return address(uint160(index + j + 1));
        }
    }
    revert("Address not found");
}}
