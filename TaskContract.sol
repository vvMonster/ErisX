// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ReputationContract.sol";
import "./StakingContract.sol";

contract TaskContract {
    struct Task {
        uint256 id;
        address publisher;
        address receiver;
        string title;
        string description;
        uint256 reward;
        bool completed;
    }
    Task[] public tasks;
    ReputationContract reputationContract;
    StakingContract stakingContract;

    event TaskCreated(address indexed publisher, uint256 indexed taskId);
    event TaskCompleted(address indexed receiver, uint256 indexed taskId);

    constructor(ReputationContract _reputationContract, StakingContract _stakingContract) {
        reputationContract = _reputationContract;
        stakingContract = _stakingContract;
    }

    function createTask(string memory _title, string memory _description, uint256 _reward) external {
        require(_reward > 0, "Reward must be greater than zero");

        stakingContract.stake(_reward, msg.sender);
        uint256 taskId = tasks.length;
        tasks.push(Task(taskId, msg.sender, address(0), _title, _description, _reward, false));

        emit TaskCreated(msg.sender, taskId);
    }

    function completeTask(uint256 _taskId) external {
        require(_taskId < tasks.length, "Invalid task ID");
        Task storage task = tasks[_taskId];
        require(!task.completed, "Task is already completed");
        require(task.receiver == msg.sender, "Only task receiver can complete the task");

        task.completed = true;
        stakingContract.requestWithdrawal(task.publisher, msg.sender);

        emit TaskCompleted(msg.sender, _taskId);

        reputationContract.addReputation(task.receiver, task.reward); // 使用ReputationContract更新接收者的信誉值
    }

    function assignTask(uint256 _taskId, address _receiver) external {
        require(_taskId < tasks.length, "Invalid task ID");
        Task storage task = tasks[_taskId];
        require(!task.completed, "Task is already completed");
        require(task.receiver == address(0), "Task is already assigned");
        
        reputationContract.addUser(_receiver); 
        task.receiver = _receiver;
    }
    
    function acceptanceTask(uint256 _taskId, address addr) external {
        Task storage task = tasks[_taskId];
        require(msg.sender == task.publisher, "Invalid task addr");
        stakingContract.chooseRecipient(task.publisher ,addr);
    }

    function getTask(uint256 _taskId) external view returns (uint256, address, string memory, string memory, uint256, bool) {
        require(_taskId < tasks.length, "Invalid task ID");
        Task storage task = tasks[_taskId];
        return (task.id, task.receiver, task.title, task.description, task.reward, task.completed);
    }

    function getNumberOfTasks() external view returns (uint256) {
        return tasks.length;
    }
}