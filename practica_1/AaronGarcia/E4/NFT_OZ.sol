// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title NFT sencillo basado en OpenZeppelin (ERC-721)
/// @notice Cada token representa una entrada o activo único.
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";

contract MyNFT_OZ is ERC721, Ownable {
    uint256 private _nextId = 1;

    constructor() ERC721("EntradaNFT", "ENTRADA") Ownable(msg.sender) {}

    /// @notice Crea una nueva entrada NFT para el destinatario indicado
    function emitir(address to) external onlyOwner {
        _safeMint(to, _nextId);
        _nextId++;
    }

    /// @notice Devuelve el número total de NFTs emitidos
    function totalEmitidos() external view returns (uint256) {
        return _nextId - 1;
    }
}
