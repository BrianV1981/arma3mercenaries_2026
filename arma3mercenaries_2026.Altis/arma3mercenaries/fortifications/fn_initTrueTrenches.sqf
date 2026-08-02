// arma3mercenaries_2026.Altis/arma3mercenaries/fortifications/fn_initTrueTrenches.sqf
/*
    A3M True Terrain-Deforming Trenches (Issue #127)
    Author: A.I.M.
*/

if (!hasInterface) exitWith {};

// --- CBA SETTINGS ---
[
    "A3M_Trench_BaseTime",
    "SLIDER",
    ["Trench Dig Time (Seconds)", "Base time to dig a trench without engineer bonus"],
    "A3M Trenches",
    [10, 120, 60, 0], // min, max, default, decimals
    true, // isGlobal
    {}
] call CBA_fnc_addSetting;

[
    "A3M_Trench_EngineerBonus",
    "SLIDER",
    ["Engineer Speed Bonus (Multiplier)", "Multiplier applied if player has Engineer trait (e.g. 0.5 = twice as fast)"],
    "A3M Trenches",
    [0.1, 1.0, 0.5, 2], // min, max, default, decimals
    true, // isGlobal
    {}
] call CBA_fnc_addSetting;


private _condition = {
    "ACE_EntrenchingTool" in (items player)
};

private _onAction = {
    private _baseTime = missionNamespace getVariable ["A3M_Trench_BaseTime", 60];
    private _engineerBonus = missionNamespace getVariable ["A3M_Trench_EngineerBonus", 0.5];
    
    private _digTime = _baseTime;
    if (player getUnitTrait "engineer") then {
        _digTime = _digTime * _engineerBonus;
    };
    
    // Calculate the target position (1.5m in front of player)
    private _targetPos = player modelToWorld [0, 1.5, 0];
    private _dir = getDir player;
    
    // Spawn the preview dummy
    private _previewObj = "Sign_Sphere10cm_F" createVehicleLocal _targetPos;
    _previewObj setDir _dir;
    
    [
        _digTime,
        [_previewObj, _targetPos, _dir],
        {
            params ["_args"];
            _args params ["_previewObj", "_targetPos", "_dir"];
            
            // Delete preview
            deleteVehicle _previewObj;
            
            // Execute the deformation on the server so it can drop the anchor!
            [[_targetPos, _dir, getPlayerUID player]] remoteExec ["A3M_fnc_serverDeformTerrain", 2, false];
            
            hint "Trench Digging Complete!";
        },
        {
            params ["_args"];
            _args params ["_previewObj"];
            deleteVehicle _previewObj;
            hint "Trench digging cancelled.";
        },
        "Digging Trench..."
    ] call CBA_fnc_progressBar;
};

private _action = [
    "A3M_DigTrueTrench",
    "Dig True Trench (Deform Terrain)",
    "", // icon
    _onAction,
    _condition
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions", "ACE_Equipment"], _action] call ace_interact_menu_fnc_addActionToObject;
