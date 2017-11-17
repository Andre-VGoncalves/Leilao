pragma solidity ^0.4.11;

contract SimpleAuction {
    address public beneficiary;
    uint public auctionEnd;

    //Estado atual do leilão
    address public highestBidder;
    uint highestBid;

    mapping (address => uint) pendingReturns;

    //no final é colocado como true não permite alteções
    bool ended;

    //serão ativados na mudança
    event HighestBidIncreased (address bidder, uint amount);
    event AuctionEnded (address winner, uint amount);

    //endereço do beneficiario
    function SimpleAuction (
        uint _biddingTime,
        address _beneficiary
    ) {
        beneficiary = _beneficiary;
        auctionEnd = now + _biddingTime;
    }

    // o
    function bid () payable {
        require(now <= auctionEnd);

        require(msg.value > highestBid);
        if (highestBidder != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw () returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
        
            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
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