// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
interface IRealestate {
      struct FractionAsset{
         address nft;
         uint tokenId;   
         uint assetPrice;
         bytes size;
         uint rentPrice;
     }
      function getfractionassetdetails(uint Assetid,uint fractionassetid) public view returns (FractionAsset memory){
        
}
interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}


contract Loan {
uint constant duration = 5 years;
uint public totalstakingtoken;
uint public totalrewardtoken;
mapping(address=> uint) public staktokens;
mapping(address=> uint) public loanamount;
mapping(address=> uint[]) Id;
mapping(address => uint) public endtime;
IERC20 public immutable token; 
    
IRealestate public immutable nftrealestate;
uint public rewardrate;
event stake(address staker,uint amount);
event withdraw(address staker,uint amount);
event getloan(address owner,uint assetid,uint fassetid,uint loanamount,uint interest);
event loanpay(address payer, uint payamount);

 constructor(address _token) {
        token = IERC20(_token);
    }


function Stake(uint _amount) external {
    require(_amount>0,"amount is zero");
    token.transferFrom(msg.sender,address(this),_amount);
    totalstakingtoken += _amount;
    endtime[msg.sender] = block.timestamp+duration;
    staktokens[msg.sender] = _amount;
    rewardrate = totalrewardtoken/totalstakingtoken; 
    emit stake(msg.sender,_amount);
}

function GetLoan(uint assetid, uint fractionassetid) external {
    FractionAsset memory fasset = nftrealestate.getfractionassetdetails(assetid,fractionassetid);
    address owner = nftrealestate.getfractionassetowner(asseid,fractionassetid);
    require(owner == msg.sender,"you are not owner");
    uint price = fasset.price;
    uint tokenid = fasset.tokenid;
    address nftaddr = fasset.nft;
    uint contractbalance = token.balanceOf(address(this));
    uint senderbalance = token.balanceOf(msg.sender);
    uint Loanamount = price*75/100;
    uint interest = loanamount*5/100;
    require(contractbalance> loanamount,"marketace have not enough tokens");
    require(senderbalance >= interest,"you have not enough interest to pay" );
    nftaddr.transferFrom(nftrealestate,address(this),tokenid);
    token.transferFrom(address(this),msg.sender,loanamount);
    token.transferFrom(msg.sender,address(this),interest);
    loanamount[msg.sender]= Loanamount;
    endtime[msg.sender]= block.timestamp+duration;
    totalstakingtoken -= Loanamount;
    totalrewardtoken += interest;
    Id[msg.sender].push(assetid);
    Id[msg.sender].push(fractionassetid);
    rewardrate = totlrewardtoken/totalstakingtoken; 
    emit getloan(owner, assetid, fractionassetid,Loanamount,interest);

}

function Payloan() external{
    uint[] Index = Id[msg.sender];
    assetid = Index[0];
    fassetid = Index[1];
    uint _endtime = endtime[msg.sender];
    uint payamount = loanamount[msg.sender];
    FractionAsset memory fasset = nftrealestate.getfractionassetdetails(assetid,fractionassetid);
    address nftaddr = fasset.nft;
    uint _tokenid = fasset.tokenid;
    token.transferFrom(msg.sender,address(this),payamount);
    nftaddr.transferFrom(address(this),nftrealestate,_tokenid);
    totalstakingtoken += payamount;
    loanamount[msg.sender] = 0;
    rewardrate = totalrewardtoken/totalstakingtoken;
    emit loanpay(msg.sender,payamount);

}

function Withdraw() external{
    uint amount = staketokens[msg.sender];
    require(amount>0,"amount is zero");
    uint _endtime = endtime[msg.sender];
    require(block.timestamp >= _endtime,"time not reached" );
    uint reward = rewardrate*amount;
    uint totalamount = amount+reward;
    token.transferFrom(address(this),msg.sender,totalamount);
    totalstakingtoken -= amount;
    totalrewardtoken -= amount;
    staketoken[msg.sender] = 0;
    rewardrate = totlrewardtoken/totalstakingtoken;
    emit Withdraw(msg.sender,totalamount);


} 
function getstaketoken(address staker) public view returns(uint) {
    return staketokens[staker];
}
function getloanamount(address loantaker) public view returns(uint){
    return loanamount[loantaker];
}
function getassetid(address owner) public view returns(uint[]){
    return Id[owner];
}
}
