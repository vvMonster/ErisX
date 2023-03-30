pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/token/ERC20/IERC20.sol";

contract StakingContract {
    IERC20 public token;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public stakeTime;
    
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }
    
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
        balances[msg.sender] += _amount;
        stakeTime[msg.sender] = block.timestamp;
    }
    
    function withdraw() external {
        require(balances[msg.sender] > 0, "No balance to withdraw");
        
        uint256 amount = balances[msg.sender];
        uint256 timeStaked = block.timestamp - stakeTime[msg.sender];
        uint256 reward = calculateReward(amount, timeStaked);
        
        balances[msg.sender] = 0;
        stakeTime[msg.sender] = 0;
        
        token.transfer(msg.sender, amount + reward);
    }
    
    function calculateReward(uint256 _amount, uint256 _timeStaked) internal view returns (uint256) {
        // Your reward calculation logic here
    }
}
