//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakeContract {
    IERC721 public _BoredApeNFT;
  struct  stakers {
        uint amount;
        uint timeStaked;
        uint amountDue;
        uint timeDue;
    }
    event stakes (address staker, uint _amount, uint _timeStaked);
    event withdrawal (address staker, uint _amount);

    mapping(address => stakers) records;

    constructor(){
        _BoredApeNFT = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
    }

    function Stake (uint _amount, uint _timeStaked, IERC20 token  ) public returns (bool) {
         require(_amount > 0, "You need to stake at least some tokens");
        uint256 tokenBalance = token.balanceOf(msg.sender);
        require(tokenBalance>= _amount, "You do not have enough tokens");
          uint256 NFTBalance = _BoredApeNFT.balanceOf(msg.sender);
        require(NFTBalance > 0, "You can only stake if you are an owner of a Bored Ape NFT" );
        bool transferred = token.transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Token Transfer Failed");
        stakers memory user;
        user.amount = _amount;
        user.timeStaked = _timeStaked;
        user.amountDue = (_amount * 110)/100;
        user.timeDue = _timeStaked + 259200;
        records[msg.sender] = user;
        emit stakes (msg.sender, _amount,  _timeStaked);
        return true;
    }


      function WithDrawStake ( uint _presentTime, IERC20 token ) public returns (bool) {
        require (records[msg.sender].amount > 0, " You need to stake to withdraw");
        stakers memory user= records[msg.sender];
        if(_presentTime >= user.timeDue){
             token.transfer(msg.sender, user.amountDue);
             emit withdrawal  (msg.sender, user.amountDue);
        }else {
            token.transfer(msg.sender, user.amount);
            emit withdrawal  (msg.sender, user.amount);
        }
        return true;
    }
}
