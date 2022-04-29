const { network, ethers } = require("hardhat")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const rewardToken = await deployments.get("RewardToken")
    const args = [rewardToken.address, rewardToken.address]


    const stakingDeployment = await deploy("Staking", {
        from: deployer,
        args: args,
        log: true
    })

}

module.exports.tags = ["all", "staking"]