// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
///////////// impoting interface of erc20 //////////////////////
import "./ERC20.sol";

abstract contract capped is ERC20{
    
    uint256 private cap;
    
    constructor(uint _cap , string memory _nam , string memory _sym , uint256 _supp , uint8 _dec)  erc( _nam ,  _sym , _supp , _dec) public{
        cap = _cap;
    }
    
    function mint(uint amount , address _add) public override onlyOwner returns (bool){
        require(amount <= cap , "you have exceeded your limit");

        mint(amount , _add);
        return true;
    }
}