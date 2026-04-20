
# AVA Capital - RWA Tokenization (Ethereum Silo)

##  Overview del Progetto
Questo repository contiene l'implementazione dell'infrastruttura Smart Contract per **"Stock Exchange 2.0"** di AVA Capital, un ecosistema decentralizzato dedicato alla tokenizzazione di *Real World Assets* (RWA). 

Il sistema adotta un modello architetturale di **Vertical Emission**, in cui il "Silo Ethereum" funge da ancoraggio legale primario per l'asset fisico (Real Estate, Corporate Equity, ecc.) e, simultaneamente, da pool di liquidità frazionata per il mercato della finanza decentralizzata (DeFi). L'obiettivo è garantire un ecosistema *trustless*, trasparente e crittograficamente inalterabile.

##  Architettura
Il protocollo è sviluppato in Solidity utilizzando il framework Foundry e si basa sugli standard industriali sicuri certificati da OpenZeppelin. Il sistema è composto da tre core contract:

- **`AssetMaster.sol` (ERC-721):** Rappresenta il titolo legale primario e l'atto di proprietà inalterabile dell'asset fisico.
- **`ClassAShares.sol` (ERC-20):** Token fungibili che rappresentano le quote frazionate (equity/dividendi) legate all'Asset Master.
- **`FractionalVault.sol` (IAssetVault):** Contratto *lock-box* non custodiale. Si occupa di custodire in sicurezza l'Asset Master NFT ed emettere in modo atomico le quote ERC-20, fungendo da arbitro crittografico. I riferimenti ai contratti esterni sono dichiarati come `immutable` per prevenire qualsiasi manipolazione amministrativa post-deployment.

##  Project Structure

L'albero delle directory è organizzato per separare nettamente la logica on-chain, l'automazione infrastrutturale e le dipendenze esterne:

```text
ava-capital/
├── lib/                             # Sottomoduli Git e dipendenze esterne (OpenZeppelin)
├── script/                          # Automazione dell'infrastruttura (Infrastructure as Code)
│   └── Deploy.s.sol                 # Script deterministico di deploy e assegnazione ruoli
├── src/                             # Codice sorgente degli Smart Contract
│   ├── AssetMaster.sol              # Contratto ERC-721 (Rappresentazione del titolo legale)
│   ├── ClassAShares.sol             # Contratto ERC-20 (Quote frazionate di equity)
│   ├── FractionalVault.sol          # Core logic: Arbitro non custodiale (Lock-box)
│   └── IAssetVault.sol              # Interfaccia di standardizzazione del Vault
├── .env                             # Variabili d'ambiente crittografiche (Escluso dal versionamento)
├── remappings.txt                   # Tabella di routing per le importazioni delle librerie
└── README.md                        # Documentazione del repository
```

##  Prerequisiti
Per poter compilare, testare e deployare il progetto, assicurati di avere il seguente ambiente configurato:

- **Sistema Operativo:** Linux (Ubuntu/Debian), macOS, o Windows Subsystem for Linux (WSL)
- **Git:** Versione `>= 2.0.0`
- **Framework:** [Foundry](https://book.getfoundry.sh/) (toolchain basata su Rust: `forge`, `cast`, `anvil`)
- **Wallet Web3:** Un portafoglio (es. MetaMask) con fondi sufficienti sulla testnet Sepolia
- **Servizi Esterni:** - Un endpoint RPC valido per Sepolia (es. Alchemy, Infura, o pubblico)
  - Un'API Key di [Etherscan](https://etherscan.io/) per la verifica del codice sorgente

##  Installazione

**1. Clona il repository:**
```bash
git clone [https://github.com/TuoUsername/ava-capital.git](https://github.com/TuoUsername/ava-capital.git)
cd ava-capital
```

**2. Installa Foundry (se non è già presente sul tuo sistema):**
```bash
curl -L [https://foundry.paradigm.xyz](https://foundry.paradigm.xyz) | bash
foundryup
```

**3. Installa le librerie e le dipendenze (OpenZeppelin):**
```bash
forge install OpenZeppelin/openzeppelin-contracts
```

**4. Configura i remappings per il compilatore:**
```bash
echo "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/" > remappings.txt
```

**5. Compila gli Smart Contract per verificare che l'ambiente sia integro:**
```bash
forge build
```

##  Deployment

Il progetto utilizza uno script di *Infrastructure as Code* per automatizzare il deployment e l'assegnazione atomica dei privilegi di minting (`MINTER_ROLE`) al Vault in un'unica esecuzione.

**1. Configurazione delle variabili d'ambiente:**
Crea un file `.env` nella root del progetto e compila i seguenti campi:
```env
PRIVATE_KEY=0x_tua_chiave_privata_qui
SEPOLIA_RPC_URL=https://tuo_rpc_url_qui
ETHERSCAN_API_KEY=tua_etherscan_api_key_qui
```

**2. Carica le variabili in memoria:**
```bash
source .env
```

**3. Lancia lo script di Deploy su Sepolia:**
```bash
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  -vvvv
```


