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

private _fnc_digAction = {
    params ["_target", "_player", "_params"];
    _params params ["_size"];

    private _baseTime = missionNamespace getVariable ["A3M_Trench_BaseTime", 60];
    private _engineerBonus = missionNamespace getVariable ["A3M_Trench_EngineerBonus", 0.5];
    
    private _digTime = _baseTime;
    if (_size == "SMALL") then {
        _digTime = _digTime * 0.6; // Small is 40% faster
    };
    
    if (player getUnitTrait "engineer") then {
        _digTime = _digTime * _engineerBonus;
    };
    
    A3M_Trench_Dummy = "Sign_Sphere10cm_F" createVehicleLocal [0,0,0];
    A3M_Trench_DigTime = _digTime;
    A3M_Trench_Size = _size;
    
    hint format ["%1 Foxhole Placement: Look around to position. Press SPACE to Dig. Press ESC to Cancel.", _size];
    
    // Render Loop
    A3M_Trench_DrawEH = addMissionEventHandler ["Draw3D", {
        private _pos = player modelToWorld [0, 2, 0];
        _pos set [2, getTerrainHeightASL _pos]; // Snap to ground
        
        A3M_Trench_Dummy setPosASL _pos;
        A3M_Trench_Dummy setDir (getDir player);
        
        drawIcon3D ["", [1,0.5,0,1], _pos vectorAdd [0,0,0.5], 1, 1, 0, format ["Press SPACE to dig %1 Foxhole", A3M_Trench_Size], 1, 0.04, "RobotoCondensedBold"];
    }];
    
    // Keybind Intercept
    A3M_Trench_KeyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_display", "_key"];
        
        if (_key == 57) exitWith {
            // Spacebar (Confirm)
            removeMissionEventHandler ["Draw3D", A3M_Trench_DrawEH];
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", A3M_Trench_KeyEH];
            
            private _targetPos = getPos A3M_Trench_Dummy;
            private _dir = getDir A3M_Trench_Dummy;
            private _sizeStr = A3M_Trench_Size;
            deleteVehicle A3M_Trench_Dummy;
            
            // Start CBA Progress Bar
            [
                format ["Digging %1 Foxhole...", _sizeStr],
                A3M_Trench_DigTime,
                {true},
                {
                    params ["_args"];
                    _args params ["_targetPos", "_dir", "_sizeStr"];
                    
                    // Execute the deformation on the server
                    [[_targetPos, _dir, getPlayerUID player, _sizeStr]] remoteExec ["A3M_fnc_serverDeformTerrain", 2, false];
                    hint format ["%1 Foxhole Digging Complete!", _sizeStr];
                },
                {
                    hint "Foxhole digging cancelled.";
                },
                [_targetPos, _dir, _sizeStr]
            ] call CBA_fnc_progressBar;
            
            true
        };
        
        if (_key == 1) exitWith {
            // Esc (Cancel)
            removeMissionEventHandler ["Draw3D", A3M_Trench_DrawEH];
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", A3M_Trench_KeyEH];
            deleteVehicle A3M_Trench_Dummy;
            hint "Foxhole placement cancelled.";
            true
        };
        
        false
    }];
};

private _actionLarge = [
    "A3M_DigFoxholeLarge",
    "Dig Large Foxhole",
    "", // icon
    _fnc_digAction,
    _condition,
    {},
    ["LARGE"]
] call ace_interact_menu_fnc_createAction;

private _actionSmall = [
    "A3M_DigFoxholeSmall",
    "Dig Small Foxhole",
    "", // icon
    _fnc_digAction,
    _condition,
    {},
    ["SMALL"]
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions", "ACE_Equipment"], _actionLarge] call ace_interact_menu_fnc_addActionToObject;
[player, 1, ["ACE_SelfActions", "ACE_Equipment"], _actionSmall] call ace_interact_menu_fnc_addActionToObject;
