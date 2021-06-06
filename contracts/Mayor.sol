pragma solidity 0.8.1;

contract Mayor {
    
    // Structs, events, and modifiers
    
    // Store refund data
    struct Refund {
        uint soul;
        bool doblon;
    }
    
    // Data to manage the confirmation
    struct Conditions {
        uint32 quorum;
        uint32 envelopes_casted;
        uint32 envelopes_opened;
        bool open;
    }
    
    event NewMayor(address _candidate);
    event Sayonara(address _escrow);
    event EnvelopeCast(address _voter);
    event EnvelopeOpen(address _voter, uint _soul, bool _doblon);
    
    // Someone can vote as long as the quorum is not reached
    modifier canVote() {
        require(voting_condition.envelopes_casted < voting_condition.quorum, "Cannot vote now, voting quorum has been reached");
        _;   
    }
    
    // Envelopes can be opened only after receiving the quorum
    modifier canOpen() {
        require(voting_condition.envelopes_casted == voting_condition.quorum, "Cannot open an envelope, voting quorum not reached yet");
        _;
    }
    
    // The outcome of the confirmation can be computed as soon as all the casted envelopes have been opened
    modifier canCheckOutcome() {
        require(voting_condition.envelopes_opened == voting_condition.quorum, "Cannot check the winner, need to open all the sent envelopes");
        require(voting_condition.open != false, "The elections has already been decleared");
        _;
    }
    
    // State attributes
    
    // Initialization variables
    address payable public candidate;
    address payable public escrow;
    
    // Voting phase variables
    mapping(address => bytes32) envelopes;

    Conditions voting_condition;

    uint public naySoul;
    uint public yaySoul;

    // Refund phase variables
    mapping(address => Refund) souls;
    address[] voters;

    /// @notice The constructor only initializes internal variables
    /// @param _candidate (address) The address of the mayor candidate
    /// @param _escrow (address) The address of the escrow account
    /// @param _quorum (address) The number of voters required to finalize the confirmation
    constructor(address payable _candidate, address payable _escrow, uint32 _quorum) public {
        candidate = _candidate;
        escrow = _escrow;
        voting_condition = Conditions({quorum: _quorum, envelopes_casted: 0, envelopes_opened: 0, open: true});
    }


    /// @notice Store a received voting envelope
    /// @param _sigil (uint) The secret sigil of a voter
    /// @param _doblon (bool) The voting preference
    /// @param _soul (uint) The soul associated to the vote
    function cast_envelope(uint _sigil, bool _doblon, uint _soul) canVote public {

        if(envelopes[msg.sender] == 0x0) // => NEW, update on 17/05/2021
            voting_condition.envelopes_casted++;

        envelopes[msg.sender] = compute_envelope(_sigil, _doblon, _soul);
        emit EnvelopeCast(msg.sender);
        
    }
    
    
    /// @notice Open an envelope and store the vote information
    /// @param _sigil (uint) The secret sigil of a voter
    /// @param _doblon (bool) The voting preference
    /// @dev The soul is sent as crypto
    /// @dev Need to recompute the hash to validate the envelope previously casted
    function open_envelope(uint _sigil, bool _doblon) canOpen public payable {
        
        //safe checks
        require(envelopes[msg.sender] != 0x0, "The sender has not casted any votes");
        require(souls[msg.sender].soul == 0x0, "You have already opened your envelope");
        
        bytes32 _casted_envelope = envelopes[msg.sender];
        bytes32 _sent_envelope = compute_envelope(_sigil, _doblon, msg.value);

        require(_casted_envelope == _sent_envelope, "Sent envelope does not correspond to the one casted");
        
        //add souls to the correct vote counter
        if (_doblon == true)
            yaySoul += msg.value;
        else
            naySoul += msg.value;
        
        //update the number of opened envelopes
        voting_condition.envelopes_opened++;
        
        //pushing voter infos and refund
        souls[msg.sender] = Refund(msg.value, _doblon);
        voters.push(msg.sender);
        
        emit EnvelopeOpen(msg.sender, msg.value, _doblon);
    }
    
    
    /// @notice Either confirm or kick out the candidate. Refund the electors who voted for the losing outcome
    function mayor_or_sayonara() canCheckOutcome public {
        
        //closing voting
        voting_condition.open = false;
        
        //checking winner and manage payments
        bool elected = yaySoul > naySoul;
        if (elected) {
            candidate.transfer(naySoul);
            emit NewMayor(candidate);
        } else {
            escrow.transfer(naySoul);
            emit Sayonara(escrow);
        }
        
        //refund the losers
        for (uint i=0; i<voters.length; i++){
            if (souls[voters[i]].doblon != elected){
                address payable voter = payable(voters[i]);
                voter.transfer(souls[voter].soul);
            }
        }
        
    }

    function get_quorum() public {
        return [voting_condition.quorum, voting_condition.envelopes_casted];
    }
 
    /// @notice Compute a voting envelope
    /// @param _sigil (uint) The secret sigil of a voter
    /// @param _doblon (bool) The voting preference
    /// @param _soul (uint) The soul associated to the vote
    function compute_envelope(uint _sigil, bool _doblon, uint _soul) private pure returns(bytes32) {
        return keccak256(abi.encode(_sigil, _doblon, _soul));
    }
    
}