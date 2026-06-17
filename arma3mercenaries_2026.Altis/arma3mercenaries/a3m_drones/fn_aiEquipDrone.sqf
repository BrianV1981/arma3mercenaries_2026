/*
    A3M_fnc_aiEquipDrone
    Equips an AI drone with a payload automatically, bypassing player inventory checks.
*/
params ["_drone", ["_payloadClass", "SatchelCharge_Remote_Mag"]];

if (!alive _drone) exitWith {};

// Create ultra-lightweight visual proxy (SimpleObject)
private _modelPath = getText (configFile >> "CfgMagazines" >> _payloadClass >> "model");
if ((_modelPath select [0,1]) != "\") then { _modelPath = "\" + _modelPath; };
if (_modelPath == "" || _modelPath == "\") then { _modelPath = "\A3\weapons_f\explosives\satchel"; };

private _dummy = createSimpleObject [_modelPath, [0,0,0]];
_dummy attachTo [_drone, [0, 0, -0.15]];

// Setup Variables for the drop script
_drone setVariable ["A3M_Payload", _dummy, true];
_drone setVariable ["A3M_Payload_Class", _payloadClass, true];
_drone setVariable ["A3M_Payload_Owner", driver _drone, true];
