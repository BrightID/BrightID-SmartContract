pragma solidity ^0.8.0;

interface IBrightIDSnapshot {
    event Verified(address indexed addr);
    function isVerifiedUser(address _user) external view returns (bool);
    function history(address addr) external view returns (address);
}
