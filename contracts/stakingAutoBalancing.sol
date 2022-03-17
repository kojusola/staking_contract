//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakingAutoBalancingContract {
    IERC721 public _BoredApeNFT;
    IERC20 public _token;
    uint constant secPerDay = 86400;
  struct  stakes {
        uint amount;
        uint timeStaked;
        uint minimumTimeDue;
        bool staked;
    }
    event stakesEvent (address staker, uint _amount, uint _timeStaked);
    event viewStakes(address staker, stakes);
    event withdrawal (address staker, uint _amount);

    mapping(address => stakes) records;

    constructor(address token){
        _token = IERC20(token);
        _BoredApeNFT = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
    }
    function interestCalc(uint _amount,uint _timeStaked, uint _timeStakeLimit, uint _presentTime) public pure returns (uint){
        if(_presentTime > _timeStakeLimit){
            uint length = _presentTime - _timeStaked;
            uint dayNumber = length/ secPerDay;
            if(dayNumber > 3 ){
               uint interest = (_amount * 1/10) * dayNumber;
               return interest;
            }else {
               uint interest = (_amount * 1/10) * 3;
               return interest;
            }
        }else{
            return 0;
        }
       
    }

    function Stake (uint _amount) public returns (bool) {
         require(_amount > 0, "You need to stake at least some tokens");
        uint256 tokenBalance = _token.balanceOf(msg.sender);
        require(tokenBalance>= _amount, "You do not have enough tokens");
          uint256 NFTBalance = _BoredApeNFT.balanceOf(msg.sender);
        require(NFTBalance > 0, "You can only stake if you are an owner of a Bored Ape NFT" );
        bool transferred = _token.transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Token Transfer Failed");
        stakes memory user = records[msg.sender];
        if(records[msg.sender].staked){
            uint interest = interestCalc(user.amount, user.timeStaked, user.minimumTimeDue, block.timestamp);
            uint _totalDue = interest + _amount + records[msg.sender].amount;
            user.amount = _totalDue;
            user.timeStaked = block.timestamp;
            user.minimumTimeDue = block.timestamp + 259200;
        } else{
            user.amount = _amount;
            user.timeStaked = block.timestamp;
            user.minimumTimeDue = block.timestamp + 259200;
            user.staked = true;
        }
        emit stakesEvent (msg.sender, _amount,  block.timestamp);
        return true;
    }


      function WithDrawAll() public returns (bool) {
        require (records[msg.sender].amount > 0, "You need to stake to withdraw");
        stakes memory user= records[msg.sender];
        uint interest = interestCalc(user.amount,user.timeStaked, user.minimumTimeDue,block.timestamp);
        uint totalWithdrawal;
        totalWithdrawal = user.amount + interest;
        user.staked = false;
         _token.transfer(msg.sender, totalWithdrawal);
        emit withdrawal  (msg.sender, totalWithdrawal);
        return true;
    }

     function WithAnAmount(uint _amount) public returns (bool) {
        require (records[msg.sender].amount > 0, "You need to stake to withdraw");
        stakes memory user= records[msg.sender];
        uint interest = interestCalc(user.amount,user.timeStaked, user.minimumTimeDue,block.timestamp);
        uint totalRemaining;
        totalRemaining = user.amount + interest;
        require(totalRemaining > _amount, "You do not have enough Balance to widthdraw that amount");
        user.amount = totalRemaining - _amount;
        user.timeStaked = block.timestamp;
        user.minimumTimeDue = block.timestamp + 259200;
         _token.transfer(msg.sender, _amount);
        emit withdrawal(msg.sender, _amount);
        return true;
    }

      function WithdrawOnlyInterests () public returns (bool) {
        require (records[msg.sender].amount > 0, "You need to stake to withdraw");
        stakes memory user= records[msg.sender];
        uint interest = interestCalc(user.amount,user.timeStaked, user.minimumTimeDue,block.timestamp);
        _token.transfer(msg.sender, interest );
        user.timeStaked = block.timestamp;
        user.minimumTimeDue = block.timestamp + 259200;
        emit withdrawal  (msg.sender, interest );
        return true;
    }

    function viewStake() public returns (bool) {
        require (records[msg.sender].amount > 0, "You need to stake");
        stakes memory user= records[msg.sender];
        emit viewStakes(msg.sender, user);
        return true;
    }
}
