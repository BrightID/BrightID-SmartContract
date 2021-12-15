pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/ERC20.sol";
import "./IBrightID.sol";

contract Distribution is Ownable {
    using SafeMath for uint256;

    uint256 public claimable = 0;
    IBrightID public brightid;
    mapping(address => uint256) public claimed;

    receive () external payable {}

    function setClaimable(uint256 _claimable) public onlyOwner {
        claimable = _claimable;
    }

    function setBrightid(address addr) public onlyOwner {
        brightid = IBrightID(addr);
    }

    function claim(address payable beneficiary, uint256 amount) public {
        require(brightid.isVerified(beneficiary) > 0, "beneficiary is not verified");
        address tmp = beneficiary;
        uint256 sum = 0;
        while (tmp != address(0)) {
            sum = sum.add(claimed[tmp]);
            tmp = brightid.history(tmp);
        }
        require(claimable >= sum.add(amount), "total claimed amount is more than claimable");        
        claimed[beneficiary] = claimed[beneficiary].add(amount);
        beneficiary.transfer(amount);
    }

}
