// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface StockFactory {
    function createStock(uint256 _userId) external returns(address);
}

contract CreatorCredit is Ownable {

    // Oracle address
    // I am using DAI token price as INA price to be able to use an Oracle in this assesment
    AggregatorV3Interface constant INA_USD_ORACLE = AggregatorV3Interface(0x0FCAa9c899EC5A91eBc3D5Dd869De833b06fB046);

    // Score
    // The score should be computed offchain due to cost optimization, and requested via Oracle on every transaction
    // that implies its use. For this assesment I will modify the mapping manually to change the scores but I will leave
    // the oracle calls commented.
    mapping(uint256 => uint256) private userIdToContentCreatorScore;
    mapping(uint256 => address) private userIdToUserAddress;

    address private stockFactoryContractAddress;
    StockFactory private stockFactory;

    constructor(address _stockFactoryContractAddress) {
        stockFactory = StockFactory(_stockFactoryContractAddress);
    }

    /////////////////////////
    ////  Main functions ////
    /////////////////////////

    // Factory the user contract, it will be done when the user reachs a score of 1000.
    // The trigger of this function and the userId comes from the frontend.
    function CreateUserToken(uint256 _userId) public {
        require(userIdToUserAddress[_userId] == address(0), "User Stock is already created");
        require(userIdToContentCreatorScore[_userId] >= 1000, "Score is less than minimum");
        // Factory Stock tokens
        address _newStockContractAddress = stockFactory.createStock(_userId);
        userIdToUserAddress[_userId] = _newStockContractAddress;
    }

    // This Method not functional for the assessment, it should be used with an Oracle to get the score of an user (see firsts comments)
    function requestScore(address _address) internal {
        // 1 - Call the Custom Oracle or Standard Chainlink API Oracle (it depends if the API needs or not authentication.)
        // 2 - Set the value to the score mapping
        // contentCreatorScore[_address] = OracleResponse;
    }

    /////////////////////////
    /// Utility functions ///
    /////////////////////////

    function getStockPrice(uint256 _userId) public view returns(uint256) {
        return getContentCreatorScore(_userId) * getINAPrice();
    }

    function setContentCreatorScore(uint256 _userId, uint256 _score) public onlyOwner {
        userIdToContentCreatorScore[_userId] = _score;
    }

    ////////////////////////
    /// Getter functions ///
    ////////////////////////

    function getContentCreatorScore(uint256 _userId) public view returns(uint256) {
        return userIdToContentCreatorScore[_userId];
    }

    function getUserIdToUserAddress(uint256 _userId) public view returns(address) {
        return userIdToUserAddress[_userId];
    }

    ////////////////////////
    /// Oracle functions ///
    ////////////////////////

    function getINAPrice() internal view returns(uint256) {

        AggregatorV3Interface priceFeed = AggregatorV3Interface(INA_USD_ORACLE);
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        
        // Echange rate in 18 digit
        return uint256(answer * 10000000000);
    }

    function getINAConversionRate(uint256 Amount) internal view returns (uint256) {
        uint256 Price = getINAPrice();
        uint256 AmountInUsd = (Price * Amount);
        return AmountInUsd;
    }
}