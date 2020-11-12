pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/BrightID/BrightID-SmartContract/blob/master/v4/IBrightID.sol";

contract StoppableBrightID is Ownable, IBrightID {
    IERC20 public supervisorToken;
    IERC20 public proposerToken;
    bytes32 public verificationHash;
    bytes32 public context;

    event Verified(address indexed addr);
    event Proposed(address indexed addr);
    event Started();
    event Stopped(address stopper);
    event TimingSet(uint waiting, uint timeout);
    event MembershipTokensSet(IERC20 supervisorToken, IERC20 proposerToken);
    event VerificationHashSet(bytes32 verificationHash);
    event ContextSet(bytes32 _context);

    bool public stopped = false;
    uint public waiting;
    uint public timeout;

    struct Verification {
        uint256 time;
        bool isVerified;
    }
    mapping(address => Verification) public verifications;
    mapping(bytes32 => uint) public proposals;
    mapping(address => address) override public history;

    /**
     * @param _supervisorToken supervisor ERC20 token
     * @param _proposerToken proposer ERC20 token
     * @param _verificationHash sha256 of the verification expression
     * @param _context BrightID context used for verifying users
     * @param _waiting The waiting amount in block number
     * @param _timeout The timeout amount in block number
     */
    constructor(
        IERC20 _supervisorToken,
        IERC20 _proposerToken,
        bytes32 _verificationHash,
        bytes32 _context,
        uint _waiting,
        uint _timeout
    ) public {
        supervisorToken = _supervisorToken;
        proposerToken = _proposerToken;
        verificationHash = _verificationHash;
        context = _context;
        waiting = _waiting;
        timeout = _timeout;
    }

    /**
     * @notice Set the context
     * @param _context BrightID context used for verifying users
     */
    function setContext(bytes32 _context) public onlyOwner {
        context = _context;
        emit ContextSet(_context);
    }

    /**
     * @notice Set verification hash
     * @param _verificationHash sha256 of the verification expression
     */
    function setVerificationHash(bytes32 _verificationHash) public onlyOwner {
        verificationHash = _verificationHash;
        emit VerificationHashSet(_verificationHash);
    }

    /**
     * @notice Set supervisor and proposer Tokens
     * @param _supervisorToken supervisor ERC20 token
     * @param _proposerToken proposer ERC20 token
     */
    function setMembershipTokens(IERC20 _supervisorToken, IERC20 _proposerToken) public onlyOwner {
        supervisorToken = _supervisorToken;
        proposerToken = _proposerToken;
        MembershipTokensSet(_supervisorToken, _proposerToken);
    }

    /**
     * @notice Set waiting and timeout values
     * @param _waiting The waiting amount in block number
     * @param _timeout The timeout amount in block number
     */
    function setTiming(uint _waiting, uint _timeout) public onlyOwner {
        waiting = _waiting;
        timeout = _timeout;
        TimingSet(_waiting, _timeout);
    }

    /**
     * @notice Stop the contract
     */
    function stop() public {
        require(supervisorToken.balanceOf(msg.sender) > 0, "not authorized");
        stopped = true;
        emit Stopped(msg.sender);
    }

    /**
     * @notice Start the contract
     */
    function start() public onlyOwner {
        stopped = false;
        emit Started();
    }

    /**
     * @notice Propose a registration
     * @param addrs The history of addresses used by this user in the context
     * @param timestamp The BrightID node's verification timestamp
     * @param v Component of signature
     * @param r Component of signature
     * @param s Component of signature
     */
    function propose(
        address[] memory addrs,
        uint timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(!stopped, "contract is stopped");

        bytes32 message = keccak256(abi.encodePacked(context, addrs, verificationHash, timestamp));
        address signer = ecrecover(message, v, r, s);
        require(proposerToken.balanceOf(signer) > 0, "not authorized");

        proposals[message] = block.number;
        emit Proposed(addrs[0]);
    }

    /**
     * @notice Verify a registration
     * @param addrs The history of addresses used by this user in the context
     * @param timestamp The BrightID node's verification timestamp
     */
    function verify(
        address[] memory addrs,
        uint timestamp
    ) public {
        require(!stopped, "contract is stopped");
        require(verifications[addrs[0]].time < timestamp, "newer verification registered before");

        bytes32 message = keccak256(abi.encodePacked(context, addrs, verificationHash, timestamp));
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

    /**
     * @notice Check an address is verified or not
     * @param addr The context id used for verifying users
     */
    function isVerified(address addr) override external view returns (bool) {
        return verifications[user].isVerified;
    }
}
