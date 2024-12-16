// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract RedPacket {
    //定义一个发红包的主体
    address payable public owner;
    //红包金额
    uint256 public totalAmount;
    //红包的数量
    uint256 public count;
    //是否是等额红包
    bool isEqual;
    // 定义 DepositMade 事件
    //做作业用的 ？？ 监听这个事件的时候 取出来这个索引
    event DepositMade(
        address indexed depositor,
        uint256 amount,
        uint256 count,
        bool isEqual
    );
event RedPacketGrabbed(
    address indexed grabber,
    uint256 amount
);
    //谁已经抢到过这个红包
    mapping(address => bool) isGrabbed;

    constructor() {
        //只有部署合约的人能购发红包
        owner = payable(msg.sender);
    }

    function deposit(uint256 c, bool _isEqual) public payable {
        require(msg.value > 0, "amount must>0");
        count = c;
        isEqual = _isEqual;
        totalAmount = msg.value;
        //前端调用成功了存钱事件 前端进行提示
        emit DepositMade(msg.sender, msg.value, c, _isEqual);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function grabRedEnvelope() public payable {
        require(count > 0, "count must >0");
        require(totalAmount > 0, "totalAmount must >0");
        require(!isGrabbed[msg.sender], "you have grabbed");
        uint256 grabbedAmount; 
        //抢红包
        isGrabbed[msg.sender] = true;
        if (count == 1) {
            //合约调用的人
            // 如果是最后一个红包：直接发送所有剩余金额
            grabbedAmount = totalAmount;
            payable(msg.sender).transfer(totalAmount);
            totalAmount = 0;
            count = 0;
        } else {
            if (isEqual) {
                //等额红包
                grabbedAmount = totalAmount / count;
                payable(msg.sender).transfer(grabbedAmount);
                //把总钱数--
                totalAmount -= grabbedAmount;
            } else {
                //随机红包
                //如果是不等额红包 计算10以内的随机数
                uint256 random = (uint256(
                    keccak256(
                        abi.encodePacked(
                            msg.sender,
                            owner,
                            count,
                            totalAmount,
                            block.timestamp
                        )
                    )
                ) % 8) + 1;
                grabbedAmount = (totalAmount * random) / 10;
                payable(msg.sender).transfer(grabbedAmount);
                totalAmount -= grabbedAmount;
            }
        }
        count--;
        emit RedPacketGrabbed(msg.sender, grabbedAmount);
    }
}
