// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.7.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Main is
    ERC1155,
    Ownable,
    ERC1155Pausable,
    ERC1155Burnable,
    ERC1155Supply
{
    uint256 constant PUBLIC_PRICE = 0.5 ether;

    uint256 constant MAX_SUPPLY = 1000;

    uint256 constant ALLOW_MINT_PRICE = 0.05 ether;

    bool public ALLOW_LIST_MINT = true;

    bool public PUBLIC_MINT = true;

    mapping(address => bool) public allowList;

    constructor(
        address initialOwner
    )
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
        Ownable(initialOwner)
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function updateMintStatus(
        bool _ALLOW_LIST_MINT,
        bool _PUBLIC_MINT
    ) external onlyOwner {
        ALLOW_LIST_MINT = _ALLOW_LIST_MINT;
        PUBLIC_MINT = _PUBLIC_MINT;
    }

    function allowMint(uint256 id, uint256 amount) public payable onlyOwner {
        require(ALLOW_LIST_MINT, "Mint Closed!");
        require(allowList[msg.sender],"You Are Not On The AllowList");
        require(msg.value == ALLOW_MINT_PRICE * amount, "Not Enough Money");
        require(totalSupply(id) + amount <= MAX_SUPPLY, "Max Supply Reached");
        _mint(msg.sender, id, amount, "");
    }

    function setAllowList(address[] calldata allAddress)external  onlyOwner{
        for (uint256 i = 0; i<allAddress.length; i++) {
            allowList[allAddress[i]] = true;
        }
    }

    function publicMint(uint256 id, uint256 amount) public payable {
        require(PUBLIC_MINT, "Mint Closed!");
        require(msg.value == PUBLIC_PRICE * amount, "Not Enough Money");
        require(totalSupply(id) + amount <= MAX_SUPPLY, "Max Supply Reached");
        _mint(msg.sender, id, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    function withdrawCbalance(address _address) private onlyOwner {
        uint256 contractBalance = address(this).balance;
        (bool sucess, ) = payable(_address).call{value: contractBalance}("");

        require(sucess, "Transfer Failed");
    }
}
