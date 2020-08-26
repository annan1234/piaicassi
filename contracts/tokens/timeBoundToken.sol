// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
///////////// impoting interface of erc20 //////////////////////
import "./IERC20.sol";

contract timeBoundToken is IERC20{
//////////////////////////// creation of token ////////////////////////
address  owner;
string public name;
string public symbol;
uint256 TotalSupply;
uint8 public decimal;

mapping(address => uint256) balance;
mapping(address => mapping(address => uint256)) allow;

    modifier onlyOwner(){
        require (msg.sender == owner , "you are not an owner");
        _;
    }


    constructor(string memory _nam , string memory _sym , uint256 _supp , uint8 _dec)public{
        
        owner = msg.sender;
        name = _nam;
        symbol = _sym;
        decimal = _dec;
        TotalSupply = _supp * 10 ** uint256(_dec);
        balance[address(this)] = TotalSupply;
        
    }
    
    function balanceOf(address _add)public view override returns(uint256) {
        return balance[_add];
    }    
    
    function totalSupply() external view override returns(uint256){
        return TotalSupply;
    }
    
    function transfer(address recepient , uint256 amount) external override returns(bool){
        require(recepient != address(0), "recepient address is 0)");

        if(msg.sender == owner) {
          _transfer(address(this) , recepient , amount);
          emit Transfer(address(this) , recepient , amount);
        } 
        else{ 
           
             if(balance[msg.sender] <= amount){               //if(timer[msg.sender] == true){revert();} else {
        
            revert("u have insufficient tokens");
             }
              else{
                    
                if(locked[msg.sender] == true){
                    unboundMyToken(msg.sender , recepient , amount);
                }
                 else{
                     _transfer(msg.sender , recepient , amount);
                     emit Transfer(msg.sender , recepient , amount);
                 }
                  }
            
        }
        
        return true;
    }
    
    
    function approve(address spender , uint256 amount) external override returns(bool){
        require(spender != address(0), "spender is 0 address");
        require(balance[msg.sender] >= amount , "you have not insufficient tokens");
        allow[msg.sender][spender] = allow[msg.sender][spender] + amount;
        emit allowed(msg.sender , spender , amount);
        return true;
    }
    
    function transferFrom(address tokenOwner , address recepient , uint256 amount) external override returns(bool){
        require(tokenOwner != address(0), "Token owner address is 0)");
        require(recepient != address(0), "recepient address is 0)");
        require(balance[tokenOwner] >= amount, "u have insufficient tokens");
        require(allow[tokenOwner][msg.sender] >= amount , "u have not allowed enough tokens to transfer");
        balance[tokenOwner] = balance[tokenOwner] - amount;
        balance[recepient] = balance[recepient] + amount;
        allow[tokenOwner][msg.sender] = allow[tokenOwner][msg.sender] - amount;
        emit Transfer(tokenOwner , recepient , amount);
        return true;
        
        
    }
    
    function allowance(address tokenOwner , address spender )external view override returns (uint256){
        require(tokenOwner != address(0), "Token owner address is 0)");
        require(spender != address(0), "spender is 0 address");
         uint a = allow[tokenOwner][spender] ;
         return a;
         
        
    }
//////////////////////////////// internal transfer function   ///////////////////////////////////////
    function _transfer(address from , address to , uint256 amount) internal {
         require(balance[from] >= amount , "insufficient tokens in contract");
        balance[from] = balance[from] - amount;
        balance[to] = balance[to] + amount;
        
      
    }
    
////////////////////////////////minting of token /////////////////////////////////////////////

    function mint(uint amount , address _add)external virtual onlyOwner returns(bool){
        require(_add != address(0));
        TotalSupply = TotalSupply + amount;
        balance[_add] = balance[_add] + amount;
        return true;
    }
    
/////////////////////////////////burning of token /////////////////////////////////// 

    function burnToken(address from ,uint amount)external onlyOwner returns(bool){
        require(from != address(0));
        balance[from] = balance[from] - amount;
        TotalSupply = TotalSupply - amount;
    }
//////////////////////////////////time token ////////////////////////////////////////
                  //time for 30days
uint public time; // = 60*60*24*30;
////////////////////////////////// tells the current time//////////////////////////////////////////////
function currentTime() public view returns(uint){
    return now;
}
//////////////////////////////////tells the locked time of given address //////////////////////////////////
function boundTime(address _add)public view returns(uint){
    return timeLock[_add];
}

mapping (address => uint) timeLock;
mapping (address => bool) locked;

///////////////////////////////////lock tokens for given tym in days of given address//////////////////////////////////
function boundToken(address recepient , uint _tym)public onlyOwner {
    time = 60*60*24* _tym; //bound time in days
    timeLock[recepient]= block.timestamp + time;
    locked[recepient] = true;
}
//////////////////////////////internal function for checking the tokens lock///////////////////////////
function unboundMyToken(address from , address to , uint amount) internal {
    if(locked[msg.sender] == false){
        _transfer(from , to , amount);
        emit Transfer(from , to , amount);
    }
       else{
            
            if(now >= timeLock[msg.sender]){
        locked[msg.sender] = false;
            } 
               else{
        revert("u have not completed your bound token time");
                   }
           
       }
    
    
    }

}