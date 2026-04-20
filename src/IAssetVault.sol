// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IAssetVault (Vertical Emission Class A)
 * @dev Gestisce il blocco degli RWA NFT e l'emissione delle quote ERC-20 indipendenti.
 */
interface IAssetVault {
    // Emesso quando l'Asset Master NFT viene messo in sicurezza e le quote vengono coniate
    event VaultLocked(uint256 indexed tokenId, uint256 classASupply);
    
    // Emesso se il vault viene dissolto (Legal exit)
    event VaultUnlocked(uint256 indexed tokenId);
    /**
    * @notice Protegge l'NFT e conia il 100% delle azioni di Classe A.
    * @param  tokenId L'ID dell'NFT Asset Master (ERC-721)
    * @param  amount fornitura totale di azioni di Classe A (ERC-20) da emettere
    */

    function lockAndMint(uint256 tokenId, uint256 amount) external;
    /**
    * @notice Ritorna lo stato e la fornitura dello specifico silo verticale
    */
   
    function getVaultStatus(uint256 tokenId) external view returns (
        bool isLocked, 
        uint256 currentSupply
    );
    function unlock(uint256 tokenId) external;
}