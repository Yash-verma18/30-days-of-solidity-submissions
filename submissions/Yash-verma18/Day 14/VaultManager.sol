// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDepositBox.sol";
import "./BasicDepositBox.sol";
import "./PremiumDepositBox.sol";
import "./TimeLockedDeposit.sol";

contract VaultManager {
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(
        address indexed owner,
        address indexed boxAddress,
        string boxType
    );
    event BoxNamed(address indexed boxAddress, string name);

    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox(msg.sender);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox(msg.sender);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(
        uint256 lockDuration
    ) external returns (address) {
        TimeLockedDeposit box = new TimeLockedDeposit(msg.sender, lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    function nameBox(address boxAddress, string memory name) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.storeSecret(secret);
    }

    function transferBoxOwnership(
        address boxAddress,
        address newOwner
    ) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.transferOwnership(newOwner);

        // remove previous owner
        address[] storage boxes = userDepositBoxes[msg.sender];

        for (uint i = 0; i < boxes.length; i++) {
            boxes[i] = boxes[boxes.length - 1];
            boxes.pop();
            break;
        }

        // new owner update
        userDepositBoxes[newOwner].push(boxAddress);
    }

    function getUserBoxes(
        address user
    ) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    function getBoxName(
        address boxAddress
    ) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    function getBoxInfo(
        address boxAddress
    )
        external
        view
        returns (
            string memory boxType,
            address owner,
            uint256 depositTime,
            string memory name
        )
    {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}
