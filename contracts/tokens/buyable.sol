//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import"./myToken.sol";
 contract buyable is IERC20{
  /////////////////////////////// creation of token /////////////////////////
   address  owner;
    string public nameOfToken;
    string public symbol;
    uint8  decimal;
    uint256 public override totalSupply;
    uint public price;
    mapping (address => uint256) balance;
    mapping (address => mapping(address => uint256)) allow;
    
    modifier onlyOwner{
        require(msg.sender == owner , "you are not a owner");
        _;
    }
    
//////////////////////// naming and setting total supply of token/////////////////
    constructor(string memory _nam , string memory _sym , uint256 _totalSupply ,uint _eth)public{
        owner = msg.sender;
        nameOfToken = _nam;
        symbol = _sym;
        decimal = 19;
        price = _eth * 1000000000000000000;
        totalSupply = _totalSupply * 10 ** uint256(decimal);
        balance[address(this)]  = totalSupply;
        allow[address(this)][owner] = totalSupply;  // owner can transfer tokens by transferFrom function
        }
//////// /////////// balance of given address //////////////////  
        function balanceOf(address yourAdd) public view override returns(uint256){
            return balance[yourAdd];
        }
//////////////////////// transfering of token /////////////////// 
        function transfer(address recepient,uint256 amount) public override returns(bool){
            require(recepient != address(0), "recepient address is null");
            require(balance[msg.sender] >= amount ," insuffieceint tokens in your account");
            balance[msg.sender] = balance[msg.sender] - amount;
            balance[recepient] = balance[recepient] + amount;
            emit Transfer(msg.sender , recepient , amount);
            return true;   
        }
//////////////////////////// internal transfering function //////////////////////////////
        function _transfer(address from , address to , uint256 amount ) internal returns(bool){
            require(to != address(0), "recepient address is null");
            require(balance[from] >= amount ," insuffieceint tokens in your account");
            balance[from] = balance[from] - amount;
            balance[to] = balance[to] + amount;
            emit Transfer(from , to , amount);
            return true;   
        }
///////////////////////// giving authority to spen token to given address /////////////////////
        function approve(address spender , uint256 amount)public override returns(bool){
            require(spender !=  address(0), "spender is 0 address");
            require(balance[msg.sender] >= amount , "insuffieceint balance in owner account");
            allow[msg.sender][spender] = allow[msg.sender][spender] + amount;
            emit allowed(msg.sender , spender , amount);
            return true;
            
        }
/////////////////////// checking balance of spender allowed token ///////////////////////// 
        function allowance(address ownerOfToken ,address spender )public view override returns(uint256 amount){
            amount = allow[ownerOfToken][spender];
        }
/////////////////////////// transfering token function used by spenders //////////////////////
        function transferFrom(address ownerOfToken , address recepient , uint256 amount) public override returns(bool){
            require(recepient != address(0), "recepient address is null");
            require(ownerOfToken != address(0), "ownerOfToken address is null");
            require(balance[ownerOfToken] >= amount, "insuffieceint amount");
            
            balance[ownerOfToken] = balance[ownerOfToken] - amount;
            balance[recepient] = balance[recepient] + amount;
            allow[ownerOfToken][msg.sender] = allow[ownerOfToken][msg.sender] - amount;
            emit Transfer(ownerOfToken , recepient , amount);
            return true;
        }
        
////////////////////////// function to buy token from contract ///////////////////////////////  
            //if 1 token price is 2 ether 
            // a = 4ether / 2ether
            // a = 2 tokens
        function buyToken() public payable returns(bool , uint , uint ){
           require(msg.value >= 1 wei , "kindly pay more ether !");             // 1 wei = 1 wei / 2 ether = 5 (0.0000000000000000005 token)
            uint a = (msg.value*10**uint256(decimal))/price;                   // 1 token == 10^19   
                                          
             _transfer(address(this) ,msg.sender ,a);
             return (true, a , msg.value);
        }

        
////////////////////////////token minting/////////////////////

        function mint(address _add ,uint amount ) public onlyOwner returns(bool){
            require(_add != address(0) , "given address is 0");
     uint a =amount*10**uint(decimal);
    totalSupply = totalSupply + a;
    balance[_add] += a;
    
}

//////////////////// fallback function /////////////////
        receive() external payable {
             //if 1 token price is 2 ether 
            // a = 4ether / 2ether
            // a = 2 tokens
       uint a = (msg.value*10**uint256(decimal))/price;
            _transfer(address(this) , msg.sender , a );
            
        }
////////////////////// adjusting Price //////////////////////
        function adjustPrice(uint _neweth) public onlyOwner virtual returns(bool){
               price = _neweth * 1000000000000000000;
}
        
        
        
        }