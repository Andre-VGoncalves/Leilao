pragma solidity ^0.4.11;

contract SimpleAuction {
    address public beneficiary;
    uint public auctionEnd;

    address public highestBidder;
    uint highestBid;

    mapping (address => uint) pedingReturns;

    bool ended;

    event HighestBidIncreased (address bidder, uint amount);
    event AuctionEnded (address winner, uint amount);

    function SimpleAuction (
        uint _biddingTime,
        address _beneficiary
    ) {
        beneficiary = _beneficiary;
        auctionEnd = now + _biddingTime;
    }

    function bid () payable {
        require(now <= auctionEnd);

        require(msg.value > highestBid);
        if (highestBidder != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        HighestBidincreased(msg.sender, msg.value);
    }

    function withdraw () returns (bool) {
        uint amount = pedingReturns[msg.sender];
        if (amount > 0) {
            pedingReturns[msg.sender] = 0;
        
            if (!msg.sender.send(amount)) {
                pedingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() {

        require(now >= auctionEnd);
        require(!ended);

        ended = true;
        AuctionEnded(highestBidder, highestBid);
        
        beneficiary.transfer (highestBid);
    }
}