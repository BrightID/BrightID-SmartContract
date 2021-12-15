pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/ERC20.sol";
import "./IBrightID.sol";

contract StoppableBrightID is Ownable, IBrightID {
    IERC20 public supervisorToken;
    IERC20 public proposerToken;
    bytes32 public app;
    bytes32 public verificationHash;

    event Verified(address indexed addr);
    event Proposed(address indexed addr);
    event Started();
    event Stopped(address stopper);
    event TimingSet(uint waiting, uint timeout);
    event MembershipTokensSet(IERC20 supervisorToken, IERC20 proposerToken);
    event AppSet(bytes32 _app);
    event VerificationHashSet(bytes32 verificationHash);

    bool public stopped = false;
    uint public waiting;
    uint public timeout;

    struct Verification {
        uint256 time;
        bool isVerified;
    }
    mapping(address => Verification) public verifications;
    mapping(bytes32 => uint) public proposals;

    /**
     * @param _supervisorToken supervisor ERC20 token
     * @param _proposerToken proposer ERC20 token
     * @param _app BrightID app used for verifying users
     * @param _waiting The waiting amount in block number
     * @param _timeout The timeout amount in block number
     * @param _verificationHash sha256 of the verification expression
     */
    constructor(
        IERC20 _supervisorToken,
        IERC20 _proposerToken,
        bytes32 _app,
        uint _waiting,
        uint _timeout,
        bytes32 _verificationHash
    ) public {
        supervisorToken = _supervisorToken;
        proposerToken = _proposerToken;
        app = _app;
        waiting = _waiting;
        timeout = _timeout;
        verificationHash = _verificationHash;
    }

    /**
     * @notice Set the app
     * @param _app BrightID app used for verifying users
     */
    function setApp(bytes32 _app) public onlyOwner {
        app = _app;
        emit AppSet(_app);
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
     * @param addr The address used by this user in the app
     * @param timestamp The BrightID node's verification timestamp
     * @param v Component of signature
     * @param r Component of signature
     * @param s Component of signature
     */
    function propose(
        address addr,
        uint timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(!stopped, "contract is stopped");

        bytes32 message = keccak256(abi.encodePacked(app, addr, verificationHash, timestamp));
        address signer = ecrecover(message, v, r, s);
        require(proposerToken.balanceOf(signer) > 0, "not authorized");

        proposals[message] = block.number;
        emit Proposed(addr);
    }

    /**
     * @notice Verify a registration
     * @param addr The address used by this user in the app
     * @param timestamp The BrightID node's verification timestamp
     */
    function verify(
        address addr,
        uint timestamp
    ) public {
        require(!stopped, "contract is stopped");

        bytes32 message = keccak256(abi.encodePacked(app, addr, verificationHash, timestamp));
        uint pblock = proposals[message];
        require(pblock > 0, "not proposed");
        require(block.number - pblock > waiting, "proposal is waiting");
        require(block.number - pblock < timeout, "proposal timed out");

        verifications[addr].time = timestamp;
        verifications[addr].isVerified = true;
        emit Verified(addr);
    }

    /**
     * @notice Check an address is verified or not
     * @param addr The context id used for verifying users
     */
    function isVerified(address addr) override external view returns (bool) {
        return verifications[addr].isVerified;
    }
}
