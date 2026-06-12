/*
    arma3mercenaries_killRewards.sqf
    Author: BrianV1981
    Version: v0.001
    Notes: Final version using profile names, global vars, server-side logic, AI wallet restored, CfgFunctions warning call.
*/
diag_log "//________________ arma3mercenaries Kill Rewards Script v0.001 ________________";

if (isServer) then {
    // diag_log "[A3M REWARDS SRV v0.001] Adding EntityKilled handler."; // Optional Log

    addMissionEventHandler ["entityKilled", {
        params ["_killed", "_killer", "_instigator"];
        if (isNull _instigator) then { _instigator = _killer };
        if (isNull _instigator || isNull _killed || !(_killed isKindOf "CAManBase")) exitWith {};

        try {
            // --- GET BASIC INFO & COMMON SETTINGS ---
            private _sideKiller = getNumber (configFile >> "cfgVehicles" >> typeOf _instigator >> "side");
            private _sideKilled = getNumber (configFile >> "cfgVehicles" >> typeOf _killed >> "side");
            private _instigatorIsPlayer = isPlayer _instigator;
            private _killedIsPlayer = isPlayer _killed;
            private _killedName = name _killed; // Use profile name
            private _instigatorName = name _instigator; // Use profile name
            private _factionNameKilled = switch (_sideKilled) do { case 0:{"OPFOR"}; case 1:{"NATO"}; case 2:{"Independent"}; case 3:{"Civilian"}; default {"Unknown"}; };
            private _factionNameKiller = switch (_sideKiller) do { case 0:{"OPFOR"}; case 1:{"NATO"}; case 2:{"Independent"}; case 3:{"Civilian"}; default {"Unknown"}; };
            // Fetch settings using global vars + isNil checks
            private _friendlyFirePenalty = if (isNil "arma3mercenaries_friendlyFirePenalty") then { 10000 } else { arma3mercenaries_friendlyFirePenalty };
            private _friendlyFireCompensation = if (isNil "arma3mercenaries_friendlyFireCompensation") then { 20000 } else { arma3mercenaries_friendlyFireCompensation };
            private _civilianKillPenalty = if (isNil "arma3mercenaries_civilianKillPenalty") then { 10000 } else { arma3mercenaries_civilianKillPenalty };
            private _deathPenalty = if (isNil "arma3mercenaries_deathPenalty") then { 10000 } else { arma3mercenaries_deathPenalty };
            private _opforKillReward = if (isNil "arma3mercenaries_opforKillReward") then { 10000 } else { arma3mercenaries_opforKillReward };
            private _opforAiWallet = if (isNil "arma3mercenaries_opforAiWallet") then { 10000 } else { arma3mercenaries_opforAiWallet };
            private _natoKillReward = if (isNil "arma3mercenaries_natoKillReward") then { 10000 } else { arma3mercenaries_natoKillReward };
            private _natoAiWallet = if (isNil "arma3mercenaries_natoAiWallet") then { 1000 } else { arma3mercenaries_natoAiWallet };
            private _independentKillReward = if (isNil "arma3mercenaries_independentKillReward") then { 10000 } else { arma3mercenaries_independentKillReward };
            private _independentAiWallet = if (isNil "arma3mercenaries_independentAiWallet") then { 1000 } else { arma3mercenaries_independentAiWallet };
            private _natoPenaltyIndependent = if (isNil "arma3mercenaries_natoPenaltyIndependent") then { 10000 } else { arma3mercenaries_natoPenaltyIndependent };
            private _civilianAiWallet = if (isNil "arma3mercenaries_civilianAiWallet") then { 1000 } else { arma3mercenaries_civilianAiWallet };
            // Use the correct setting name for warnings
            private _warningsEnabled = if (isNil "arma3mercenaries_penaltyWarningsEnabled") then { true } else { arma3mercenaries_penaltyWarningsEnabled };

            // --- PENALTY/REWARD LOGIC ---

            // ** A. Handle Friendly Fire Penalty **
            if (_instigatorIsPlayer && _sideKiller == _sideKilled && _instigator != _killed && _friendlyFirePenalty > 0) then {
                [_instigator, -_friendlyFirePenalty, true] call grad_moneymenu_fnc_addFunds;
                if (_warningsEnabled) then { // Check the correct setting
                    private _message = format [ "<t size='0.55' align='center' color='#FF0000' shadow='1'>FRIENDLY FIRE!</t><br/><t size='0.45' align='center'>Killed %1 (%2). -%3 Bank</t>", _killedName, _factionNameKilled, _friendlyFirePenalty ];
                    [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _instigator]; // Target local function definition
                };
            };

            // ** B. Handle Friendly Fire Compensation **
            if (_killedIsPlayer && _sideKiller == _sideKilled && _instigator != _killed && _friendlyFireCompensation > 0) then {
                [_killed, _friendlyFireCompensation, true] call grad_moneymenu_fnc_addFunds;
                if (_warningsEnabled) then { // Check the correct setting
                    private _message = format [ "<t size='0.55' align='center' color='#FFA500' shadow='1'>COMPENSATION</t><br/><t size='0.45' align='center'>Killed by FF (%1/%2). +%3 Bank</t>", _instigatorName, _factionNameKiller, _friendlyFireCompensation ];
                    [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _killed]; // Target local function definition
                };
            };

            // ** C. Civilian Kill Penalty **
            if (_instigatorIsPlayer && _sideKilled == 3 && _civilianKillPenalty > 0) then {
                [_instigator, -_civilianKillPenalty, true] call grad_moneymenu_fnc_addFunds;
                if (_warningsEnabled) then { // Check the correct setting
                    private _message = format [ "<t size='0.55' align='center' color='#FF0000' shadow='1'>CIVILIAN KILLED!</t><br/><t size='0.45' align='center'>%1. -%2 Bank</t>", _killedName, _civilianKillPenalty ];
                    [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _instigator]; // Target local function definition
                };
            };

            // ** D. Handle Kill Rewards & Specific Penalties (Enemy Kills) **
            if (_instigatorIsPlayer && _sideKiller != _sideKilled && _sideKilled != 3) then {
                 switch (_sideKilled) do {
                    case 0:{if(_opforKillReward>0)then{private _r=round random _opforKillReward;if(_r>0)then{[_instigator,_r,false]call grad_moneymenu_fnc_addFunds;};};};
                    case 1:{if(_sideKiller==0 && _natoKillReward>0)then{private _r=round random _natoKillReward;if(_r>0)then{[_instigator,_r,false]call grad_moneymenu_fnc_addFunds;};};};
                    case 2:{
                        if(_sideKiller==0 && _independentKillReward>0)then{private _r=round random _independentKillReward;if(_r>0)then{[_instigator,_r,false]call grad_moneymenu_fnc_addFunds;};}
                        else{if(_sideKiller!=2 && _natoPenaltyIndependent>0)then{[_instigator,-_natoPenaltyIndependent,true]call grad_moneymenu_fnc_addFunds; if (_warningsEnabled) then { private _message = format [ "<t size='0.55' align='center' color='#FF8C00' shadow='1'>INDEPENDENT KILLED!</t><br/><t size='0.45' align='center'>%1 (%2). -%3 Bank</t>", _killedName, _factionNameKilled, _natoPenaltyIndependent ]; [_message] remoteExecCall ["A3M_fnc_showWarningHUD",_instigator];};};}; // Check warning setting here too
                    };
                 };
            };

            // ** E. AI Wallet Amounts **
            if (!_killedIsPlayer) then {
                private _walletAmount=0; private _maxWallet=0;
                switch (_sideKilled) do { case 0:{_maxWallet=_opforAiWallet};case 1:{_maxWallet=_natoAiWallet};case 2:{_maxWallet=_independentAiWallet};case 3:{_maxWallet=_civilianAiWallet}; };
                _walletAmount=round random _maxWallet;
                if(_walletAmount>0 && !isNull _killed)then{[_killed,_walletAmount,false]call grad_moneymenu_fnc_addFunds;};
            };

            // ** F. Death Penalty **
            if (_killedIsPlayer && _sideKiller != _sideKilled && _deathPenalty > 0) then {
                [_killed, -_deathPenalty, true] call grad_moneymenu_fnc_addFunds;
                if (_warningsEnabled) then { // Check the correct setting
                    private _message = format [ "<t size='0.55' align='center' color='#FF0000' shadow='1'>PENALTY</t><br/><t size='0.45' align='center'>You Died! -%1 Bank</t>", _deathPenalty ];
                    [_message] remoteExecCall ["A3M_fnc_showWarningHUD", _killed]; // Target local function definition
                };
            };

        } catch { diag_log ("[A3M REWARDS SRV v0.001] ERROR: " + str _exception); };
    }];
};

diag_log "//________________ arma3mercenaries Kill Rewards Script v0.001 Finished Loading ________________";