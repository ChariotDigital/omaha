const { ethers,deployments} = require('hardhat') 
const {moveBlocks} = require('../utils/moveBlocks')
const {moveTime} = require('../utils/moveTime')

const SECONDS_IN_A_DAY = 86400
const SECONDS_IN_A_YEAR = 10000000

describe("Staking Test", async function () {

    beforeEach( async function () {
        const account = await ethers.getSigners() //Get those who have signed this contract with the wallet address
        deployer = account[0] //get the first one
        await deployments.fixture('all') // let all of the contracts deploy? basically load them in so we can user them in this test
        stakingData = await deployments.get("Staking")
        rewardTokenData = await deployments.get("RewardToken")
        staking = await ethers.getContractAt("Staking", stakingData.address)
        rewardToken = await ethers.getContractAt("RewardToken", rewardTokenData.address)
        stakeAmount = ethers.utils.parseEther('100000') // get the amount of tokens in their true form
        
    })

    it("Allows users to stake tokens and claim rewards", async function () {
        await rewardToken.approve(staking.address, stakeAmount)
        await staking.stake(stakeAmount);
        const startingEarned = await staking.earned(deployer.address)
        console.log(`Starting Earned ${startingEarned}`)

        await moveTime(SECONDS_IN_A_YEAR)
        await moveBlocks(1)
        const endingEarned = await staking.earned(deployer.address)
        console.log(`Ending Earned ${endingEarned}`)
    })
})