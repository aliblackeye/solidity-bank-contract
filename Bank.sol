//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing Counters
import "Counters.sol";

contract Bank {
    // For using
    using Counters for Counters.Counter;
    Counters.Counter private idToUser;

    struct User {
        uint256 ID;
        uint256 balance;
        uint256 debt;
    }

    // Our Events
    event Withdraw(address creator, uint256 amount);
    event Deposit(address creator, uint256 amount);
    event Transfer(address sender, address to, uint256 amount);
    event Account(uint256 id, address creator, address createdAt);

    address payable owner;
    address[] private userAccounts; // Array for getting total users
    mapping(address => User) private users; // User's addresses

    // When the contract has deployed, we are creating our first user. (Deployer)
    constructor() {
        owner = payable(msg.sender);
        idToUser.increment(); // First id will be equal to 1
        users[msg.sender] = User(idToUser.current(), 0, 0); // User created on users mapping
        userAccounts.push(msg.sender); // First user added to userAccounts array
        idToUser.increment(); // counter increased by one because we just created a new user.
    }

    // Requirements
    modifier isOwner() {
        require(owner == msg.sender, "You are not owner!");
        _;
    }

    modifier insufficientBalance(uint256 _amount) {
        require(
            _amount > 0 && _amount <= users[msg.sender].balance,
            "Error: Insufficient balance!"
        );
        _;
    }

    // Creating a new user
    function createNewUser(address _address) external {
        require(
            users[_address].ID == 0,
            "Error: This user has already registered!"
        ); // If _address doesn't exist, you can create a new user

        users[_address] = User(idToUser.current(), 0, 0); // User created on users mapping
        userAccounts.push(_address); // User added to userAccounts array
        idToUser.increment(); // counter increased by one because we just created a new user.

        emit Account(idToUser.current(), msg.sender, _address); // Creating an event
    }

    // How many users we have
    function totalUsers() external view returns (uint256) {
        return userAccounts.length; // It returns total users
    }

    // Deposit money
    function deposit() external payable isOwner {
        users[msg.sender].balance += msg.value; // Amount adding to user's balance
        emit Deposit(msg.sender, msg.value); // Creating an event
    }

    // Withdraw money
    function withdraw(uint256 _amount)
        external
        isOwner
        insufficientBalance(_amount)
    {
        users[msg.sender].balance -= _amount; // decreasing owner's balance
        emit Withdraw(msg.sender, _amount); // Creating an event

        //Bool is called to confirm the amount
        (bool sent, ) = msg.sender.call{value: _amount}("Sent");
        require(sent, "Failed to send ETH");
    }

    // Send money
    function sendMoney(address _address, uint256 _amount)
        external
        isOwner
        insufficientBalance(_amount)
    {
        require(
            _address != msg.sender,
            "Error: You can't send money to yourself"
        );
        require(users[_address].ID != 0, "Error: User not found!");

        users[msg.sender].balance -= _amount; // decreasing sender's balance
        users[_address].balance += _amount; // increasing receiver's balance

        emit Transfer(msg.sender, _address, _amount); // Creating an event
    }

    // See your balance
    function getBalance() external view returns (uint256) {
        return users[msg.sender].balance; // Returns our balance
    }

    // Get an user's details
    function getUser(address _address)
        external
        view
        returns (User memory user)
    {
        return users[_address]; // Returns user
    }
}
