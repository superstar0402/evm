# <h1 align="center"> Reproduced Exploits Library </h1>
A library with previously exploited vulnerabilities, categorized by type (common denominator of each exploit). 

To contribute, create a new file inside the most appropriate category. Use the `template.txt` file in the `test` folder including the information related to the attack.

Utils that perform flashloans and swaps are provided in `test/utils` to ease the job of reproducing future attacks.
Also, modules that provide enhanced features to Foundry are included in the `test/modules` folder. 
 
Each exploit can be found under the test folder.

## Index
### [How to Install, Compile and Run](#-how-to-install-compile-and-run-)

Currently, 26 past exploits were reproduced. 

### Access Control
- [TempleDAO, Oct 2022 - (~$2.3MM) - Unchecked ownership on token migration](/test/Access_Control/TempleDao/TempleDao)
- [Rikkei, Apr 2022 - ($1MM) - Public Oracle Setter](/test/Access_Control/Rikkei/Rikkei)
- [DAOMaker, Sept 2021 - (~$4MM) - Public Init](/test/Access_Control/DAOMaker/DAOMaker)
- [Sandbox, Feb 2022 - (1 NFT, possibly more) - Public Burn](/test/Access_Control/Sandbox/Sandbox)
- [Punk Protocol, Aug 2021 - (~$8MM) - Non initialized contract](/test/Access_Control/PunkProtocol/PunkProtocol)


### Bad Data Validation
- [Olympus DAO Bond, Oct 2022 - ($300,000) - Arbitrary Tokens / Unchecked transfers](/test/Bad_Data_Validation/Bond_OlympusDAO/Bond_OlympusDAO)
- [Bad Guys NFT, Sept 2022 - (400 NFTs) - Unchecked Mint Amount](/test/Bad_Data_Validation/Bad_Guys_NFT/Bad_Guys_NFT)
- [Multichain a.k.a AnySwap, Jan 2022 - ($960,000) - Arbitrary Tokens / Unchecked Permit](/test/Bad_Data_Validation/Multichain_Permit/Multichain_Permit)
- [Superfluid, Jan 2022 - ($8.7MM) - Calldata crafting / CTX not verified](/test/Bad_Data_Validation/Superfluid/Superfluid)

### Business Logic
- [EarningFarm, Oct 2022 - (200 ETH) - Unchecked Flashloan reception](/test/Business_Logic/EarningFarm/EarningFarm)
- [BVaults, Oct 2022 - ($35,000) - DEX Pair Manipulation](/test/Business_Logic/Bvaults/Bvaults)
- [Fantasm Finance, Mar 2022 - ($2.4MM) - Unchecked Payments While Minting](/test/Business_Logic/Fantasm_Finance/Fantasm_Finance)
- [Compound - Mar 2022 - ($0) - Side Entrance on cToken](/test/Business_Logic/Compound/Compound.reported.sol)
- [OneRing Finance - Mar 2022 - (~$2MM) - Price Feed Manipulation](/test/Business_Logic/OneRingFinance/OneRingFinance)
- [Vesper Rari Pool - Nov 2021 - (~$3MM) - Price Feed Manipulation](/test/Business_Logic/VesperRariFuse/VesperRariFuse)
- [Uranium - Apr 2021 - (~$50MM) - Wrong Constant Product AMM checks](/test/Business_Logic/Uranium/Uranium)

### Reentrancy
- [DFX Finance - Nov 2022 - (~$6MM) - Reentrancy / Side Entrance](/test/Reentrancy/DFXFinance/DFXFinance)
- [Fei Protocol, Apr 2022 - (~$80MM) - Cross Function Reentrancy / FlashLoan Attack](/test/Reentrancy/FeiProtocol/FeiProtocol)
- [Revest Protocol, Mar 2022 - (~$2MM) - ERC1155 Reentrancy / Flashswap Attack](/test/Reentrancy/RevestFinance/RevestFinance)
- [Hundred Finance - Mar 2022 - (~$6MM) - Reentrancy / ERC667 Transfer Hook](/test/Reentrancy/HundredFinance/HundredFinance)
- [Paraluni - Mar 2022 - (~$1.7MM) - Reentrancy / Arbitrary tokens](/test/Reentrancy/Paraluni/Paraluni)
- [Cream Finance - Aug 2021 - (~$18MM) - Reentrancy / ERC777 Transfer Hook](/test/Reentrancy/CreamFinance/CreamFinance)
- [Read Only Reentrancy - N/A - N/A - Read Only Reentrancy](/test/Reentrancy/ReadOnlyReentrancy/ReadOnlyReentrancy)

### Bridges
- [Nomad Bridge, Aug 2022 - (~$190MM) - Invalid Root Hash Commitment / Poor Root Validation](/test/Bridges/NomadBridge/NomadBridge)
- [Ronin Bridge, Mar 2022 - (~$624MM) - Compromised Keys](/test/Bridges/RoninBridge/RoninBridge)
- [PolyNetwork Bridge, Aug 2021 - (~$611MM) - Arbitrary External Calls, Access Control Bypass](/test/Bridges/PolyNetworkBridge/PolyNetworkBridge)


Another interesting repo that might be handy: https://github.com/SunWeb3Sec/DeFiHackLabs

# <h2 align="center"> How to Install, Compile and Run </h2>[]

**Template repository for getting started quickly with Hardhat and Foundry in one project**

### Getting Started

 * Use Foundry: 
```bash
forge install
forge test
```

 * Use Hardhat:
```bash
npm install
npx hardhat test
```

### Features

 * Write / run tests with either Hardhat or Foundry:
```bash
forge test
# or
npx hardhat test
```

 * Use Hardhat's task framework
```bash
npx hardhat example
```

 * Install libraries with Foundry which work with Hardhat.
```bash
forge install rari-capital/solmate # Already in this repo, just an example
```

### Notes

Whenever you install new libraries using Foundry, make sure to update your `remappings.txt` file by running `forge remappings > remappings.txt`. This is required because we use `hardhat-preprocessor` and the `remappings.txt` file to allow Hardhat to resolve libraries you install with Foundry.
