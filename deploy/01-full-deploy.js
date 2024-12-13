const { loadFixture } = require("ethereum-waffle")
const { network, ethers } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const signers = await ethers.getSigners();

    const timeoutPeriod = 3200;
    //const chainId = network.config.chainId

    ////////////////////////////
    ////  INA TOKEN Deploy  ////
    ////////////////////////////

    //  Fake Contracts
    const usdt = await deploy("USDTFakeToken", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    console.log("USDTFakeToken Deployed",usdt.address);

    const eth = await deploy("ETHFakeToken", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    console.log("ETHFakeToken Deployed",eth.address);

    // INA Contract
    const ina = await deploy("INANIToken", {
        from: deployer,
        args: [usdt.address, eth.address, signers[1].address, signers[2].address, signers[3].address, signers[4].address, signers[5].address, signers[6].address, signers[7].address],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    console.log("INANIToken Deployed",ina.address);

    // SETUP

    // USDT Attach
    const USDTFactory = await ethers.getContractFactory("USDTFakeToken");
    const USDTContract = await USDTFactory.attach(usdt.address);
    console.log("[USDT attached]: " + usdt.address);
    await new Promise((r) => setTimeout(() => r(), timeoutPeriod));
    // Allowance USDT
    await USDTContract.approve(ina.address, ethers.constants.MaxInt256);

    // ETH Attach
    const ETHFactory = await ethers.getContractFactory("ETHFakeToken");
    const ETHContract = await ETHFactory.attach(eth.address);
    console.log("[ETH attached]: " + eth.address);
    await new Promise((r) => setTimeout(() => r(), timeoutPeriod));
    // Allowance ETH
    await ETHContract.approve(ina.address, ethers.constants.MaxInt256);

    /////////////////////////////////
    ////  Creator Credit Deploy  ////
    /////////////////////////////////

    // Stock Factory
    const stockFactory = await deploy("contracts/CreatorCredit/Stock.sol:StockFactory", {
        from: deployer,
        args: [ina.address],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    await stockFactory.deployed();
    console.log("Stock Factory Deployed",stockFactory.address);

    // Creator Credit
    const creatorCredit = await deploy("contracts/CreatorCredit/CreatorCredit.sol:CreatorCredit", {
        from: deployer,
        args: [stockFactory.address],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    await creatorCredit.deployed();
    console.log("Creator Credit Deployed",creatorCredit.address);

    // Stock Factory Attach
    const stockFactoryFactory = await ethers.getContractFactory("USDTFakeToken");
    const stockFactoryContract = await stockFactoryFactory.attach(stockFactory.address);
    console.log("[Stock Factory attached]: " + stockFactory.address);
    await new Promise((r) => setTimeout(() => r(), timeoutPeriod));
    
    // Set CreatorCredit Contract Address 
    await stockFactoryContract.setCreatorCreditContractAddress(creatorCredit.address);

    log("Verifying")
    await verify(usdt.address, arguments)
    log("---------------------------------------")
}

module.exports.tags = ["all"]
