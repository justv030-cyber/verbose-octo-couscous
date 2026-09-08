# ERC-1155 NFT Minting Smart Contract

A Solidity-based **ERC-1155 NFT smart contract** built with **OpenZeppelin Contracts v5.7.0**.

This project supports:

* Public NFT minting
* Allowlist NFT minting
* Multiple ERC-1155 token IDs
* Per-token maximum supply
* Minting multiple token IDs in one transaction
* Burnable tokens
* Pause / unpause functionality
* Owner-controlled mint phases
* IPFS-based metadata
* ETH withdrawal

---

## 🚀 Features

### 1. ERC-1155

The contract implements the ERC-1155 multi-token standard.

A single contract can manage multiple token IDs:

```text
Token ID 1 → Sword
Token ID 2 → Shield
Token ID 3 → Potion
Token ID 4 → Gold
```

Each token ID can have its own supply.

---

### 2. Public Mint

Anyone can mint NFTs when public minting is enabled.

```solidity
function publicMint(uint256 id, uint256 amount)
    public
    payable
```

Public mint price:

```text
0.5 ETH per token
```

Example:

```text
1 NFT  → 0.5 ETH
2 NFTs → 1.0 ETH
3 NFTs → 1.5 ETH
```

Public minting can be enabled or disabled by the contract owner.

---

### 3. Allowlist Mint

Allowlisted addresses can mint NFTs at a lower price.

```text
Allowlist price = 0.05 ETH
```

Only addresses added to the allowlist can use the allowlist mint function.

The allowlist is stored using:

```solidity
mapping(address => bool) public allowList;
```

The owner can add multiple addresses:

```solidity
setAllowList(address[] calldata allAddress)
```

---

### 4. Mint Status Control

The owner can independently enable or disable:

```solidity
ALLOW_LIST_MINT
PUBLIC_MINT
```

Using:

```solidity
updateMintStatus(bool _ALLOW_LIST_MINT, bool _PUBLIC_MINT)
```

Example:

```text
Allowlist Mint → ON
Public Mint    → OFF
```

This allows the owner to run an allowlist/presale phase before opening the public sale.

---

## 💰 Mint Prices

| Mint Type      |    Price |
| -------------- | -------: |
| Allowlist Mint | 0.05 ETH |
| Public Mint    |  0.5 ETH |

These prices are defined as constants in the contract:

```solidity
uint256 constant PUBLIC_PRICE = 0.5 ether;
uint256 constant ALLOW_MINT_PRICE = 0.05 ether;
```

---

## 📦 Maximum Supply

The contract defines:

```solidity
uint256 constant MAX_SUPPLY = 1000;
```

The supply limit is checked separately for each ERC-1155 token ID.

For example:

```text
Token ID 1 → maximum 1000
Token ID 2 → maximum 1000
Token ID 3 → maximum 1000
```

The contract checks:

```solidity
require(
    totalSupply(id) + amount <= MAX_SUPPLY,
    "Max Supply Reached"
);
```

---

## 📝 Allowlist

The owner can add addresses to the allowlist.

Example:

```solidity
address[] memory users = new address[](2);

users[0] = 0x123...;
users[1] = 0x456...;

setAllowList(users);
```

The contract stores:

```solidity
allowList[user] = true;
```

An allowlisted address can then call:

```solidity
allowMint(id, amount);
```

---

## 🎨 Metadata

The contract uses an IPFS URI:

```text
ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/
```

The URI can be updated by the owner:

```solidity
function setURI(string memory newuri)
    public
    onlyOwner
```

---

## 🔥 Burn

The contract inherits:

```solidity
ERC1155Burnable
```

Token holders can burn their own ERC-1155 tokens.

---

## ⏸️ Pause / Unpause

The owner can pause the contract:

```solidity
pause();
```

And resume it:

```solidity
unpause();
```

Pausing uses OpenZeppelin's `ERC1155Pausable`.

This can be useful during emergencies or maintenance.

---

## 🪙 Owner Mint

The owner can mint multiple token IDs in one transaction using:

```solidity
mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
)
```

Example:

```text
Token ID 1 → 10 tokens
Token ID 2 → 5 tokens
Token ID 3 → 20 tokens
```

This is useful for administrative or collection-related minting.

---

## 💸 Withdraw

The contract contains an owner-only withdrawal function:

```solidity
withdrawCbalance(address _address)
```

It transfers the contract's ETH balance to the specified address.

The transfer uses:

```solidity
(bool success, ) =
    payable(_address).call{value: contractBalance}("");
```

---

## 🔐 Access Control

The contract uses OpenZeppelin's:

```solidity
Ownable
```

Only the owner can perform administrative operations such as:

* Updating metadata URI
* Pausing the contract
* Unpausing the contract
* Updating mint status
* Managing the allowlist
* Owner minting

---

## 🏗️ Contract Architecture

```text
Main
│
├── ERC1155
│   └── Multi-token NFT standard
│
├── Ownable
│   └── Owner access control
│
├── ERC1155Pausable
│   └── Pause / unpause
│
├── ERC1155Burnable
│   └── Token burning
│
└── ERC1155Supply
    └── Token supply tracking
```

---

## 🛠️ Technologies

* Solidity `^0.8.27`
* OpenZeppelin Contracts `^5.7.0`
* ERC-1155
* IPFS
* Ethereum / EVM-compatible networks
* Remix / Hardhat

---

## 📋 Main Functions

### Owner Functions

```solidity
setURI(string memory newuri)
```

Updates the NFT metadata URI.

```solidity
pause()
```

Pauses token operations.

```solidity
unpause()
```

Resumes token operations.

```solidity
updateMintStatus(
    bool _ALLOW_LIST_MINT,
    bool _PUBLIC_MINT
)
```

Controls allowlist and public mint phases.

```solidity
setAllowList(address[] calldata allAddress)
```

Adds addresses to the allowlist.

```solidity
mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
)
```

Mints multiple token IDs.

---

### User Functions

```solidity
allowMint(
    uint256 id,
    uint256 amount
)
```

Allows allowlisted users to mint.

```solidity
publicMint(
    uint256 id,
    uint256 amount
)
```

Allows anyone to mint during the public sale.

---

## 🔄 Mint Flow

### Allowlist Mint

```text
Owner
  │
  ▼
Add wallet to Allowlist
  │
  ▼
Enable Allowlist Mint
  │
  ▼
User calls allowMint()
  │
  ▼
Payment verified
  │
  ▼
Supply verified
  │
  ▼
ERC-1155 NFT minted
```

### Public Mint

```text
Owner
  │
  ▼
Enable Public Mint
  │
  ▼
User calls publicMint()
  │
  ▼
Payment verified
  │
  ▼
Supply verified
  │
  ▼
ERC-1155 NFT minted
```

---

## ⚠️ Important Note

The current `allowMint()` function contains:

```solidity
onlyOwner
```

while also checking:

```solidity
allowList[msg.sender]
```

This means **only the contract owner can currently call `allowMint()`**, so normal allowlisted users cannot use it.

If the intention is to allow allowlisted users to mint, remove `onlyOwner` from `allowMint()`:

```solidity
function allowMint(
    uint256 id,
    uint256 amount
) public payable {
    require(ALLOW_LIST_MINT, "Mint Closed!");
    require(
        allowList[msg.sender],
        "You Are Not On The AllowList"
    );

    require(
        msg.value == ALLOW_MINT_PRICE * amount,
        "Not Enough Money"
    );

    require(
        totalSupply(id) + amount <= MAX_SUPPLY,
        "Max Supply Reached"
    );

    _mint(msg.sender, id, amount, "");
}
```

This is an important fix before deploying the contract for a real allowlist sale.

---

## 📄 License

This project is licensed under the MIT License.

```text
MIT License
```

---

## 👨‍💻 Author

**Harshil Thummar**

Blockchain / Solidity Developer

Technologies:

```text
Solidity
ERC-20
ERC-721
ERC-1155
Smart Contracts
NFT
DeFi
Ethereum
BNB Chain
Polygon
Hardhat
Ethers.js
Web3.js
```
