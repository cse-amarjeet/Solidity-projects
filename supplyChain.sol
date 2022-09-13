// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;

contract Ownable {
    address payable _owner;

    constructor() public {
        _owner=msg.sender;
    }
    modifier onlyOwner() {
        require(isOwner() ,"you are not Owner");
        _;
    }
    function isOwner() public view returns(bool) {
        return (msg.sender== _owner);
    }
}
contract Item {
    uint public index;
    uint public priceInWei;
    uint public pricePaid;
    ItemManager parentContract;

    constructor(ItemManager _parentContract, uint _index, uint _priceInWei) public {
        parentContract = _parentContract;
        index = _index;
        priceInWei = _priceInWei;
    }

    receive() external payable {
        require(pricePaid==0,"Already paid Full amount!!");
        require(priceInWei==msg.value,"only full payment allowed!!");
        pricePaid+=msg.value;
        (bool isSuccess,) = address(parentContract).call.value(msg.value)(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(isSuccess,"transection is not successfull!!");
    }
    

}

contract ItemManager is Ownable {

    enum SupplyChainState {Created, Paid, Delivered}

    struct S_Item {
        Item _item;
        string identifier;
        uint itemPrice;
        ItemManager.SupplyChainState _state;
    }

    mapping (uint=>S_Item) public Items; // mapping(address=>ItemManager) public Items;
    uint itemIndex;
    event SupplyChainStep(uint _itemIndex, uint _step,address _itemAddress);

    function createItem(string memory _identifier, uint _price) public onlyOwner {
        Item item = new Item(this , itemIndex, _price);
        Items[itemIndex]._item = item;
        Items[itemIndex].identifier=_identifier;
        Items[itemIndex].itemPrice = _price;
        Items[itemIndex]._state = SupplyChainState.Created;
        emit SupplyChainStep(itemIndex, uint(Items[itemIndex]._state),address(item));
        itemIndex++;
    }
    function triggerPayment(uint _itemIndex) public payable {
        require(Items[_itemIndex].itemPrice == msg.value , "only full payment is acceptable");
        require(Items[_itemIndex]._state == SupplyChainState.Created, "this item further in chain");
        Items[_itemIndex]._state = SupplyChainState.Paid;
        emit SupplyChainStep(itemIndex, uint(Items[_itemIndex]._state),address(Items[itemIndex]._item));
    }
    function triggerDelivery(uint _itemIndex) public onlyOwner {
        require(Items[_itemIndex]._state == SupplyChainState.Paid);
        Items[_itemIndex]._state = SupplyChainState.Delivered;
        emit SupplyChainStep(_itemIndex, uint(Items[itemIndex]._state),address(Items[itemIndex]._item));
    }
}