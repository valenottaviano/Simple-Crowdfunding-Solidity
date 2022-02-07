// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe{
    mapping(address => uint256) public addressToAmount;
    address[] public funders;
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    // Accept some type of payment
    function fund() public payable {
        // Minimum fund value is 5 dollars
        uint256 minUDS = 5*10**18;
        require(getConversionRate(msg.value) >= minUDS, "You need to spend more ETH!");
        addressToAmount[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int price,,,) = priceFeed.latestRoundData();
        return uint256(price * 10000000000);
        // uint256: 3,008.95769532
    }
    
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner of the contract.");
        _;
    }

    function withdraw() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 i=0; i<funders.length; i++){
            address funder = funders[i];
            addressToAmount[funder] = 0;
        }
        funders = new address[](0);
    }
}
