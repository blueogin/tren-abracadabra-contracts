// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "BoringSolidity/interfaces/IERC20.sol";

interface IERC20Vault is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
    
    function underlying() external returns (IERC20);

    function enter(uint256 amount) external returns (uint256 shares);

    function leave(uint256 shares) external returns (uint256 amount);

    function toAmount(uint256 shares) external view returns (uint256);

    function toShares(uint256 amount) external view returns (uint256);
}
