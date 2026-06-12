/*
    fn_serverStowMercenary.sqf
    Server-side logic to find a deployed mercenary, validate distance, and safely delete them from the world.
*/
params ["_client", "_mercID"];

if (!isServer) exitWith {};

private _targetUnit = objNull;

{
    if ((_x getVariable ["arma3mercenaries_aiUnit", ""]) == _mercID) exitWith { _targetUnit = _x; };
} forEach allUnits;

if (isNull _targetUnit) exitWith { "Error: Cannot locate mercenary on the map." remoteExecCall ["systemChat", _client]; };

if (!alive _targetUnit) exitWith { "Error: Mercenary is dead." remoteExecCall ["systemChat", _client]; };

// Validate distance (must be within 50 meters of the player interacting with the barracks)
private _distance = _client distance _targetUnit;
if (_distance > 50) exitWith { 
    (format ["Error: Mercenary is %1m away. They must be within 50m of the barracks to stow.", round _distance]) remoteExecCall ["systemChat", _client]; 
};

// Safe to stow
private _name = name _targetUnit;

// (Phase 2 Future Expansion: Save their current inventory/weapons to their DB profile here)

// Securely delete the object
deleteVehicle _targetUnit;

format ["%1 has been safely returned to the barracks.", _name] remoteExecCall ["systemChat", _client];

// Refresh the UI so the state updates seamlessly
[_client] spawn {
    params ["_client"];
    uiSleep 0.5; // Wait for the engine to flush the deleted unit from the allUnits array
    [_client, true] call A3M_fnc_serverFetchSquadDossier;
};
