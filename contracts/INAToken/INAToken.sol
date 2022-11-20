// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract INANIToken is ERC20, Ownable {
    using SafeERC20 for IERC20;

    address private INAContract;

    // Internal Wallets
    address private incentives;
    address private marketing;
    address private team;
    address private advisors;
    address private treasury;
    address private rewards;
    address private development;
    
    // Presale quantities
    uint256 private presaleTotalTokens = 90000000 * 10 ** decimals();
    uint256 private publicsaleTotalTokens = 150000000 * 10 ** decimals();

    // Presale status
    bool private presaleStatus;

    // USDT & ETH contract addresses
    // Remember to allow this contract as spender for these token´s user
    address constant USDT_CONTRACT = 0xe4Cc6BDBc94680514a4dd08e2b5674CD3b9233A5;
    address constant ETH_CONTRACT = 0x69D44a9Cb0FbbeB5ab0629D1D738521a5af2b3d7;

    // Oracle addresses
    AggregatorV3Interface constant ETH_USD_ORACLE = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A);
    AggregatorV3Interface constant MATIC_USD_ORACLE = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);

    // Presale Price
    uint256 private presalePrice = 166666666666666666;  // 1 INA == 0.166666666666666

    // Deploy time
    uint256 private deploytime;
    uint256 constant SIX_MONTHS = 15780000;
    uint256 constant ONE_YEAR = 31560000;

    // Caps in USD
    uint256 private minCap = 500 * 10 ** (decimals());  // 200$
    uint256 private maxCap = 10000 * 10 ** decimals();  // 10000$

    // Sales mappings Addresses to Amount
    mapping(address => uint256) private privateSaleAddressToAmount;
    mapping(address => bool) private blacklistedAddress;

    constructor(
    address _incentives,
    address _marketing,
    address _team,
    address _advisors,
    address _treasury,
    address _rewards,
    address _development
    ) ERC20("INANI Token", "INA") {

        INAContract = address(this);

        incentives = _incentives;
        marketing = _marketing;
        team = _team;
        advisors = _advisors;
        treasury = _treasury;
        rewards = _rewards;
        development = _development;

        deploytime = block.timestamp;

        presaleStatus = true;

        _mint(address(this), (presaleTotalTokens + publicsaleTotalTokens)); // 90KK for PreSale & 15KK for PublicSale
        _mint(incentives, 100000000 * 10 ** decimals()); // 100KK for Inncentives
        _mint(marketing, 170000000 * 10 ** decimals()); // 170KK for Marketing
        _mint(team, 100000000 * 10 ** decimals()); // 100KK for Team
        _mint(advisors, 20000000 * 10 ** decimals()); // 20KK for Advisors
        _mint(treasury, 160000000 * 10 ** decimals()); // 160KK for Treasury
        _mint(rewards, 100000000 * 10 ** decimals()); // 100KK for Rewards
        _mint(development, 110000000 * 10 ** decimals()); // 110KK for Rewards
    }

    /////////////////////////
    /// Presale functions ///
    /////////////////////////

    function buyPresaleMATIC() public payable {
        // Value sent in USD
        uint256 sentUSDValue = getConversionRate(msg.value, MATIC_USD_ORACLE) / (10 ** decimals());
        // Amount of tokens to send
        uint256 amount = ((sentUSDValue * 10 ** decimals()) / presalePrice);
        // Presale conditions
        presaleConditionsOK(sentUSDValue, amount);
        // Send tokens to the buyer
        _transfer(INAContract, msg.sender, amount);
        // Update the total amount bought for the msg.sender
        privateSaleAddressToAmount[msg.sender] += sentUSDValue;
    }

    function buyPresaleUSDT(uint256 _amountUSDT) public {
        // USDT deposit
        // Remember to set this contract as spender in the USDT contract, it is usually done
        // from the forntend.
        IERC20(USDT_CONTRACT).safeTransferFrom(msg.sender, address(this), _amountUSDT);
        // Amount of tokens to send
        uint256 amount = ((_amountUSDT * 10 ** decimals()) / presalePrice);
        // Presale conditions
        presaleConditionsOK(_amountUSDT, amount);
        // Send tokens to the buyer
        _transfer(INAContract, msg.sender, amount);
        // Update the total amount bought for the msg.sender
        privateSaleAddressToAmount[msg.sender] += _amountUSDT;
    }

    function buyPresaleETH(uint256 _amountETH) public {
        // ETH deposit
        // Remember to set this contract as spender in the ETH contract, it is usually done
        // from the forntend.
        IERC20(ETH_CONTRACT).safeTransferFrom(msg.sender, address(this), _amountETH);
        // Value sent in USD
        uint256 sentUSDValue = getConversionRate(_amountETH, ETH_USD_ORACLE) / (10 ** decimals());
        // Amount of tokens to send
        uint256 amount = ((sentUSDValue * 10 ** decimals()) / presalePrice);
        // Presale conditions
        presaleConditionsOK(sentUSDValue, amount);
        // Send tokens to the buyer
        _transfer(INAContract, msg.sender, amount);
        // Update the total amount bought for the msg.sender
        privateSaleAddressToAmount[msg.sender] += sentUSDValue;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        // Vesting for Team
        if ((msg.sender == team) && ((block.timestamp - deploytime) < ONE_YEAR)) {
            revert("Team tokens are still vested");
        }
        // Blacklist transfer filter
        if (!blacklistedAddress[msg.sender]) {
            _transfer(msg.sender, to, amount);
            return true;
        }
        else {
            revert("This address cannot transfer tokens");
        }
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        // Vesting for Team
        if ((from == team) && ((block.timestamp - deploytime) < ONE_YEAR)) {
            revert("Team tokens are still vested");
        }
        // Blacklist transfer filter
        if (!blacklistedAddress[from]) {
            address spender = _msgSender();
            _spendAllowance(from, spender, amount);
            _transfer(from, to, amount);
            return true;
        }
        else {
            revert("This address cannot transfer tokens");
        }
        
    }

    function switchPresaleStatus() public onlyOwner returns(bool) {
        presaleStatus = !presaleStatus;
        return presaleStatus;
    }

    function presaleConditionsOK(uint256 _sentUSDValue, uint256 _amount) internal view returns(bool) {
        // Check presale requirements
        // We can also use coditional sentences with error codes here
        require(_sentUSDValue >= minCap, "USD value sent is less than minimum");
        require(maxCap - privateSaleAddressToAmount[msg.sender] >= _sentUSDValue, "USD value sent is more than maximum");
        require(((tokensBalanceSC() > publicsaleTotalTokens) && ((block.timestamp - deploytime) < SIX_MONTHS) && (presaleStatus)), "The presale has finished.");
        require((tokensBalanceSC() - publicsaleTotalTokens) >= _amount, "Not enought tokens to buy.");
        return true;
    }

    //////////////////////////
    /// Blacklist function ///
    //////////////////////////

    function blacklist(address _address, bool _newStatus) public onlyOwner {
        blacklistedAddress[_address] = _newStatus;
    }

    //////////////////////////
    /// Withdraw functions ///
    //////////////////////////

    function withdrawMATIC() public payable onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function withdrawUSDT() public onlyOwner {
        uint balance = IERC20(USDT_CONTRACT).balanceOf(address(this));
        IERC20(USDT_CONTRACT).safeTransfer(owner(), balance);
    }

    function withdrawETH() public onlyOwner {
        uint balance = IERC20(ETH_CONTRACT).balanceOf(address(this));
        IERC20(ETH_CONTRACT).safeTransfer(owner(), balance);
    }

    ////////////////////////
    /// Getter functions ///
    ////////////////////////

    function getINAContract() public view returns(address) {
        return INAContract;
    }

    function getPresaleStatus() public view returns(bool) {
        return presaleStatus;
    }

    function getBlacklist(address _address) public view returns(bool) {
        return blacklistedAddress[_address];
    }

    function tokensBalanceSC() public view returns(uint256) {
        return balanceOf(INAContract);
    }

    function getMATICBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getUSDTBalance() public view returns(uint256) {
        return IERC20(USDT_CONTRACT).balanceOf(INAContract);
    }

    function getETHBalance() public view returns(uint256) {
        return IERC20(ETH_CONTRACT).balanceOf(INAContract);
    }

    function getPrivateSaleAddressToAmount(address _address) public view returns(uint256) {
        return privateSaleAddressToAmount[_address];
    }

    function getIncentives() public view returns(address) {
        return incentives;
    }

    function getMarketing() public view returns(address) {
        return marketing;
    }

    function getTeam() public view returns(address) {
        return team;
    }

    function getAdvisors() public view returns(address) {
        return advisors;
    }

    function getTreasury() public view returns(address) {
        return treasury;
    }

    function getDevelopment() public view returns(address) {
        return development;
    }

    function getminCap() public view returns(uint256) {
        return minCap;
    }

    function getmaxCap() public view returns(uint256) {
        return maxCap;
    }

    function getDeploytime() public view returns(uint256) {
        return deploytime;
    }

    ////////////////////////
    /// Oracle functions ///
    ////////////////////////

    function getPrice(AggregatorV3Interface _priceFeed) internal view returns(uint256) {

        AggregatorV3Interface priceFeed = AggregatorV3Interface(_priceFeed);
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        
        // Echange rate in 18 digit
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 Amount, AggregatorV3Interface _priceFeed)
        internal
        view
        returns (uint256)
    {
        uint256 Price = getPrice(_priceFeed);
        uint256 AmountInUsd = (Price * Amount);
        return AmountInUsd;
    }

    //////////////////////////
    /// Fallback functions ///
    //////////////////////////

    // We prevent from sending MATIC funds accidentally without calling the
    // right function, even in this case the funder will receive the tokens.

    fallback() external payable {
        buyPresaleMATIC();
    }

    receive() external payable {
        buyPresaleMATIC();
    }
}