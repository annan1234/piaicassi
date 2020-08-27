//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import "./buyable.sol";
 contract buyableExtension is buyable{
    
    constructor(string memory _nam , string memory _sym , uint256 _totalSupply ,uint _eth) buyable( _nam ,  _sym , _totalSupply , _eth) public{
    
        
        
    }
    uint lockTime;
    bool Token;
    event timeLocked(string);
       mapping (address => bool) priceOperator;
    function transferOwnerShip(address newOwner) public onlyOwner returns(bool){
        owner = newOwner;
        _transfer(msg.sender , newOwner , balance[msg.sender]);
        priceOperator[msg.sender] = true;
    }    
    
    function setOperatorApproval(address operator , bool approval) public onlyOwner {
        priceOperator[operator] = approval; 
    }
    
    function adjustPrice(uint _price)public override returns(bool) {
        if(msg.sender == owner){
             price = _price * 1000000000000000000;
             return true;
        } 
            else{
                  if (priceOperator[msg.sender] == true){
                        price =_price * 1000000000000000000;
                        return priceOperator[msg.sender];
                  }
                      else{
                          
                          revert("your are not an owner nor you are approved operator");
                          
                      }
            }
        
        
    } 
    
    function ReturnToken( uint amount)  public returns(bool) {
        require(amount >= 5);
        require(balance[msg.sender] >= amount);             
       if(Token== true){
           lockedOrUnlocked(amount);
           
       } 
         else {
                
         
         uint a = (amount * price )/(10**uint256(decimal));  
         msg.sender.transfer(a);
             _transfer(msg.sender , address(this) , amount);
         }
         return true;
        
    }
//////////////////// this will locked the return functioon one month//////////////////         
function lockReturnToken()public onlyOwner{
    lockTime = block.timestamp + (60*60*24*30);
    Token = true;
    emit timeLocked("tokens are locked for one month");
    
}

///////////////////////internal function for unlocking/checking tokens ///////////////////////       
function lockedOrUnlocked(uint amount)internal returns(string memory ){

    if(now >= lockTime){
        Token = false;
        uint a = (amount * price )/(10**uint256(decimal));  
         msg.sender.transfer(a);
         _transfer(msg.sender , address(this) , amount);
        return "unlocked";
        
    }
     else {
           revert("tokens are locked");
           
     }
}
         
         
    
}