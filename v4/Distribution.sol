pragma solidity ^0.6.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract BrightID {
    mapping(address => uint) public verifications;
    mapping(address => address) public history;
}

contract Distribution is Ownable {
    using SafeMath for uint256;

    uint256 public claimable = 0;
    BrightID public brightid;
    mapping(address => uint256) public claimed;

    receive () external payable {}

    function setClaimable(uint256 _claimable) public onlyOwner {
        claimable = _claimable;
    }

    function setBrightid(address addr) public onlyOwner {
        brightid = BrightID(addr);
    }

    function claim(address payable beneficiary, uint256 amount) public {
        require(brightid.verifications(beneficiary) > 0, "beneficiary is not verified");
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
