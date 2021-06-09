pragma solidity 0.8.1;

contract Mayor {

    // Structs, events, and modifiers

    // Store refund data
    struct Refund {
        uint soul;
        address sign;
    }

    // Data to manage the confirmation
    struct Conditions {
        uint32 quorum;
        uint32 envelopes_casted;
        uint32 envelopes_opened;
        bool open;
    }

    struct Candidate {
        uint32 deposit;
        uint souls;
        uint32 votes;
    }

    event NewMayor(address _candidate);
    event Sayonara(address _escrow);
    event EnvelopeCast(address _voter);
    event EnvelopeOpen(address _voter, uint _soul, address _sign);

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
    address[] public candidate;
    address payable public escrow;

    // Voting phase variables
    mapping(address => bytes32) envelopes;

    Conditions voting_condition;

    // Refund phase variables
    mapping(address => Refund) souls;
    mapping(address => Candidate) candidates;

    address[] voters;

    /// @notice The constructor only initializes internal variables
    /// @param _candidates (address) The address of the mayor candidate
    /// @param _escrow (address) The address of the escrow account
    /// @param _quorum (address) The number of voters required to finalize the confirmation
    constructor(address[] memory _candidates, address payable _escrow, uint32 _quorum) public {
        for (uint i=0; i<_candidates.length; i++){
            address key = _candidates[i];
            candidates[key] = Candidate({deposit:0, souls: 0, votes: 0});
            candidate.push(key);
        }

        escrow = _escrow;
        voting_condition = Conditions({quorum: _quorum, envelopes_casted: 0, envelopes_opened: 0, open: true});
    }


    /// @notice Store a received voting envelope
    /// @param _sigil (uint) The secret sigil of a voter
    /// @param _sign (address) The voting preference
    /// @param _soul (uint) The soul associated to the vote
    function cast_envelope(uint _sigil, address _sign, uint _soul) canVote public {

        if(envelopes[msg.sender] == 0x0)
            voting_condition.envelopes_casted++;

        envelopes[msg.sender] = compute_envelope(_sigil, _sign, _soul);
        emit EnvelopeCast(msg.sender);

    }


    /// @notice Open an envelope and store the vote information
    /// @param _sigil (uint) The secret sigil of a voter
    /// @param _sign (address) The voting preference
    /// @dev The soul is sent as crypto
    /// @dev Need to recompute the hash to validate the envelope previously casted
    function open_envelope(uint _sigil, address _sign) canOpen public payable {

        //safe checks
        require(envelopes[msg.sender] != 0x0, "The sender has not casted any votes");
        require(souls[msg.sender].soul == 0x0, "You have already opened your envelope");

        bytes32 _casted_envelope = envelopes[msg.sender];
        bytes32 _sent_envelope = compute_envelope(_sigil, _sign, msg.value);

        require(_casted_envelope == _sent_envelope, "Sent envelope does not correspond to the one casted");

        //add souls to the correct vote counter
        candidates[_sign].souls += msg.value;

        //update the number of opened envelopes
        voting_condition.envelopes_opened++;

        //pushing voter infos and refund
        souls[msg.sender] = Refund(msg.value, _sign);
        voters.push(msg.sender);

        emit EnvelopeOpen(msg.sender, msg.value, _sign);
    }


    /// @notice Either confirm or kick out the candidate. Refund the electors who voted for the losing outcome
    function mayor_or_sayonara() canCheckOutcome public {

        //closing voting
        voting_condition.open = false;

        //checking winner and manage payments
        address elected = address(0);
        uint maxSouls = 0;
        uint maxVotes = 0;
        bool invalid = false;
        for (uint i=0; i<candidate.length; i++){
            Candidate memory cnd = candidates[candidate[i]];
            if (cnd.souls > maxSouls){
                //new first
                elected = payable(candidate[i]);
                maxSouls = cnd.souls;
                maxVotes = cnd.votes;
                invalid = false;
            } else if (cnd.souls == maxSouls) {
                //same souls, check voters
                if (cnd.votes > maxVotes){
                    //new first
                    elected = candidate[i];
                    maxSouls = cnd.souls;
                    maxVotes = cnd.votes;
                    invalid = false;
                } else if (cnd.votes == maxVotes){
                    //marking as potentially invalid
                    invalid = true;
                }
            }
        }
        if (invalid) {
            uint allsouls = 0;
            for (uint i=0; i<candidate.length; i++){
                uint c_souls = candidates[candidate[i]].souls;
                candidates[candidate[i]].souls = 0; //protection for reentrancy
                allsouls += c_souls;
            }
            escrow.transfer(allsouls);
            emit Sayonara(escrow);
            return;
        } else {
            uint w_souls = candidates[elected].souls;
            candidates[elected].souls = 0;
            payable(elected).transfer(w_souls);
            emit NewMayor(elected);
        }

        //refund the losers
        for (uint i=0; i<voters.length; i++){
            if (souls[voters[i]].sign != elected){
                address payable voter = payable(voters[i]);
                voter.transfer(souls[voter].soul);
            }
        }

    }

    //This API is used by the FlowScreen to display the proper step
    //@param address
    //It returns a list of:
    //uint32 => quorum
    //uint32 => votes casted
    //bool => if passed addr have open his letter
    function get_quorum(address addr) public view returns(uint32, uint32, bool){
        return (voting_condition.quorum, voting_condition.envelopes_casted, (souls[addr].soul == 0x0));
    }

    function get_candidates() public view returns(address[] memory){
        return candidate;
    }


    /// @notice Compute a voting envelope
    /// @param _sigil (uint) The secret sigil of a voter
    /// @param _sign (address) The voting preference
    /// @param _soul (uint) The soul associated to the vote
    function compute_envelope(uint _sigil, address _sign, uint _soul) private pure returns(bytes32) {
        return keccak256(abi.encode(_sigil, _sign, _soul));
    }

}