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

    mapping(bytes32 => uint) public proposals;
    mapping(address => uint) override public verifications;
    mapping(address => address) override public history;
    mapping(address => bool) public isRevoked;

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
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(!stopped, "contract is stopped");
        require(!isRevoked[addrs[0]], "address was revoked");
        bytes32 message = keccak256(abi.encodePacked(context, addrs));
        address signer = ecrecover(message, v, r, s);
        require(proposerToken.balanceOf(signer) > 0, "not authorized");
        proposals[message] = block.number;
        emit Proposed(addrs[0]);
    }

    function verify(
        bytes32 context,
        address[] memory addrs
    ) public {
        require(!stopped, "contract is stopped");
        require(!isRevoked[addrs[0]], "address was revoked");
        bytes32 message = keccak256(abi.encodePacked(context, addrs));
        uint pblock = proposals[message];
        require(pblock > 0, "not proposed");
        require(block.number - pblock > waiting, "proposal is waiting");
        require(block.number - pblock < timeout, "proposal timed out");

        verifications[addrs[0]] = block.number;
        for(uint i = 1; i < addrs.length; i++) {
            verifications[addrs[i]] = 0;
            isRevoked[addrs[i]] = true;
            history[addrs[i - 1]] = addrs[i];
        }
        emit Verified(addrs[0]);
    }

}
