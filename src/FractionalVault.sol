// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// 1. Importiamo l'interfaccia principale dal suo file separato
import {IAssetVault} from "./IAssetVault.sol";

/**
 * @dev Interfaccia minima per interagire con ClassAShares (ERC-20).
 * Reinserita per garantire il disaccoppiamento e l'ottimizzazione del Gas.
 */
interface IClassAShares {
    function mint(address to, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}

/**
 * @title FractionalVault
 * @notice Un contratto "lock-box" non custodiale progettato per mettere in sicurezza l'Asset Master NFT 
 * e autorizzare il minting delle quote frazionate.
 */
contract FractionalVault is IAssetVault, ReentrancyGuard, IERC721Receiver {
    
    // Riferimenti immutabili ai contratti esterni per garantire il disaccoppiamento
    IERC721 public immutable assetMaster;
    
    // Utilizziamo l'interfaccia come best practice per la blockchain (DIP - Dependency Inversion)
    IClassAShares public immutable classAShares;

    // Struttura dati che rispecchia il modello ER (Silo / VaultState)
    struct VaultState {
        bool isLocked;
        uint256 classASupply;
        address issuerAddress;
    }

    // Mapping per tracciare lo stato di ogni singolo immobile (Silo indipendente)
    mapping(uint256 => VaultState) public silos;

    /**
     * @dev Il costruttore riceve gli indirizzi del Catasto (NFT) e delle Quote (ERC-20)
     */
    constructor(address _assetMaster, address _classAShares) {
        require(_assetMaster != address(0), "Invalid AssetMaster address");
        require(_classAShares != address(0), "Invalid ClassAShares address");
        
        assetMaster = IERC721(_assetMaster);
        classAShares = IClassAShares(_classAShares);
    }

    /**
     * @notice Mette in sicurezza l'NFT e conia il 100% della fornitura di quote di Classe A.
     * @param tokenId L'ID dell'Asset Master NFT (ERC-721).
     * @param amount La fornitura totale di quote di Classe A (ERC-20) da emettere.
     */
    function lockAndMint(uint256 tokenId, uint256 amount) external override nonReentrant {
        // --- CHECKS ---
        require(amount > 0, "Amount must be greater than zero");
        require(assetMaster.ownerOf(tokenId) == msg.sender, "Caller is not the owner");
        require(!silos[tokenId].isLocked, "Asset is already locked");

        // --- EFFECTS ---
        silos[tokenId] = VaultState({
            isLocked: true,
            classASupply: amount,
            issuerAddress: msg.sender
        });

        // --- INTERACTIONS ---
        assetMaster.transferFrom(msg.sender, address(this), tokenId);
        
        // Ordina al contratto ERC-20 tramite interfaccia di stampare le quote
        classAShares.mint(msg.sender, amount);

        emit VaultLocked(tokenId, amount);
    }

    /**
     * @notice Restituisce l'NFT e distrugge le quote (Exit Strategy)
     * @dev Pre-condizione: L'Issuer deve aver riacquisito il 100% della supply circolante 
     * e approvato il Vault a spenderla tramite approve() sul contratto ERC-20.
     */
    function unlock(uint256 tokenId) external override nonReentrant {
        VaultState memory silo = silos[tokenId];
        
        // --- CHECKS ---
        require(silo.isLocked, "Asset is not locked");
        require(silo.issuerAddress == msg.sender, "Caller is not the original issuer");

        // --- EFFECTS ---
        silos[tokenId].isLocked = false;
        silos[tokenId].classASupply = 0; // reset esplicito per l'Auditor

        // --- INTERACTIONS ---
        classAShares.burnFrom(msg.sender, silo.classASupply);
        assetMaster.transferFrom(address(this), msg.sender, tokenId);

        emit VaultUnlocked(tokenId);
    }

    /**
     * @notice Restituisce lo stato e la fornitura del silo specifico.
     */
    function getVaultStatus(uint256 tokenId) external view override returns (bool isLocked, uint256 currentSupply) {
        VaultState memory silo = silos[tokenId];
        return (silo.isLocked, silo.classASupply);
    }

    /**
     * @dev Gestisce la ricezione sicura dell'NFT validando che arrivi solo dall'AssetMaster.
     */
    function onERC721Received(
        address /*operator*/, 
        address /*from*/, 
        uint256 /*tokenId*/, 
        bytes calldata /*data*/
    ) external view override returns (bytes4) {
        require(msg.sender == address(assetMaster), "Only AssetMaster NFTs accepted");
        return this.onERC721Received.selector;
    }
}