// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "BoringSolidity/interfaces/IERC20.sol";
import "BoringSolidity/libraries/BoringERC20.sol";
import "BoringSolidity/BoringOwnable.sol";
import "OpenZeppelin/utils/Address.sol";
import "interfaces/ICauldronV4.sol";
import "interfaces/IBentoBoxV1.sol";

contract CauldronOwner is BoringOwnable {
    using BoringERC20 for IERC20;

    error ErrNotOperator(address operator);
    error ErrCauldronNotAuthorized(address cauldron);
    error ErrBentoBoxNotAuthorized(address bentoBox);

    event LogOperatorChanged(address operator, bool enabled);
    event LogTreasuryChanged(address previous, address current);

    IERC20 public immutable mim;

    mapping(address => bool) public operators;
    address public treasury;

    modifier onlyOperators() {
        if (!operators[msg.sender]) {
            revert ErrNotOperator(msg.sender);
        }
        _;
    }

    constructor(address _treasury, IERC20 _mim) {
        treasury = _treasury;
        mim = _mim;

        emit LogTreasuryChanged(address(0), _treasury);
    }

    function setFeeTo(ICauldronV2 cauldron, address newFeeTo) external onlyOperators {
        cauldron.setFeeTo(newFeeTo);
    }

    function reduceSupply(ICauldronV2 cauldron, uint256 amount) external onlyOperators {
        cauldron.reduceSupply(amount);
    }

    function changeInterestRate(ICauldronV3 cauldron, uint64 newInterestRate) external onlyOperators {
        cauldron.changeInterestRate(cauldron, newInterestRate);
    }

    function changeBorrowLimit(
        ICauldronV3 cauldron,
        uint128 newBorrowLimit,
        uint128 perAddressPart
    ) external onlyOperators {
        cauldron.changeBorrowLimit(newBorrowLimit, perAddressPart);
    }

    function setBlacklistedCallee(
        ICauldronV4 cauldron,
        address callee,
        bool blacklisted
    ) external onlyOperators {
        cauldron.setBlacklistedCallee(callee, blacklisted);
    }

    function setAllowedSupplyReducer(
        ICauldronV4 cauldron,
        address account,
        bool allowed
    ) external onlyOperators {
        cauldron.setAllowedSupplyReducer(account, allowed);
    }

    function withdrawMIMToTreasury(IBentoBoxV1 bentoBox, uint256 share) external onlyOperators {
        uint256 maxShare = bentoBox.balanceOf(mim, address(this));
        if (share > maxShare) {
            share = maxShare;
        }

        bentoBox.withdraw(mim, address(this), treasury, 0, share);
    }

    function setOperator(address operator, bool enabled) external onlyOwner {
        operators[operator] = true;
        emit LogOperatorChanged(operator, enabled);
    }

    function transferMasterContractOwnership(BoringOwnable masterContract, address newOwner) external onlyOwner {
        masterContract.transferOwnership(newOwner, true, false);
    }

    function setTreasury(address _treasury) external onlyOwner {
        emit LogTreasuryChanged(treasury, _treasury);
        treasury = _treasury;
    }

    /// low level execution for any other future added functions
    function execute(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlyOwner returns (bool success, bytes memory result) {
        // solhint-disable-next-line avoid-low-level-calls
        (success, result) = to.call{value: value}(data);
    }
}
