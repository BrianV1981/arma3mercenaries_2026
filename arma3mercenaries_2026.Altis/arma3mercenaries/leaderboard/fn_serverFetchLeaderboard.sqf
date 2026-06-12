// File: arma3mercenaries\leaderboard\fn_serverFetchLeaderboard.sqf
/*
    fn_serverFetchLeaderboard.sqf
    Fetches the pre-compiled A3M_GLOBAL_LEADERBOARDS array directly from SQLite.
    (Compiled by the Python daemon to ensure offline players are included).
*/

params ["_client"];

// Fetch the 4 arrays: [killers, shots, wealth, distance]
private _leaderboardData = ["A3M_GLOBAL_LEADERBOARDS", [[],[],[],[]], false] call A3M_fnc_dbGetSecure;

// Remote execute back to the client
_leaderboardData remoteExec ["A3M_fnc_receiveLeaderboardData", _client];