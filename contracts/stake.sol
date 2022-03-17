//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakeContract {
    IERC721 public _BoredApeNFT;
    IERC20 public _token;
    uint constant secPerMonth = 2592000;
  struct  stakes {
        uint amount;
        uint timeStaked;
        uint amountDue;
        uint minimumTimeDue;
        bool staked;
        bool withdrawn;
        bool withdrawnInterest;
    }
    event stakesEvent (address staker, uint _amount, uint _timeStaked, stakes[]);
    event viewStakes(address staker, stakes[]);
    event withdrawal (address staker, uint _amount);

    mapping(address => stakes[]) records;

    constructor(address token){
        _token = IERC20(token);
        _BoredApeNFT = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
    }
    function interestCalc(uint _amount,uint _timeStaked, uint _timeStakeLimit, uint _presentTime) public pure returns (uint){
        if(_presentTime > _timeStakeLimit){
            uint length = _presentTime - _timeStaked;
            uint monthNumber = length/ secPerMonth;
            if(monthNumber > 1 ){
               uint interest = (_amount * 1/10) * monthNumber;
               return interest;
            }else {
               uint interest = (_amount * 1/10);
               return interest;
            }
        }else{
            return 0;
        }
       
    }

    function Stake (uint _amount, uint _timeStaked ) public returns (bool) {
         require(_amount > 0, "You need to stake at least some tokens");
        uint256 tokenBalance = _token.balanceOf(msg.sender);
        require(tokenBalance>= _amount, "You do not have enough tokens");
          uint256 NFTBalance = _BoredApeNFT.balanceOf(msg.sender);
        require(NFTBalance > 0, "You can only stake if you are an owner of a Bored Ape NFT" );
        bool transferred = _token.transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Token Transfer Failed");
        stakes memory user;
        user.amount = _amount;
        user.timeStaked = _timeStaked;
        user.minimumTimeDue = _timeStaked + 259200;
        records[msg.sender].push(user);
        emit stakesEvent (msg.sender, _amount,  _timeStaked, records[msg.sender]);
        return true;
    }


      function WithDrawAll ( uint _presentTime) public returns (bool) {
        require (records[msg.sender].length > 0, "You need to stake to withdraw");
        stakes[] memory user= records[msg.sender];
        uint totalWithdrawal;
        for(uint i = 0; i< user.length; i++){
            if(!user[i].withdrawn){
                uint interest = interestCalc(user[i].amount,user[i].timeStaked, user[i].minimumTimeDue, _presentTime);
                uint total = user[i].amount + interest;
                totalWithdrawal += total;
            }
        }
         _token.transfer(msg.sender, totalWithdrawal);
        emit withdrawal(msg.sender, totalWithdrawal);
        return true;
    }

      function WithdrawOnlyInterests ( uint _presentTime) public returns (bool) {
        require (records[msg.sender].length > 0, "You need to stake to withdraw");
        stakes[] memory user= records[msg.sender];
        uint totalWithdrawal;
        for(uint i = 0; i< user.length; i++){
            if(!user[i].withdrawn){
                uint interest = interestCalc(user[i].amount,user[i].timeStaked, user[i].minimumTimeDue, _presentTime);
                totalWithdrawal += interest;
            }
            user[i].timeStaked = _presentTime;
            user[i].minimumTimeDue = _presentTime + secPerMonth;
        }
         _token.transfer(msg.sender, totalWithdrawal);
        emit withdrawal  (msg.sender, totalWithdrawal);
        return true;
    }

    function WithdrawSingleStake( uint _presentTime, uint _stakeNumber) public returns (bool) {
        require (records[msg.sender].length > 0, "You need to stake to withdraw");
        require (records[msg.sender][_stakeNumber].amount > 0, "You do not have any stake with this number");
        stakes memory user= records[msg.sender][_stakeNumber];
        uint interest = interestCalc(user.amount,user.timeStaked, user.minimumTimeDue, _presentTime);
        uint totalWithdrawal;
        totalWithdrawal = user.amount + interest;
         _token.transfer(msg.sender, totalWithdrawal);
        emit withdrawal  (msg.sender, totalWithdrawal);
        return true;
    }

    function viewAllStakes() public returns (bool) {
        require (records[msg.sender].length > 0, "You need to stake");
        stakes[] memory user= records[msg.sender];
        emit viewStakes(msg.sender, user);
        return true;
    }
}
