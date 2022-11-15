// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract StudentTeamBallot {

    struct Voter {
        bool voted;  // if true, that person already voted
        int vote;   // index of the voted proposal
        bool vfst;
        int team;
        bool live;
    }

    struct Team {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        int voteCount; // number of accumulated votes
    }  

    address public professor;
    address public ta;
    address[] public vfs; 

    bytes32[] public teamNames = [
        bytes32("Core4"), // Team 0
        bytes32("Maroon Traders"), // Team 1
        bytes32("RP Squad"), // Team 2
        bytes32("Stonk X"), // Team 3
        bytes32("TBD"),  // Team 4
        bytes32("The Intelligent Investors"), // Team 5
        bytes32("to{sigma}"), // Team 6 
        bytes32("Unnamed Group") // Team 7
    ];  

    mapping(address => Voter) public voters;

    Team[] public teams;

    /** 
     * @dev Create a new ballot to vote on teams
     */
    constructor() {
        professor = msg.sender;

        voters[professor] = Voter({
            voted:false,
            vote: -1,
            vfst:false,
            team: -1,
            live: true
        });

        for (uint t = 0; t < teamNames.length; t++) {
            teams.push(Team({
                name: teamNames[t],
                voteCount: 0
            }));
        }
    }

    function setTA(address taAddress) public {
        require(
            msg.sender == professor,
            "Only professor can set the TA."
        );

        voters[taAddress] = Voter({
            voted:false,
            vote: -1,
            vfst:false,
            team: -1,
            live: true
        });
    }

    /** 
     * @dev Give student the right to vote on this ballot. May only be called by 'professor'.
     * @param studentAddress address of voter
     * @param teamNumber the number of the team address     
     */
    function addStudent(address studentAddress, int teamNumber) public {
        require(
            msg.sender == professor,
            "Only professor can give right to vote."
        );

        require(
            !voters[studentAddress].voted,
            "The voter already voted."
        );

        voters[studentAddress] = Voter({
            voted: false,
            vote: -1,
            vfst: false,
            team: teamNumber,
            live: true
        });        
    }

    /**
     * @dev Give your vote to team with specified number.
     * @param teamNumber index of team in the team array
     */
    function vote(int teamNumber) public {
        Voter storage sender = voters[msg.sender];
        require(sender.live, "Not a live address");
        require(!sender.voted, "Already voted.");
        require(teamNumber >= 0, "Invalid teamNumber");
        require(teamNumber <= 7, "Invalid teamNumber");

        sender.voted = true;
        sender.vote = teamNumber;

        if (teamNumber == sender.team) {
            sender.vfst = true;
            teams[uint(teamNumber)].voteCount -= 1;
            vfs.push(msg.sender);
        } else {
            sender.vfst = false;
            teams[uint(teamNumber)].voteCount += 1;
        }
    }

    /** 
     * @dev Computes the winning team taking all previous votes into account.
     * @return winningTeam_ index of winning proposal in the proposals array
     */
    function winningTeam() public view
            returns (uint winningTeam_)
    {
        int winningVoteCount = 0;
        for (uint t = 0; t < teams.length; t++) {
            if (teams[t].voteCount > winningVoteCount) {
                winningVoteCount = teams[t].voteCount;
                winningTeam_ = t;
            }
        }
    }

    function voteTotals() public view returns (int[8] memory)
    {
        int[8] memory teamVoteTotals = [
            teams[0].voteCount,
            teams[1].voteCount,
            teams[2].voteCount,
            teams[3].voteCount,
            teams[4].voteCount,
            teams[5].voteCount,
            teams[6].voteCount,
            teams[7].voteCount          
        ];

        return teamVoteTotals;
    }

    function getVFS() public view returns (address[] memory) {
        return vfs;
    }

    /** 
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = teams[winningTeam()].name;
    }
}