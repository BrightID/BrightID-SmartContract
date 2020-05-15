pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract BrightID is Ownable {

    event Verified(address indexed addr, address indexed revoked);
    mapping(address => uint) public verifications;
    mapping(address => address) public history;

    function verify(address addr, address revoked) public onlyOwner
    {
        verifications[addr] = block.timestamp;
        if (revoked != address(0)) {
            verifications[revoked] = 0;
            history[addr] = revoked;
        }
        emit Verified(addr, revoked);
    }
    
}
