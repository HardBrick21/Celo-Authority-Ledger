// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CeloAuthorityState
 * @notice Authority Ledger deployed on Celo for stablecoin-native micro-lending
 * @dev Optimized for Celo's low fees and stablecoin infrastructure
 */
contract CeloAuthorityState {
    
    enum AuthorityLevel {
        REVOKED,
        OBSERVE,
        SUGGEST,
        EXECUTE
    }
    
    enum DecayReason {
        FRESHNESS_TIMEOUT,
        ACK_TIMEOUT,
        SESSION_EXPIRY
    }
    
    struct AuthorityStateInfo {
        AuthorityLevel level;
        bytes32 scope;
        uint256 expiresAt;
        uint256 lastActivity;
        bool isActive;
        uint256 creditLimit;  // cUSD credit limit for micro-lending
    }
    
    struct Transition {
        bytes32 id;
        address agent;
        AuthorityLevel fromLevel;
        AuthorityLevel toLevel;
        bytes32 evidenceRef;
        uint256 timestamp;
    }
    
    // Agent state
    mapping(address => AuthorityStateInfo) public authorities;
    mapping(bytes32 => Transition) public transitions;
    mapping(address => bytes32[]) public agentHistory;
    
    uint256 public totalTransitions;
    address public owner;
    
    // cUSD token address on Celo
    address public constant CUSD = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    
    event AuthorityGranted(address indexed agent, AuthorityLevel level, uint256 creditLimit);
    event AuthorityDecayed(address indexed agent, AuthorityLevel from, AuthorityLevel to);
    event AuthorityRevoked(address indexed agent, bytes32 evidenceRef);
    event MicroLoanIssued(address indexed agent, address borrower, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @notice Grant authority with cUSD credit limit for micro-lending
     */
    function grantAuthority(
        address agent,
        AuthorityLevel level,
        bytes32 scope,
        uint256 duration,
        uint256 creditLimit
    ) external onlyOwner returns (bytes32 transitionId) {
        require(agent != address(0), "Invalid address");
        require(level != AuthorityLevel.REVOKED, "Cannot grant REVOKED");
        
        AuthorityStateInfo storage state = authorities[agent];
        
        transitionId = _createTransition(agent, state.level, level, bytes32(0));
        
        state.level = level;
        state.scope = scope;
        state.expiresAt = duration > 0 ? block.timestamp + duration : 0;
        state.lastActivity = block.timestamp;
        state.isActive = true;
        state.creditLimit = creditLimit;
        
        emit AuthorityGranted(agent, level, creditLimit);
    }
    
    /**
     * @notice Issue micro-loan in cUSD (Celo stablecoin)
     * @dev Only agents with EXECUTE level can issue loans
     */
    function issueMicroLoan(
        address borrower,
        uint256 amount
    ) external returns (bytes32 loanId) {
        require(borrower != address(0), "Invalid borrower address");
        
        AuthorityStateInfo storage state = authorities[msg.sender];
        require(state.level == AuthorityLevel.EXECUTE, "Need EXECUTE level");
        require(state.isActive, "Agent not active");
        require(amount <= state.creditLimit, "Exceeds credit limit");
        
        // Generate loan ID with more entropy
        loanId = keccak256(abi.encode(
            msg.sender,
            borrower,
            amount,
            block.timestamp,
            totalTransitions
        ));
        
        // In production, this would transfer cUSD
        // IERC20(CUSD).transfer(borrower, amount);
        
        emit MicroLoanIssued(msg.sender, borrower, amount);
    }
    
    /**
     * @notice Check authority level
     */
    function checkAuthority(address agent, AuthorityLevel required) 
        external view returns (bool hasAuthority, AuthorityLevel current) 
    {
        require(agent != address(0), "Invalid address");
        
        AuthorityStateInfo storage state = authorities[agent];
        current = state.level;
        hasAuthority = uint8(state.level) >= uint8(required) && state.isActive;
    }
    
    /**
     * @notice Get agent history
     */
    function getAgentHistory(address agent) external view returns (bytes32[] memory) {
        require(agent != address(0), "Invalid address");
        return agentHistory[agent];
    }
    
    // Internal functions
    function _createTransition(
        address agent,
        AuthorityLevel from,
        AuthorityLevel to,
        bytes32 evidenceRef
    ) internal returns (bytes32 transitionId) {
        transitionId = keccak256(abi.encode(
            agent,
            uint8(from),
            uint8(to),
            block.timestamp,
            totalTransitions,
            msg.sender
        ));
        
        transitions[transitionId] = Transition({
            id: transitionId,
            agent: agent,
            fromLevel: from,
            toLevel: to,
            evidenceRef: evidenceRef,
            timestamp: block.timestamp
        });
        
        agentHistory[agent].push(transitionId);
        totalTransitions++;
    }
}
