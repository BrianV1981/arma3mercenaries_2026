params ["_target", "_caller"];

private _mags = magazines _caller;
private _payloadClass = "";

// Hierarchy of explosives (chooses the biggest one first if player has multiple)
if ("SatchelCharge_Remote_Mag" in _mags) then { _payloadClass = "SatchelCharge_Remote_Mag"; } else {
if ("DemoCharge_Remote_Mag" in _mags) then { _payloadClass = "DemoCharge_Remote_Mag"; } else {
if ("HandGrenade" in _mags) then { _payloadClass = "HandGrenade"; } else {
if ("MiniGrenade" in _mags) then { _payloadClass = "MiniGrenade"; } else {
if ("1Rnd_HE_Grenade_shell" in _mags) then { _payloadClass = "1Rnd_HE_Grenade_shell"; };
};};};};

if (_payloadClass == "") exitWith { systemChat "No suitable explosive found."; };

// 1. Remove from player
_caller removeItem _payloadClass;

// 2. Create ultra-lightweight visual proxy (SimpleObject)
private _modelPath = getText (configFile >> "CfgMagazines" >> _payloadClass >> "model");
// Ensure model path has a leading slash for createSimpleObject if it doesn't already
if ((_modelPath select [0,1]) != "\") then { _modelPath = "\" + _modelPath; };
// Fallback if model is broken
if (_modelPath == "" || _modelPath == "\") then { _modelPath = "\A3\weapons_f\explosives\satchel"; };

private _dummy = createSimpleObject [_modelPath, [0,0,0]];
_dummy attachTo [_target, [0, 0, -0.15]];

// 3. Setup Variables for the drop script
_target setVariable ["A3M_Payload", _dummy, true];
_target setVariable ["A3M_Payload_Class", _payloadClass, true];
_target setVariable ["A3M_Payload_Owner", _caller, true]; 

// 4. Add drop action natively to the drone so the pilot can scroll wheel it
private _actionID = _target addAction [
    "<t color='#FF0000'>[DROP PAYLOAD]</t>",
    {
        params ["_drone", "_caller", "_actionId", "_arguments"];
        [_drone, _caller] call A3M_fnc_dropPayload;
    },
    nil,
    6,
    false,
    true,
    "",
    "driver _target == _this || gunner _target == _this"
];
_target setVariable ["A3M_Payload_ActionID", _actionID, true];

private _name = getText (configFile >> "CfgMagazines" >> _payloadClass >> "displayName");
systemChat format ["%1 Attached! Use scroll wheel to drop it while flying.", _name];
