/*
    arma3mercenaries\ticketing\fn_serverLogTicket.sqf
    Server-side script to safely serialize ticket data to extDB3 dedicated log file.
*/
params ["_player", "_title", "_desc", ["_type", "Bug"]];

if (!isServer) exitWith {};

private _uid = getPlayerUID _player;
private _name = name _player;
private _server = serverName;
if (_server == "") then { _server = "Dedicated Server"; };

// systemTimeUTC returns [year, month, day, hour, minute, second, millisecond]
private _timeArr = systemTimeUTC;
private _timeStr = format ["%1-%2-%3 %4:%5:%6 UTC", _timeArr select 0, _timeArr select 1, _timeArr select 2, _timeArr select 3, _timeArr select 4, _timeArr select 5];

// Format data for the python script to read easily (Pipe-separated or JSON)
// JSON is safer.
private _json = format ["{""author"":""%1"",""uid"":""%2"",""title"":""%3"",""description"":""%4"",""type"":""%5"",""server"":""%6"",""time"":""%7""}", 
    _name, 
    _uid, 
    (_title splitString (toString [10, 13, 9, 34])) joinString " ", 
    (_desc splitString (toString [10, 13, 9, 34])) joinString " ",
    _type,
    _server,
    _timeStr
];

// Write directly to the native Arma 3 .rpt/server_console.log file using diag_log
// The Python script will scan the server log directory for this specific prefix
diag_log format ["[A3M_TICKETS_EXPORT] %1", _json];

diag_log format ["[A3M TICKETS] Received and logged ticket from %1: %2", _name, _title];

// Notify player
["Ticket submitted securely. Thank you!"] remoteExecCall ["hint", _player];
