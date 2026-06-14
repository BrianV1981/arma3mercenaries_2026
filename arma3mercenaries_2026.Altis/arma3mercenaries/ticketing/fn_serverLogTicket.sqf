/*
    arma3mercenaries\ticketing\fn_serverLogTicket.sqf
    Server-side script to safely serialize ticket data to extDB3 dedicated log file.
*/
params ["_player", "_title", "_desc"];

if (!isServer) exitWith {};

private _uid = getPlayerUID _player;
private _name = name _player;

// Format data for the python script to read easily (Pipe-separated or JSON)
// JSON is safer.
private _json = format ["{""author"":""%1"",""uid"":""%2"",""title"":""%3"",""description"":""%4""}", 
    _name, 
    _uid, 
    _title regexReplace ["\n|\r|\t|""", ""], // Strip bad characters
    _desc regexReplace ["\n|\r|\t|""", " "]
];

// Write directly to an extDB3 dedicated log file (will create @extDB3/logs/A3M_Tickets.log)
"extDB3" callExtension format["9:ADD_LOG:A3M_Tickets:%1", _json];

diag_log format ["[A3M TICKETS] Received and logged ticket from %1: %2", _name, _title];

// Notify player
["Ticket submitted securely. Thank you!"] remoteExecCall ["hint", _player];
