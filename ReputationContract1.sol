// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReputationContract {

    struct User {
        uint256 reputation;
        bool exists;
    }

    mapping (address => User) public users;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner, "Only admin can execute this function");
        _;
    }

    function addReputation(address _user, uint256 _reputation) external {
        require(users[_user].exists, "User does not exist");
        users[_user].reputation += _reputation;
    }

    function removeReputation(address _user, uint256 _reputation) external {
        require(users[_user].exists, "User does not exist");
        require(users[_user].reputation >= _reputation, "User has insufficient reputation");
        users[_user].reputation -= _reputation;
    }

    function getReputation(address _user) external view returns (uint256) {
        require(users[_user].exists, "User does not exist");
        return users[_user].reputation;
    }

    function addUser(address _user) external {
        require(!users[_user].exists, "User already exists");
        users[_user] = User(0, true);
    }
}
