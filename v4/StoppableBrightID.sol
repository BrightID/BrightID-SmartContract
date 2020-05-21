pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract StoppableBrightID is Ownable {

    IERC20 public supervisorToken;
    IERC20 public proposerToken;

    event Verified(address indexed addr);
    event Proposed(address indexed addr);
    event Started();
    event Stopped(address stopper);
    event TimingSet(uint waiting, uint timeout);
    event MembershipTokensSet(IERC20 supervisorToken, IERC20 proposerToken);

    bool public stopped = false;
    uint public waiting;
    uint public timeout;

    mapping(bytes32 => uint) public proposals;
    mapping(address => uint) public verifications;
    mapping(address => address) public history;

    function setMembershipTokens(IERC20 _supervisorToken, IERC20 _proposerToken) public onlyOwner {
        supervisorToken = _supervisorToken;
        proposerToken = _proposerToken;
        MembershipTokensSet(_supervisorToken, _proposerToken);
    }

    function setTiming(uint _waiting, uint _timeout) public onlyOwner {
        waiting = _waiting;
        timeout = _timeout;
        TimingSet(_waiting, _timeout);
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

    function propose(
        address addr,
        address[] memory revokeds,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(!stopped, "contract is stopped");
        bytes32 message = keccak256(abi.encodePacked(addr, revokeds));
        address signer = ecrecover(message, v, r, s);
        require(proposerToken.balanceOf(signer) > 0, "not authorized");
        proposals[message] = block.number;
        emit Proposed(addr);
    }

    function verify(address addr, address[] memory revokeds) public {
        require(!stopped, "contract is stopped");
        bytes32 message = keccak256(abi.encodePacked(addr, revokeds));
        uint pblock = proposals[message];
        require(pblock > 0, "not proposed");
        require(block.number - pblock > waiting, "proposal is waiting");
        require(block.number - pblock < timeout, "proposal timed out");

        verifications[addr] = block.number;
        emit Verified(addr);
        for(uint i = 0; i < revokeds.length; i++) {
            verifications[revokeds[i]] = 0;
            history[addr] = revokeds[i];
            addr = revokeds[i];
        }
    }
}
