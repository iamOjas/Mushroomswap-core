//SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

import './interfaces/IMushroomswapFactory.sol';
import './MushroomswapPair.sol';

contract MushroomswapFactory is IMushroomswapFactory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;


    constructor(address _feeToSetter)  {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'Mushroomswap: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Mushroomswap: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Mushroomswap: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(MushroomswapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IMushroomswapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Mushroomswap: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Mushroomswap: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}