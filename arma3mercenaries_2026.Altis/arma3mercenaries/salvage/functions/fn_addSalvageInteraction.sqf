/*
    A3M Salvage System - Add Interaction
    Author: A.I.M. / BrianV1981
    Description: Adds the ACE interaction to a destroyed vehicle locally for the client.
*/

params ["_vehicle"];

// Ensure we don't add multiple actions to the same vehicle
if (_vehicle getVariable ["a3m_salvage_action_added", false]) exitWith {};
_vehicle setVariable ["a3m_salvage_action_added", true, false];

private _action = [
    "A3M_SalvageWreck",
    "Salvage Wreck",
    "",
    {
        params ["_target", "_player", "_params"];
        
        // 1. Check if they have the required item
        if (A3M_Salvage_RequiredItem != "" && {!(A3M_Salvage_RequiredItem in (items _player))}) exitWith {
            private _displayName = getText (configFile >> "CfgWeapons" >> A3M_Salvage_RequiredItem >> "displayName");
            if (_displayName == "") then { _displayName = getText (configFile >> "CfgMagazines" >> A3M_Salvage_RequiredItem >> "displayName"); };
            if (_displayName == "") then { _displayName = A3M_Salvage_RequiredItem; };
            
            private _message = format ["<t color='#FF0000' size='0.6'>Salvage Failed</t><br/><t size='0.5'>You need a %1 to salvage this wreck.</t>", _displayName];
            [_message, -1, 0.8, 5, 0.5, 0, 789] call BIS_fnc_dynamicText;
        };

        // 2. Start the ACE Progress Bar
        [
            A3M_Salvage_Time, 
            [_target, _player], 
            {
                params ["_args"];
                _args params ["_wreck", "_salvager"];
                
                private _vehicleType = typeOf _wreck;
                private _reward = parseNumber A3M_Salvage_DefaultReward;
                
                // Parse the CBA string array into an actual array
                private _customArray = call compile A3M_Salvage_Values_String;
                if (isNil "_customArray" || {typeName _customArray != "ARRAY"}) then { _customArray = []; };
                
                // Optional: Check if the vehicle has a specific custom reward defined
                private _customReward = _customArray select {(_x select 0) == _vehicleType};
                if (count _customReward > 0) then {
                    _reward = (_customReward select 0) select 1;
                };
                
                // --- ECONOMY PAYOUT ---
                switch (A3M_Salvage_EconomyMode) do {
                    case 0: { // GRAD Money Menu (Bank)
                        [_salvager, _reward, true] remoteExec ["GRAD_moneymenu_fnc_addFunds", 2, false];
                    };
                    case 1: { // HoverGuy Simple Economy
                        [_reward, 0] remoteExec ["HG_fnc_addOrSubCash", _salvager, false];
                    };
                    case 2: { // Custom Player Variable
                        // Executing on server to prevent client-side cheating of global vars
                        [[_salvager, _reward, A3M_Salvage_CustomVariable], {
                            params ["_unit", "_amount", "_varName"];
                            _unit setVariable [_varName, (_unit getVariable [_varName, 0]) + _amount, true];
                        }] remoteExec ["call", 2];
                    };
                    case 3: { // Physical Item Drop
                        private _box = "Land_Money_F" createVehicle (getPos _wreck);
                    };
                };
                
                private _formattedReward = [_reward, 1, 0, true] call CBA_fnc_formatNumber;
                private _message = format ["<t color='#00FF00' size='0.6'>Salvage Complete</t><br/><t size='0.5'>$%1 has been paid out.</t>", _formattedReward];
                [_message, -1, 0.8, 10, 0.5, 0, 789] call BIS_fnc_dynamicText;
                
                // Delete the wreck on the machine that owns it to prevent locality failures
                _wreck remoteExec ["deleteVehicle", _wreck];
            }, 
            {
                // On Failure/Cancel
                private _message = "<t color='#FFFF00' size='0.6'>Salvage Cancelled</t>";
                [_message, -1, 0.8, 3, 0.5, 0, 789] call BIS_fnc_dynamicText;
            }, 
            "Salvaging Wreck..."
        ] call ace_common_fnc_progressBar;
    },
    {
        // Condition: The vehicle is dead and the player is alive
        alive _player && {damage _target >= 1 || !alive _target}
    }
] call ace_interact_menu_fnc_createAction;

[_vehicle, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
