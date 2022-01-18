// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./Ownable.sol";
import "./IERC20.sol";
import "./IBrightIDSnapshot.sol";


//-------------------Contracts-------------------------------
contract BrightIDSnapshot is Ownable, IBrightIDSnapshot {
    
    //-------------------Storage-----------------------------    
    IERC20 public verifierToken; // address of verification Token  
    bytes32 public app; // Registered BrightID app name 
    uint32 constant public REGISTRATION_PERIOD = 2592000; // One month
    
    struct Verification {
        uint256 time;
        bool isVerified;
    }

    
    
    //-------------------Events-----------------------------
    event Verified(address indexed addr);
    event VerifierTokenSet(IERC20 verifierToken);
    event AppSet(bytes32 _app);
    event Sponsor(address indexed addr);

    
    //-------------------Mappings---------------------------
    mapping(address => Verification) public verifications;
    mapping(address => address) public history;
    
 
    
    //-------------------Constructor-------------------------
    /**
     * @param _verifierToken verifier token
     * @param _app BrightID app used for verifying users
     */
    constructor(IERC20 _verifierToken, bytes32 _app) {
        verifierToken = _verifierToken;
        app = _app; 
    }
    

    // emits a sponsor event for brightID nodes 
    function sponsor(address addr) public {
        emit Sponsor(addr);
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
     * @notice Set verifier token
     * @param _verifierToken verifier token
     */
    function setVerifierToken(IERC20 _verifierToken) public onlyOwner {
        verifierToken = _verifierToken;
        emit VerifierTokenSet(_verifierToken);
    }

    /**
     * @notice Register a user by BrightID verification
     * @param addrs The history of addresses used by this user in the app
     * @param timestamp The BrightID node's verification timestamp
     * @param v Component of signature
     * @param r Component of signature
     * @param s Component of signature
     */
    function verify(
        address[] memory addrs,
        uint timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(verifications[addrs[0]].time < timestamp, "Newer verification registered before.");
        require (timestamp > block.timestamp - REGISTRATION_PERIOD, "Verification too old. Try linking again.");
        
        bytes32 message = keccak256(abi.encodePacked(app, addrs, timestamp));
        address signer = ecrecover(message, v, r, s);
        require(verifierToken.balanceOf(signer) > 0, "not authorized");

        verifications[addrs[0]].time = timestamp;
        verifications[addrs[0]].isVerified = true;
        for(uint i = 1; i < addrs.length; i++) {
            require(verifications[addrs[i]].time < block.timestamp - REGISTRATION_PERIOD * 2, "Address changed too recently. Wait for next registration period.");
            verifications[addrs[i]].time = timestamp;
            verifications[addrs[i]].isVerified = false;
            history[addrs[i - 1]] = addrs[i];
        }
        emit Verified(addrs[0]);
    }

    /**
     * @notice Check an address is verified or not
     * @param _user The context id used for verifying users
     */
    function isVerifiedUser(address _user) external view returns (bool) {
        return verifications[_user].isVerified;
    }

    /**
     * @notice Return the last address used by a user
     * @param addr The user's newest address
     */
    function history(address addr) external view returns (address) {
        return history[addr];
    }
}