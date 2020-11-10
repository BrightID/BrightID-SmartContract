pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/BrightID/BrightID-SmartContract/blob/master/v4/IBrightID.sol";

contract StoppableBrightID is Ownable, IBrightID {

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

    struct Verification {
        uint256 time;
        bool isVerified;
    }
    mapping(address => Verification) override public verifications;
    mapping(bytes32 => uint) public proposals;
    mapping(address => address) override public history;

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
        bytes32 context,
        address[] memory addrs,
        uint timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(!stopped, "contract is stopped");

        bytes32 message = keccak256(abi.encodePacked(context, addrs, timestamp));
        address signer = ecrecover(message, v, r, s);
        require(proposerToken.balanceOf(signer) > 0, "not authorized");

        proposals[message] = block.number;
        emit Proposed(addrs[0]);
    }

    function verify(
        bytes32 context,
        address[] memory addrs,
        uint timestamp
    ) public {
        require(!stopped, "contract is stopped");
        require(verifications[addrs[0]].time < timestamp, "newer verification registered before");

        bytes32 message = keccak256(abi.encodePacked(context, addrs, timestamp));
        uint pblock = proposals[message];
        require(pblock > 0, "not proposed");
        require(block.number - pblock > waiting, "proposal is waiting");
        require(block.number - pblock < timeout, "proposal timed out");

        verifications[addrs[0]].time = timestamp;
        verifications[addrs[0]].isVerified = true;
        for(uint i = 1; i < addrs.length; i++) {
            verifications[addrs[i]].time = timestamp;
            verifications[addrs[i]].isVerified = false;
            history[addrs[i - 1]] = addrs[i];
        }
        emit Verified(addrs[0]);
    }

}
