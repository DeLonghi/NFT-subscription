//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./utils/StructuredLinkedList.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SubscriptionNFT is ERC721("OnlyDefans", "OD") {
    using StructuredLinkedList for StructuredLinkedList.List;
    StructuredLinkedList.List list;

    struct Subscription {
        address author;
        uint256 expiresAt;
    }

    struct SubscriptionStatus {
        bool isActive;
        uint256 expiresAt;
    }

    event SubscriptionUpdate(address author, address user, uint256 expires);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // author => user => active NFT subscription id
    mapping(address => mapping(address => StructuredLinkedList.List)) activeUserSubscruptionNFTs;

    // author => user => subscriptionStatus
    mapping(address => mapping(address => SubscriptionStatus)) userSubscriptionStatus;

    // token id => Subscription information
    mapping(uint256 => Subscription) tokenSubscriptionInfo;

    function mint(address author, address to) public {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        Subscription memory newSubscription = Subscription(
            author,
            block.timestamp + 1 weeks
        );
        tokenSubscriptionInfo[newTokenId] = newSubscription;
        _mint(to, newTokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        Subscription memory transferedSubscription = tokenSubscriptionInfo[tokenId];
        updateListOnAdd(to, tokenId, transferedSubscription);
        updateListOnRemove(from, tokenId, transferedSubscription);
    }

    function getUserNFTS(address author, address user)
        public
        view
        returns (uint256)
    {
        return activeUserSubscruptionNFTs[author][user].sizeOf();
    }

    function getUserSubscription(address author, address user) public  view  returns (uint256 expires) {
            return userSubscriptionStatus[author][user].expiresAt;
    }

    function updateListOnAdd(address tokenOwner, uint256 tokenId, Subscription memory subscription) private {
        StructuredLinkedList.List storage currentList = activeUserSubscruptionNFTs[subscription.author][tokenOwner];
        if (!currentList.listExists()) {
            // currentList.pushBack(0);
            currentList.pushBack(tokenId);
            userSubscriptionStatus[subscription.author][tokenOwner] = SubscriptionStatus(true, subscription.expiresAt);
            emit SubscriptionUpdate(subscription.author, tokenOwner, subscription.expiresAt);
        }
        // uint256 nodeIterator = currentList.getNode(0);
        (bool hasNext, uint256 tokenIdIterator) = currentList.getNextNode(0);

         if (tokenSubscriptionInfo[tokenIdIterator].expiresAt <= subscription.expiresAt) {
                currentList.insertBefore(tokenIdIterator, tokenId);
                userSubscriptionStatus[subscription.author][tokenOwner] = SubscriptionStatus(true, subscription.expiresAt);
                emit SubscriptionUpdate(subscription.author, tokenOwner, subscription.expiresAt);
                return;
            }

        (hasNext, tokenIdIterator) = currentList.getNextNode(tokenIdIterator);

        while (hasNext) {
            if (tokenSubscriptionInfo[tokenIdIterator].expiresAt <= subscription.expiresAt) {
                currentList.insertBefore(tokenIdIterator, tokenId);
                return;
            }
             (hasNext, tokenIdIterator) = currentList.getNextNode(tokenIdIterator);
        }
        currentList.pushBack(tokenId);

    }

    function updateListOnRemove(address tokenOwner, uint256 tokenId, Subscription memory subscription) private {
        StructuredLinkedList.List storage currentList = activeUserSubscruptionNFTs[subscription.author][tokenOwner];
        currentList.remove(tokenId);
        (, uint256 headTokenId) = currentList.getNextNode(0);
        if(headTokenId != tokenId) {
            userSubscriptionStatus[subscription.author][tokenOwner].expiresAt = tokenSubscriptionInfo[headTokenId].expiresAt;
            emit SubscriptionUpdate(subscription.author, tokenOwner, subscription.expiresAt);
        }
    }
}
