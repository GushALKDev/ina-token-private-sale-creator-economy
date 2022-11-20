// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract StockFactory {

    modifier onlyCreatorCredit() {
        require(msg.sender == creatorCreditContractAddress,"You are not allowed to Factory contracts.");
        _;
    }

    address private creatorCreditContractAddress;
    address private INAContractAddress;

    constructor(address _INAContractAddress) {
        INAContractAddress = _INAContractAddress;
    }

    function createStock(uint256 _userId) external onlyCreatorCredit returns(address) {
        string memory userId = Strings.toString(_userId);
        string memory name = string.concat("StockContract", userId);
        string memory ticker = string.concat("STK", userId);

        address newStockContractAddress = address(new Stock(name, ticker, INAContractAddress, creatorCreditContractAddress, _userId));

        return newStockContractAddress;
    }

    //////////////////////////
    ////  Set functions  /////
    //////////////////////////

    function setCreatorCreditContractAddress(address _newAddress) public {
        creatorCreditContractAddress = _newAddress;
    }

    function setINAContractAddress(address _newAddress) public {
        INAContractAddress = _newAddress;
    }

    ///////////////////////////
    ////  Getter functions ////
    ///////////////////////////

    function getCreatorCreditContractAddress() public view returns(address) {
        return creatorCreditContractAddress;
    }

    function getINAContractAddress() public view returns(address) {
        return INAContractAddress;
    }
}

interface CreatorCredit {
    function getStockPrice(uint256 _userId) external view returns(uint256);
}

contract Stock is ERC20, Ownable {

    using SafeERC20 for IERC20;

    // The own contract is a liquidity pool of INA <--> UserStock
    // NOTES:   - Provide it INA liquidity to allow it works.
    //          - Approve allowance for INA and this token to this contract as spender,
    //            it is usually done from the fronted before swap the tokens.
    
    address private INAContractAddress;
    address private creatorCreditContractAddress;
    uint256 immutable userId;
    CreatorCredit private creatorCredit;

    // Max integer
    uint256 constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    constructor(string memory _name, string memory _ticker, address _INAContractAddress, address _creatorCreditContractAddress, uint _userId) ERC20(_name, _ticker) {
        _mint(address(this), 10000 * 10 ** decimals());
        INAContractAddress = _INAContractAddress;
        creatorCreditContractAddress = _creatorCreditContractAddress;
        creatorCredit = CreatorCredit(creatorCreditContractAddress);
        userId = _userId;
    }

    /////////////////////////
    ////  Main functions ////
    /////////////////////////

    // Remember to add INA liquidity to the contract before swap

    function buyTokens(uint256 _amountTokens) public {
        require(_amountTokens > 0, "You cannot buy 0 tokens");
        // Remember to set this contract as spender in the INA contract, it is usually done
        // from the frontend.
        // Calculate how many INAs this amount of tokens worth.
        uint256 tokenPrice = creatorCredit.getStockPrice(userId);
        uint256 amountINA = (_amountTokens * tokenPrice) / 10 ** decimals();
        // Deposit INAs to get Tokens
        IERC20(INAContractAddress).safeTransferFrom(msg.sender, address(this), amountINA);
        // Checking liquidity
        require(balanceOf(address(this)) > _amountTokens, "Not enough liquidity to swap");
        // Send tokens to the buyer
        _transfer(address(this), msg.sender, _amountTokens);
    }

    function sellTokens(uint256 _amountTokens) public {
        require(_amountTokens > 0, "You cannot sell 0 tokens");
        // Remember to set this contract as spender in this contract, it is usually done
        // from the forntend.
        // Deposit Tokens to get back INAs
        _transfer(msg.sender, address(this), _amountTokens);
        // Calculate how many INAs this amount if tokens worth.
        uint256 tokenPrice = creatorCredit.getStockPrice(userId);
        uint256 amountINA = (_amountTokens * tokenPrice) / 10 ** decimals();
        // Checking liquidity
        require(IERC20(INAContractAddress).balanceOf(address(this)) > amountINA, "Not enough liquidity to swap");
        // Send INAs to the buyer
        IERC20(INAContractAddress).approve(address(this), MAX_INT);
        IERC20(INAContractAddress).safeTransferFrom(address(this), msg.sender, amountINA);
    }

    function addINALiquidity(uint256 _amountINA) public {
        // Remember to set this contract as spender in the INA contract, it is usually done
        // from the frontend.
        IERC20(INAContractAddress).safeTransferFrom(msg.sender, address(this), _amountINA);
    }

    //////////////////////////
    ////  Set functions  /////
    //////////////////////////

    function setINAContractAddress(address _newAddress) public {
        INAContractAddress = _newAddress;
    }
    function setCreatorCreditContractAddress(address _newAddress) public {
        creatorCreditContractAddress = _newAddress;
    }

    ///////////////////////////
    ////  Getter functions ////
    ///////////////////////////

    function getINAContractAddress() public view returns(address) {
        return INAContractAddress;
    }

    function getCreatorCreditContractAddress() public view returns(address) {
        return creatorCreditContractAddress;
    }

    function getINABalanceOf(address _address) public view returns(uint256) {
        return IERC20(INAContractAddress).balanceOf(_address);
    }

    function getUserId() public view returns(uint256) {
        return userId;
    }
}
