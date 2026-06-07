// plays random tracks for each player independently of eachother
execVM "arma3mercenaries\jukebox\arma3mercenaries_playRandomTracks.sqf";

// ambiant radio chatter
execVM "arma3mercenaries\jukebox\ambientRadioChatter.sqf";

execVM "scripts\HG_initPlayerLocal.sqf";
execVM "arma3mercenaries\tutorials\quickTutorial.sqf";
execVM "scripts\wearAllUniforms.sqf";

// player traits
player setUnitTrait ["UAVHacker",true];
player setUnitTrait ["explosiveSpecialist",true];

// -------------------------------------------------------------------------
// --- ACE SELF-INTERACT MENU REORGANIZATION ---
// -------------------------------------------------------------------------

// 1. Create Parent Categories
private _catSupport = ["A3M_LogisticsStore", "[Emergency Support]", "", {}, {true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions"], _catSupport] call ace_interact_menu_fnc_addActionToObject;

private _catSquad = ["A3M_SquadCommand", "[Squad Commands]", "", {}, {true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions"], _catSquad] call ace_interact_menu_fnc_addActionToObject;

private _catDB = ["A3M_ConstellisDB", "[Constellis Database]", "", {}, {true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions"], _catDB] call ace_interact_menu_fnc_addActionToObject;


// 2. GRAD MoneyMenu Stores -> [Support & Logistics]
[player, "aliveStore_2", container_2, aHelipad_2, "Combat Support Menu", "Emergency ALiVE Combat Support Services", {true}, [0,0,0], 3, ["ACE_SelfActions", "A3M_LogisticsStore"]] call grad_lbm_fnc_addInteraction;
[player, "haloStore_2", container_2, aHelipad_2, "High-altitude Military Parachuting", "Emergency SAC Services", {true}, [0,0,0], 3, ["ACE_SelfActions", "A3M_LogisticsStore"]] call grad_lbm_fnc_addInteraction;
[player, "mercenaryStore_parachute", container_2, aHelipad_2, "Private Security Services Contractors For Hire", "Emergency Constellis Holdings, Inc. Services", {true}, [0,0,0], 3, ["ACE_SelfActions", "A3M_LogisticsStore"]] call grad_lbm_fnc_addInteraction;
[player, "supplyDropStore_1", container_2, aHelipad_2, "Supply Drops", "Emergency Supply Drops", {true}, [0,0,0], 3, ["ACE_SelfActions", "A3M_LogisticsStore"]] call grad_lbm_fnc_addInteraction;


// 3. Squad Controls -> [Squad Command]
[] execVM "arma3mercenaries\set_group_captive\groupRejoin.sqf";

private _actGrpRecall = ["groupTeleport","Recall Squad","",{execVM "arma3mercenaries\group_teleport\groupTeleport.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpRecall] call ace_interact_menu_fnc_addActionToObject;

private _actGrpStandDown = ["groupSetCaptive","Stand Down (Deactivate)","",{execVM "arma3mercenaries\set_group_captive\setGroupCaptive_proofOfConcept.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpStandDown] call ace_interact_menu_fnc_addActionToObject;

private _actGrpMobilize = ["groupRejoin","Mobilize (Reactivate)","",{execVM "arma3mercenaries\set_group_captive\groupRejoin_proofOfConcept.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpMobilize] call ace_interact_menu_fnc_addActionToObject;

private _actGrpAssemble = ["groupAssemble","Assemble Formations","",{execVM "arma3mercenaries\set_group_captive\groupRejoin.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpAssemble] call ace_interact_menu_fnc_addActionToObject;


// 4. Database Controls -> [Constellis Database]
A3M_fnc_initMercenary = compileFinal (preprocessFileLineNumbers "arma3mercenaries\mercenaries\fn_initMercenary.sqf");
A3M_fnc_openPlayerCard = compileFinal (preprocessFileLineNumbers "arma3mercenaries\player_profile\fn_openPlayerCard.sqf");
A3M_fnc_receiveProfileData = compileFinal (preprocessFileLineNumbers "arma3mercenaries\player_profile\fn_receiveProfileData.sqf");
[] execVM "arma3mercenaries\player_profile\fn_initPedometer.sqf";

private _actPlayerCard = ["a3m_playerCard","View Player Dossier","",{[] call A3M_fnc_openPlayerCard},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_ConstellisDB"], _actPlayerCard] call ace_interact_menu_fnc_addActionToObject;

A3M_fnc_openLeaderboard = compileFinal (preprocessFileLineNumbers "arma3mercenaries\leaderboard\fn_openLeaderboard.sqf");
A3M_fnc_receiveLeaderboardData = compileFinal (preprocessFileLineNumbers "arma3mercenaries\leaderboard\fn_receiveLeaderboardData.sqf");
A3M_fnc_openTargetPlayerCard = compileFinal (preprocessFileLineNumbers "arma3mercenaries\leaderboard\fn_openTargetPlayerCard.sqf");

private _actLeaderboard = ["a3m_leaderboard","View Global Leaderboards","",{[] call A3M_fnc_openLeaderboard},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_ConstellisDB"], _actLeaderboard] call ace_interact_menu_fnc_addActionToObject;


// -------------------------------------------------------------------------
// --- ACE GLOBAL VEHICLE INTERACTIONS (Replaces addActions) ---
// -------------------------------------------------------------------------

private _catVehicleOps = ["A3M_VehicleOps", "[Vehicle Operations]", "", {}, {true}] call ace_interact_menu_fnc_createAction;
["LandVehicle", 0, ["ACE_MainActions"], _catVehicleOps, true] call ace_interact_menu_fnc_addActionToClass;
["Air", 0, ["ACE_MainActions"], _catVehicleOps, true] call ace_interact_menu_fnc_addActionToClass;
["Ship", 0, ["ACE_MainActions"], _catVehicleOps, true] call ace_interact_menu_fnc_addActionToClass;

// 1. Claim Vehicle
private _claimAction = ["A3M_ClaimVehicle", "Claim Vehicle", "", {
    [_target] call HG_fnc_setOwner;
    _target setVariable ["ALiVE_disableDynamicSimulation", true, true];
}, {
    isNil {_target getVariable "HG_Owner"}
}] call ace_interact_menu_fnc_createAction;
["LandVehicle", 0, ["ACE_MainActions", "A3M_VehicleOps"], _claimAction, true] call ace_interact_menu_fnc_addActionToClass;
["Air", 0, ["ACE_MainActions", "A3M_VehicleOps"], _claimAction, true] call ace_interact_menu_fnc_addActionToClass;
["Ship", 0, ["ACE_MainActions", "A3M_VehicleOps"], _claimAction, true] call ace_interact_menu_fnc_addActionToClass;

// 2. Lock / Unlock
private _lockAction = ["A3M_ToggleLock", "Lock / Unlock", "", {
    [_target] call HG_fnc_lockOrUnlock;
}, {
    private _ownerArray = _target getVariable ["HG_Owner", []];
    (count _ownerArray > 0) && { ((_ownerArray select 0) == getPlayerUID player) || (getPlayerUID player in (_ownerArray select 3)) }
}] call ace_interact_menu_fnc_createAction;
["LandVehicle", 0, ["ACE_MainActions", "A3M_VehicleOps"], _lockAction, true] call ace_interact_menu_fnc_addActionToClass;
["Air", 0, ["ACE_MainActions", "A3M_VehicleOps"], _lockAction, true] call ace_interact_menu_fnc_addActionToClass;
["Ship", 0, ["ACE_MainActions", "A3M_VehicleOps"], _lockAction, true] call ace_interact_menu_fnc_addActionToClass;

// 3. Give Keys
private _keysAction = ["A3M_GiveKeys", "Give Keys", "", {
    [_target] call HG_fnc_dialogOnLoadGiveKey;
}, {
    private _ownerArray = _target getVariable ["HG_Owner", []];
    (count _ownerArray > 0) && { ((_ownerArray select 0) == getPlayerUID player) }
}] call ace_interact_menu_fnc_createAction;
["LandVehicle", 0, ["ACE_MainActions", "A3M_VehicleOps"], _keysAction, true] call ace_interact_menu_fnc_addActionToClass;
["Air", 0, ["ACE_MainActions", "A3M_VehicleOps"], _keysAction, true] call ace_interact_menu_fnc_addActionToClass;
["Ship", 0, ["ACE_MainActions", "A3M_VehicleOps"], _keysAction, true] call ace_interact_menu_fnc_addActionToClass;

// 4. Flip Vehicle (ACE Contextual)
private _flipAction = ["A3M_FlipVehicle", "Flip Vehicle", "", {
    private _normalVec = surfaceNormal getPos _target;
    if (!local _target) then {
        [_target, _normalVec] remoteExec ["setVectorUp", _target];
        [_target, [getPosATL _target select 0, getPosATL _target select 1, 0]] remoteExec ["setPosATL", _target];
    } else {
        _target setVectorUp _normalVec;
        _target setPosATL [getPosATL _target select 0, getPosATL _target select 1, 0];
    };
}, {
    // Only show if tilted > ~45 degrees or upside down
    (vectorUp _target) vectorCos (surfaceNormal getPos _target) < 0.7
}] call ace_interact_menu_fnc_createAction;
["LandVehicle", 0, ["ACE_MainActions", "A3M_VehicleOps"], _flipAction, true] call ace_interact_menu_fnc_addActionToClass;
["Ship", 0, ["ACE_MainActions", "A3M_VehicleOps"], _flipAction, true] call ace_interact_menu_fnc_addActionToClass;

// 5. A3M Radio
private _radioAction = ["A3M_Radio", "A3M Radio", "", {
    createDialog "customInterface";
}, {true}] call ace_interact_menu_fnc_createAction;
["LandVehicle", 0, ["ACE_MainActions", "A3M_VehicleOps"], _radioAction, true] call ace_interact_menu_fnc_addActionToClass;
["Air", 0, ["ACE_MainActions", "A3M_VehicleOps"], _radioAction, true] call ace_interact_menu_fnc_addActionToClass;
["Ship", 0, ["ACE_MainActions", "A3M_VehicleOps"], _radioAction, true] call ace_interact_menu_fnc_addActionToClass;

// 6. Mobile Respawn (Specific Classes only)
private _respawnAction = ["A3M_SetRespawn", "Set Mobile Respawn", "", {
    // Assign respawn points to the vehicle globally using the correct signature
    [[west, _target], BIS_fnc_addRespawnPosition] remoteExec ["call", 0, true];
    [[independent, _target], BIS_fnc_addRespawnPosition] remoteExec ["call", 0, true];

    // Mark as having a respawn so the ACE action hides itself
    _target setVariable ["A3M_HasRespawn", true, true];

    hint "Mobile Respawn Set.";
}, {
    // Only show if it hasn't been set yet
    isNil {_target getVariable "A3M_HasRespawn"}
}] call ace_interact_menu_fnc_createAction;

private _respawnClasses = [
    "B_T_APC_Tracked_01_CRV_F", "B_APC_Tracked_01_CRV_F", "B_T_VTOL_01_armed_olive_F", "B_T_VTOL_01_armed_blue_F", 
    "B_T_VTOL_01_armed_F", "B_T_VTOL_01_infantry_olive_F", "B_T_VTOL_01_infantry_blue_F", "B_T_VTOL_01_infantry_F", 
    "I_Heli_Transport_02_F", "B_Heli_Transport_03_unarmed_green_F", "B_Heli_Transport_03_F", "B_Heli_Transport_03_black_F", 
    "O_Heli_Transport_04_F", "B_Slingload_01_Medevac_F", "Land_Pod_Heli_Transport_04_medevac_F", "I_E_Van_02_medevac_F", 
    "B_Truck_01_medical_F", "I_Truck_02_medical_F"
];
{
    [_x, 0, ["ACE_MainActions", "A3M_VehicleOps"], _respawnAction, true] call ace_interact_menu_fnc_addActionToClass;
} forEach _respawnClasses;


// -------------------------------------------------------------------------
// --- ACE STATIC WEAPON ACTIONS ---
// -------------------------------------------------------------------------
private _staticClaimAction = ["A3M_ClaimStatic", "Claim Weapon", "", {
    [_target] call HG_fnc_setOwner;
    _target setVariable ["ALiVE_disableDynamicSimulation", true, true];
}, {
    isNil {_target getVariable "HG_Owner"}
}] call ace_interact_menu_fnc_createAction;
["StaticWeapon", 0, ["ACE_MainActions"], _staticClaimAction, true] call ace_interact_menu_fnc_addActionToClass;

private _staticLockAction = ["A3M_ToggleStaticLock", "Lock / Unlock Weapon", "", {
    [_target] call HG_fnc_lockOrUnlock;
}, {
    private _ownerArray = _target getVariable ["HG_Owner", []];
    (count _ownerArray > 0) && { ((_ownerArray select 0) == getPlayerUID player) || (getPlayerUID player in (_ownerArray select 3)) }
}] call ace_interact_menu_fnc_createAction;
["StaticWeapon", 0, ["ACE_MainActions"], _staticLockAction, true] call ace_interact_menu_fnc_addActionToClass;

// (ACE Interrogation Bindings Removed - Migrated to Server JIP addAction)

// -------------------------------------------------------------------------
// --- A3M INTERROGATION ACE ACTIONS ---
// -------------------------------------------------------------------------
private _actInterrogate = [
    "A3M_Interrogate_Action",          
    "Begin Interrogation",             
    "",                                
    { 
        systemChat "[A3M] ACE Action 'Begin Interrogation' clicked!";
        if (isNil "A3M_fnc_interrogateTarget") then { systemChat "[A3M] ERROR: A3M_fnc_interrogateTarget is undefined!"; };
        _this spawn A3M_fnc_interrogateTarget; 
    }, 
    { 
        side player in [west, independent] && 
        { ((vehicleVarName _target) in ["interrogation_bodybag_1", "interrogation_bodybag_2", "interrogation_bodybag_3"]) || (_target getVariable ["isInterrogationTarget", false]) }
    },    
    {},                                
    ["CIVILIAN"],                             
    [],                           
    5                                  
] call ace_interact_menu_fnc_createAction;

// Bind globally to the classnames of the objects you tested. 
// The condition block above ensures it only shows up on the specific named ones.
["Land_Bodybag_01_black_F", 0, ["ACE_MainActions"], _actInterrogate, true] call ace_interact_menu_fnc_addActionToClass;
["Land_Bodybag_01_blue_F", 0, ["ACE_MainActions"], _actInterrogate, true] call ace_interact_menu_fnc_addActionToClass;
["Land_Bodybag_01_white_F", 0, ["ACE_MainActions"], _actInterrogate, true] call ace_interact_menu_fnc_addActionToClass;
["Land_CampingTable_F", 0, ["ACE_MainActions"], _actInterrogate, true] call ace_interact_menu_fnc_addActionToClass;
["Land_WoodenTable_large_F", 0, ["ACE_MainActions"], _actInterrogate, true] call ace_interact_menu_fnc_addActionToClass;