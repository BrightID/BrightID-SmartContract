pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract MembershipToken {
    function balanceOf(address account) public returns (uint256) {}
}

contract BrightID is Ownable {

    MembershipToken public supervisorToken;
    MembershipToken public proposerToken;

    event Verified(address indexed addr, address indexed revoked);
    event Proposed(address indexed addr, address indexed revoked);
    event Started();
    event Stopped(address stopper);
    event AppliedCounterSet(uint counter);
    event TimingSet(uint waiting, uint timeout);
    event MembershipTokensSet(address supervisorToken, address proposerToken);

    struct Proposal {
        address addr;
        address revoked;
        uint block;
    }
    uint public proposedCounter = 0;
    uint public appliedCounter = 0;
    mapping(uint => Proposal) public proposals;

    bool public stopped = false;
    uint public waiting = 10;
    uint public timeout = 120;
    mapping(address => uint) public verifications;
    mapping(address => address) public history;

    function setMembershipTokens(address _supervisorToken, address _proposerToken) public onlyOwner {
        supervisorToken = MembershipToken(_supervisorToken);
        proposerToken = MembershipToken(_proposerToken);
        MembershipTokensSet(_supervisorToken, _proposerToken);
    }

    function setTiming(uint _waiting, uint _timeout) public onlyOwner {
        waiting = _waiting;
        timeout = _timeout;
        TimingSet(_waiting, _timeout);
    }

    function setAppliedCounter(uint _appliedCounter) public onlyOwner {
        appliedCounter = _appliedCounter;
        AppliedCounterSet(_appliedCounter);
    }

    function stop() public {
        require(supervisorToken.balanceOf(msg.sender) > 0, "not authorized");
        stopped = true;
        emit Stopped(msg.sender);
    }

    function start() public onlyOwner {
        stopped = false;
        emit Started();
    }

    function proposeVerification(address addr, address revoked) public {
        require(proposerToken.balanceOf(msg.sender) > 0, "not authorized");
        proposals[proposedCounter] = Proposal(addr, revoked, block.number);
        proposedCounter = proposedCounter + 1;
        emit Proposed(addr, revoked);
    }

    function applyNext() public {
        require(!stopped, "contract is in stopped state");
        Proposal memory p = proposals[appliedCounter];
        appliedCounter = appliedCounter + 1;
        require(block.number - p.block > waiting, "proposal is in waiting state");
        require(block.number - p.block < timeout, "proposal timed out");

        verifications[p.addr] = block.number;
        if (p.revoked != address(0)) {
            verifications[p.revoked] = 0;
            history[p.addr] = p.revoked;
        }
        emit Verified(p.addr, p.revoked);
    }
    
}