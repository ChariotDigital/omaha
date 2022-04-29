require("@nomiclabs/hardhat-waffle")
require("hardhat-deploy")
require("@nomiclabs/hardhat-ethers")

module.exports ={
    solidity: "0.8.7",
    namedAccounts: {
        deployer :{
            default: 0 // ethers built in account @ index 0
        }
    }
}