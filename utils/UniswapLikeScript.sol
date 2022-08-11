// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "swappers/ZeroXUniswapLikeLPLevSwapper.sol";
import "swappers/ZeroXUniswapLikeLPSwapper.sol";
import "oracles/ProxyOracle.sol";
import "oracles/TokenOracle.sol";
import "oracles/LPChainlinkOracle.sol";
import "oracles/InvertedLPOracle.sol";
import "interfaces/IBentoBoxV1.sol";
import "interfaces/IUniswapV2Pair.sol";
import "interfaces/IUniswapV2Router01.sol";
import "interfaces/ISwapperV2.sol";
import "interfaces/ILevSwapperV2.sol";

abstract contract UniswapLikeScript {
    function deployUniswapLikeZeroExSwappers(
        IBentoBoxV1 degenBox,
        IUniswapV2Router01 uniswapLikeRouter,
        IUniswapV2Pair collateral,
        ERC20 mim,
        address zeroXExchangeProxy
    ) public returns (ISwapperV2 swapper, ILevSwapperV2 levSwapper) {
        swapper = ISwapperV2(address(new ZeroXUniswapLikeLPSwapper(degenBox, collateral, mim, zeroXExchangeProxy)));
        levSwapper = ILevSwapperV2(
            address(new ZeroXUniswapLikeLPLevSwapper(degenBox, uniswapLikeRouter, collateral, mim, zeroXExchangeProxy))
        );
    }

    function deployUniswapLikeLPOracle(
        string memory desc,
        IUniswapV2Pair lp,
        IAggregator tokenAOracle,
        IAggregator tokenBOracle
    ) public returns (ProxyOracle proxy) {
        proxy = new ProxyOracle();
        TokenOracle tokenOracle = new TokenOracle(tokenAOracle, tokenBOracle);
        LPChainlinkOracle lpChainlinkOracle = new LPChainlinkOracle(lp, tokenOracle);
        InvertedLPOracle invertedLpOracle = new InvertedLPOracle(IAggregator(lpChainlinkOracle), tokenBOracle, desc);
        proxy.changeOracleImplementation(invertedLpOracle);
    }
}
