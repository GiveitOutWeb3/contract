pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

//0xDA0bab807633f07f013f94DD0E6A4F96F8742B53

//createGiveaway, giveawayMap, participate, getParticipants, owner are working fine.
//getAllGiveaways(asking for payable), balance and getBalance(both giving diff. values),

import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract GiveitOutWeb3 is VRFConsumerBase, KeeperCompatibleInterface {
    address public owner;
    using Counters for Counters.Counter;
    Counters.Counter private giveawayNumber;

    bytes32 internal keyHash;
    uint256 internal fee;
    address vrfCoordinator;
    address link;
    address keeperRegistryAddress;
    uint256 public currGiveawayId = 0;
    bool public isLocked = false;

    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        address _keeperRegistryAddress
    ) payable VRFConsumerBase(_vrfCoordinator, _link) {
        keyHash = _keyHash;
        keeperRegistryAddress = _keeperRegistryAddress;

        fee = 0.1 ether;
        owner = msg.sender;
    }

    event GiveawayCreated(
        address creator,
        uint256 uniqueId,
        string message,
        string socialLink,
        uint256 deadline,
        uint256 timestamp,
        uint256 amount,
        uint256 participationFee,
        address[] participants,
        bool isLive,
        address winner,
        bool isProcessing
    );

    event GiveawayParticipated(
        address creator,
        uint256 uniqueId,
        bool isLive,
        uint256 amount,
        uint256 participationFee,
        address[] participants
    );

    event GiveawayEnded(
        address creator,
        uint256 uniqueId,
        bool isLive,
        uint256 amount,
        uint256 participationFee,
        address winner
    );

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getLinkBalance() public view returns (uint256) {
        return LINK.balanceOf(address(this));
    }

    struct Giveaway {
        address creator;
        uint256 uniqueId;
        string message;
        string socialLink;
        uint256 deadline;
        uint256 timestamp;
        uint256 amount;
        uint256 participationFee;
        address[] participants;
        bool isLive;
        address winner;
        bool isProcessing;
    }

    mapping(uint256 => Giveaway) public giveawayMap;

    function createGiveaway(
        string memory _message,
        string memory _socialLink,
        uint256 _deadline
    ) public payable {
        require(block.timestamp < _deadline, "Enter valid time");
        require(msg.value > 0, "No value given");
        uint256 _participationFee = msg.value / 100;
        address[] memory empty;
        giveawayNumber.increment();
        uint256 newGiveawayNumber = giveawayNumber.current();

        giveawayMap[newGiveawayNumber] = Giveaway(
            msg.sender,
            newGiveawayNumber,
            _message,
            _socialLink,
            _deadline,
            block.timestamp,
            msg.value,
            _participationFee,
            empty,
            true,
            address(0),
            false
        );
        emit GiveawayCreated(
            msg.sender,
            newGiveawayNumber,
            _message,
            _socialLink,
            _deadline,
            block.timestamp,
            msg.value,
            _participationFee,
            empty,
            true,
            address(0),
            false
        );
    }

    function participate(uint256 giveawayId)
        public
        payable
        giveawayExist(giveawayId)
    {
        Giveaway storage currGiveaway = giveawayMap[giveawayId];
        require(currGiveaway.isLive == true, "Giveaway has been finished");
        require(
            currGiveaway.deadline >= block.timestamp,
            "Giveaway time is over"
        );
        for (uint256 i = 0; i < currGiveaway.participants.length; i++) {
            require(
                currGiveaway.participants[i] != msg.sender,
                "You cannot participate twice"
            );
        }
        require(currGiveaway.participationFee <= msg.value, "Insufficient fee");
        currGiveaway.participants.push(payable(msg.sender));
        emit GiveawayParticipated(
            currGiveaway.creator,
            currGiveaway.uniqueId,
            currGiveaway.isLive,
            currGiveaway.amount,
            currGiveaway.participationFee,
            currGiveaway.participants
        );
    }

    function getParticipants(uint256 giveawayId)
        public
        view
        giveawayExist(giveawayId)
        returns (address[] memory)
    {
        return giveawayMap[giveawayId].participants;
    }

    function endGiveaway(uint256 giveawayId) public giveawayExist(giveawayId) {
        require(isLocked == false, "Please try again later");
        Giveaway storage currGiveaway = giveawayMap[giveawayId];
        require(
            currGiveaway.creator == msg.sender ||
                msg.sender == owner ||
                msg.sender == keeperRegistryAddress,
            "Not Authorized"
        );
        require(
            currGiveaway.deadline <= block.timestamp,
            "Deadline not reached"
        );
        require(currGiveaway.isLive == true, "Giveaway already ended");
        giveawayMap[giveawayId].isProcessing = true;

        currGiveawayId = giveawayId;
        isLocked = true;
        getRandomNumber();
        emit GiveawayEnded(
            currGiveaway.creator,
            currGiveaway.uniqueId,
            currGiveaway.isLive,
            currGiveaway.amount,
            currGiveaway.participationFee,
            currGiveaway.winner
        );
    }

    modifier giveawayExist(uint256 giveawayId) {
        require(
            giveawayMap[giveawayId].uniqueId != 0,
            "Giveaway doesn't exist"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getRandomNumber() internal returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(
        bytes32, /** requestId */
        uint256 randomness
    ) internal override {
        Giveaway storage currGiveaway = giveawayMap[currGiveawayId];
        if (currGiveaway.participants.length == 0) {
            payable(currGiveaway.creator).transfer(currGiveaway.amount);
        } else {
            uint256 index = randomness % currGiveaway.participants.length;
            payable(currGiveaway.participants[index]).transfer(
                currGiveaway.amount
            );
            giveawayMap[currGiveawayId].winner = currGiveaway.participants[
                index
            ];
        }

        giveawayMap[currGiveawayId].isProcessing = false;
        giveawayMap[currGiveawayId].isLive = false;
        isLocked = false;
        currGiveawayId = 0;
    }

    function getAllGiveaways() public view returns (Giveaway[] memory) {
        uint256 totalGiveaways = giveawayNumber.current();
        uint256 currIndex = 0;
        Giveaway[] memory allGiveaways = new Giveaway[](totalGiveaways);
        for (uint256 i = 0; i < totalGiveaways; i++) {
            uint256 currId = giveawayMap[i + 1].uniqueId;
            Giveaway storage currGiveaway = giveawayMap[currId];
            allGiveaways[currIndex] = currGiveaway;
            currIndex += 1;
        }
        return allGiveaways;
    }

    function getParticipatedGiveaways()
        public
        view
        returns (Giveaway[] memory)
    {
        uint256 totalGiveaways = giveawayNumber.current();
        uint256 currIndex = 0;
        uint256 participatedGiveawaysLength = 0;
        for (uint256 i = 0; i < totalGiveaways; i++) {
            uint256 currId = giveawayMap[i + 1].uniqueId;
            Giveaway storage currGiveaway = giveawayMap[currId];
            for (uint256 j = 0; j < currGiveaway.participants.length; j++) {
                if (currGiveaway.participants[j] == msg.sender) {
                    participatedGiveawaysLength++;
                }
            }
        }
        Giveaway[] memory participatedGiveaways = new Giveaway[](
            participatedGiveawaysLength
        );
        for (uint256 i = 0; i < totalGiveaways; i++) {
            uint256 currId = giveawayMap[i + 1].uniqueId;
            Giveaway storage currGiveaway = giveawayMap[currId];
            for (uint256 j = 0; j < currGiveaway.participants.length; j++) {
                if (currGiveaway.participants[j] == msg.sender) {
                    participatedGiveaways[currIndex] = currGiveaway;
                    currIndex += 1;
                }
            }
        }
        return participatedGiveaways;
    }

    function getWonGiveaways() public view returns (Giveaway[] memory) {
        uint256 totalGiveaways = giveawayNumber.current();
        uint256 currIndex = 0;
        uint256 wonGiveawaysLength = 0;
        for (uint256 i = 0; i < totalGiveaways; i++) {
            uint256 currId = giveawayMap[i + 1].uniqueId;
            Giveaway storage currGiveaway = giveawayMap[currId];
            if (
                currGiveaway.winner == msg.sender &&
                currGiveaway.isLive == false
            ) {
                wonGiveawaysLength++;
            }
        }
        Giveaway[] memory wonGiveaways = new Giveaway[](wonGiveawaysLength);
        for (uint256 i = 0; i < totalGiveaways; i++) {
            uint256 currId = giveawayMap[i + 1].uniqueId;
            Giveaway storage currGiveaway = giveawayMap[currId];
            if (
                currGiveaway.winner == msg.sender &&
                currGiveaway.isLive == false
            ) {
                wonGiveaways[currIndex] = currGiveaway;
                currIndex += 1;
            }
        }

        return wonGiveaways;
    }

    function getYourGiveaways() public view returns (Giveaway[] memory) {
        uint256 totalGiveaways = giveawayNumber.current();
        uint256 currIndex = 0;
        uint256 yourGiveawaysLength = 0;
        for (uint256 i = 0; i < totalGiveaways; i++) {
            uint256 currId = giveawayMap[i + 1].uniqueId;
            Giveaway storage currGiveaway = giveawayMap[currId];
            if (currGiveaway.creator == msg.sender) {
                yourGiveawaysLength++;
            }
        }
        Giveaway[] memory yourGiveaways = new Giveaway[](yourGiveawaysLength);
        for (uint256 i = 0; i < totalGiveaways; i++) {
            uint256 currId = giveawayMap[i + 1].uniqueId;
            Giveaway storage currGiveaway = giveawayMap[currId];
            if (currGiveaway.creator == msg.sender) {
                yourGiveaways[currIndex] = currGiveaway;
                currIndex += 1;
            }
        }

        return yourGiveaways;
    }

    function getTimestamp() public view returns (uint256 time) {
        time = block.timestamp;
    }

    function rechargeEth() public payable {}

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        uint256 giveawaysToEndCount;
        for (uint256 i = 1; i <= giveawayNumber.current(); i++) {
            bool canExec = block.timestamp >= giveawayMap[i].deadline &&
                giveawayMap[i].isLive;
            if (canExec) {
                giveawaysToEndCount++;
            }
        }

        if (giveawaysToEndCount > 0) {
            upkeepNeeded = true;

            uint256[] memory giveawayIds = new uint256[](giveawaysToEndCount);
            uint256 tempCounter;
            for (uint256 i = 1; i <= giveawayNumber.current(); i++) {
                bool canExec = block.timestamp >= giveawayMap[i].deadline &&
                    giveawayMap[i].isLive;
                if (canExec) {
                    giveawayIds[tempCounter] = i;
                    tempCounter++;
                }
            }

            performData = abi.encode(giveawayIds);
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        uint256[] memory giveawayIds;
        (giveawayIds) = abi.decode(performData, (uint256[]));

        for (uint256 i = 0; i < giveawayIds.length; i++) {
            endGiveaway(giveawayIds[i]);
        }
    }

    function changeOwner(address newAddress)
        public
        onlyOwner
        returns (address)
    {
        owner = newAddress;
        return owner;
    }

    function unlockContract() public onlyOwner {
        isLocked = false;
        currGiveawayId = 0;
    }

    function getFees(uint256 percentage) public onlyOwner {
        uint256 totalGiveaways = giveawayNumber.current();
        uint256 totalLiveAmount = 0;
        for (uint256 i = 0; i < totalGiveaways; i++) {
            uint256 currId = giveawayMap[i + 1].uniqueId;
            Giveaway storage currGiveaway = giveawayMap[currId];
            if (currGiveaway.isLive == true) {
                totalLiveAmount += currGiveaway.amount;
            }
        }
        uint256 remainingFees = (address(this).balance - totalLiveAmount) /
            percentage;
        payable(owner).transfer(remainingFees);
    }
}
