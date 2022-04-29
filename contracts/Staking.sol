//Contract functions
//stake: lock tokens in the contact
//withdraw: unlock & take tokens out of the contract
//claimrewards: withfraw rewards from staked tokens

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__TransferFailed();
error Staking__NeedMoreThanZero();

contract Staking {
    //IERC20 allow us to have the normal ERCO20 functions, but implement them according to the token contract we build
    IERC20 public s_staking_token; // the token that we are allowing to be staked
    IERC20 public s_reward_token;  // the token that liquidity providers will earn for stakign their tokens
    uint256 public s_total_balances; // total amont of staking tokens in the contract
    uint256 public s_rewards_per_token_stored; // the rewards per token stored
    uint256 public s_last_update_time; // last time the contract as interacted with successfully
    uint256 public constant REWARD_RATE = 100; // the amount of reward token given per second
    event StakeEvent(address sender, uint256 amount); // event to be emitted when toekn are staked successfully
    // Used to keep track of who has staked and how muc htye have in the contract
    mapping (address => uint256) public s_balances; 
    // A mapping of how much each address has in reward tokens
    mapping (address => uint256) public s_rewards; 
    mapping (address => uint256) public s_user_reward_per_token_paid; // How much each staker should get in rewards per token the have stalked back 

    modifier updateReward(address account) {
        s_rewards_per_token_stored = rewardsPerToken();
        s_last_update_time = block.timestamp;
        s_rewards[account] = earned(account);
        s_user_reward_per_token_paid[account] = s_rewards_per_token_stored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if(amount == 0) { revert Staking__NeedMoreThanZero();}
        _;
    }

    constructor(address stakingToken, address reward_token) {
        s_staking_token = IERC20(stakingToken);
        s_reward_token = IERC20(reward_token);
    }

    function earned(address account) public view returns(uint256) {
        uint256 current_balance = s_balances[account];
        uint256 amount_paid = s_user_reward_per_token_paid[account];
        uint256 current_reward_per_token = rewardsPerToken();
        uint256 pastRewards = s_rewards[account];

        uint256 result = (current_balance * (current_reward_per_token - amount_paid)/ 1e18) + pastRewards;
        return result;
    }

    //External because only external addresses / contracts will call it

    function stake(uint256 amount) external moreThanZero(amount) updateReward(msg.sender) {
        //update the amount the user has staked
        //update total amount staked
        //transfer the tokens to this contract from the user

        s_balances[msg.sender] = s_balances[msg.sender] + amount;
        s_total_balances = s_total_balances + amount;
        // This transferFrom will revert in its current form.
        // This is because the transfer is being called by the contract, not the owner of the token.
        // This would be okay if approve() has been called, but it hasn't yet
        bool success = s_staking_token.transferFrom(msg.sender, address(this), amount);
        if(!success) {
            revert Staking__TransferFailed();
        } else {
            emit StakeEvent(msg.sender, amount);
        }

    }

    function withdraw(uint256 amount) external moreThanZero(amount) updateReward(msg.sender) {
        if(s_balances[msg.sender] >= amount) {
            s_balances[msg.sender] = s_balances[msg.sender] - amount;
            s_total_balances = s_total_balances - amount;

            bool success = s_staking_token.transfer(msg.sender, amount);
            if(!success) {
                revert Staking__TransferFailed();
            }
            
        } else {
            revert Staking__TransferFailed();
        }
        
    }

    function rewardsPerToken() public view returns(uint256) {
        if(s_total_balances == 0) {
            return s_rewards_per_token_stored;
        }
        return s_rewards_per_token_stored + ((block.timestamp - s_last_update_time) * REWARD_RATE * 1e18) / s_total_balances; 
    }

    function claimReward() external updateReward(msg.sender) {
        uint256 rewards = s_rewards[msg.sender];
        bool success = s_reward_token.transfer(msg.sender, rewards);
        if(!success) {
            revert Staking__TransferFailed();
        }

        //How to users get rewarded
        // emit X tokens per second
        // And disperse them to all stakers

        //100 tokens per second
        //the allocation of tokens is split evenly among all of the addressees currently staking in the contract
        // each address will have an amount of reward token that they earned calced from their share of the pool * the seconds that share rate was active
    }
    
}