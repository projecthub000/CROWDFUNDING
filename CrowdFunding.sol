// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// CROWDFUNDING PROJECT
contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContributor;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    constructor(uint _target, uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline; // 10sec+3600sec
        minimumContributor=100 wei;
        manager=msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp < deadline,"Deadline has passed");
        require(msg.value>=minimumContributor,"Minium contribution is not met");
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function gcb() public view returns(uint){
        
        return address(this).balance;
    } 
    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target," You are not eligible for refund");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfvoters;
        mapping(address=>bool) voters;
    }
    mapping (uint=>Request) public requests;
    uint public numrequest; 
    // modifier onlymanager(){ // optional
    //     require(msg.sender==manager,"only manager can call this function");
    //     _;
    // }
    function createrequest(string memory _description,address payable _recipient,uint _value) public {
       require(msg.sender==manager,"only manager can call this function");
       Request storage newRequest = requests[numrequest];
       numrequest++;
       newRequest.description=_description;
       newRequest.recipient=_recipient;
       newRequest.value=_value;
       newRequest.completed=false;
       newRequest.noOfvoters=0;  
    }
    function voterequest(uint _requestno) public{
        require(contributors[msg.sender]>0,"you must be a contributor");
        Request storage thisrequest=requests[_requestno];
        require(thisrequest.voters[msg.sender]==false,"you have allready voted ");
        thisrequest.voters[msg.sender]==true;
        thisrequest.noOfvoters++;
        
    }

    function makepayment(uint _requestno) public {
        require(msg.sender==manager);
        require(raisedAmount>=target);
        Request storage thisrequest=requests[_requestno];
        require(thisrequest.completed==false,"The request has been completed");
        require(thisrequest.noOfvoters>noOfContributors/2,"Majority does not support");
        thisrequest.recipient.transfer(thisrequest.value);
        thisrequest.completed=true;
    }
}
