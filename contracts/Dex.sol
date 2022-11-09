// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract Dex{
    //state variables
    address payable public owner;

    //AAVE ERC20 Token addresses on goerli network
    address private immutable daiAddress=0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464;
    address private immutable usdcAddress=0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43;

    IERC20 private dai;
    IERC20 private usdc;

    //Exchange rate indexes
    uint256 dexARate = 90; //90%
    uint256 dexBRate = 100; //100%

    //Keeps track of individual's dai balances
    mapping(address => uint256) public daiBalances;
    //Keeps track of individual's usdc balances
    mapping(address => uint256) public usdcBalances;

    constructor(){
        owner = payable(msg.sender);
        dai =IERC20(daiAddress);
        usdc = IERC20(usdcAddress);
    }

    modifier onlyOwner (){
        require(
            msg.sender == owner, "Only the contract owner can call this function"
        );
        _;
    }

    function depositUSDC(uint256 _amount) external{
        usdcBalances[msg.sender] += _amount; //updates usdc balances
        uint256 allowance = usdc.allowance(msg.sender, address(this));
        //`amount` as the allowance of `spender` over the caller's tokens.
        require(allowance >= _amount, "Check the token allowance");
        usdc.transferFrom(msg.sender, address(this), _amount);
//      function transferFrom(
//      address sender,
//      address recipient,
//      uint256 amount
//      ) external returns (bool);
    }

    function depositDAI(uint256 _amount) external {
        daiBalances[msg.sender] += _amount;
        uint256 allowance = dai.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        dai.transferFrom(msg.sender, address(this), _amount);
    }


    // uint256 dexARate = 90; //90%
    // uint256 dexBRate = 100; //100%

    function buyDAI() external {
        uint256 daiToReceive = ((usdcBalances[msg.sender] / dexARate)*100)*(10 ** 12); //(10 usdc/90)*100 => 90%
        dai.transfer(msg.sender, daiToReceive);
    }
    // 10 usdc / ? dai => (10/90)*100 *1e12 = (10/9)*000000000000
    //11110000000000

    function sellDAI() external {
        uint256 usdcToReceive = ((daiBalances[msg.sender] * dexBRate) / 100) /(10 ** 12);
        usdc.transfer(msg.sender, usdcToReceive);
    } 
    //Calculated in wei (include decimal difference)

    // 1 USDC = 1,000,000
    // 1 DAI = 1,000,000,000,000,000,000


    function getBalance(address _tokenAddress) external view returns (uint256){
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable{}
}