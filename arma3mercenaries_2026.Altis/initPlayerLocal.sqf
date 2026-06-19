// plays random tracks for each player independently of eachother
execVM "arma3mercenaries\jukebox\arma3mercenaries_playRandomTracks.sqf";

// ambiant radio chatter
execVM "arma3mercenaries\jukebox\ambientRadioChatter.sqf";

execVM "scripts\HG_initPlayerLocal.sqf";
execVM "scripts\wearAllUniforms.sqf";
execVM "arma3mercenaries\briefing\initBriefing.sqf";

// player traits
player setUnitTrait ["UAVHacker",true];
player setUnitTrait ["explosiveSpecialist",true];

// A3M Client-Side Function Compilation
A3M_fnc_applyChatterEHs = compileFinal (preprocessFileLineNumbers "arma3mercenaries\speech_overhaul\fn_applyChatterEHs.sqf");
A3M_fnc_submitTicket = compileFinal (preprocessFileLineNumbers "arma3mercenaries\ticketing\fn_submitTicket.sqf");
[] execVM "arma3mercenaries\speech_overhaul\fn_initSpeechArrays.sqf";

// -------------------------------------------------------------------------
// --- A3M TICKETING SYSTEM: ESC Menu Injector (#70) ---
// -------------------------------------------------------------------------
[] spawn {
    disableSerialization;
    while {true} do {
        waitUntil { !isNull (findDisplay 49) }; // 49 is the ESC menu
        private _disp = findDisplay 49;
        
        // Inject button if not present
        if (isNull (_disp displayCtrl 7777)) then {
            private _btn = _disp ctrlCreate ["RscButtonMenu", 7777];
            _btn ctrlSetPosition [0.01 * safezoneW + safezoneX, 0.02 * safezoneH + safezoneY, 0.15 * safezoneW, 0.03 * safezoneH];
            _btn ctrlCommit 0;
            _btn ctrlSetText "A3M TICKETING SYSTEM";
            _btn ctrlSetBackgroundColor [1, 0.5, 0, 0.9]; // A3M Orange
            
            _btn ctrlAddEventHandler ["ButtonClick", {
                closeDialog 2; // Close ESC menu
                createDialog "A3M_TicketMenu"; // Open ticketing UI
                { lbAdd [7705, _x]; } forEach ["Bug", "Enhancement / Feature Request", "Comment"];
                lbSetCurSel [7705, 0];
            }];
        };
        waitUntil { isNull (findDisplay 49) };
    };
};

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


// 3. A3M HVT Satellite Tracker -> [Support & Logistics]
private _actLocateHVT = ["A3M_LocateHVT", "Palantir Gotham (Intelligence and Tracking)", "", {
    [] execVM "arma3mercenaries\tasks\fn_openHVTTrackerMenu.sqf";
}, {true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_LogisticsStore"], _actLocateHVT] call ace_interact_menu_fnc_addActionToObject;

// 4. Squad Controls -> [Squad Command]
[] execVM "arma3mercenaries\set_group_captive\groupRejoin.sqf";

private _actGrpReform = ["groupReform","Reform Squad (Reset AI)","",{execVM "arma3mercenaries\set_group_captive\squadReform.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpReform] call ace_interact_menu_fnc_addActionToObject;

private _actGrpRecall = ["groupTeleport","Recall Squad","",{execVM "arma3mercenaries\group_teleport\groupTeleport.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpRecall] call ace_interact_menu_fnc_addActionToObject;

private _actGrpStandDown = ["groupSetCaptive","Stand Down (Deactivate)","",{execVM "arma3mercenaries\set_group_captive\setGroupCaptive_proofOfConcept.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpStandDown] call ace_interact_menu_fnc_addActionToObject;

private _actGrpMobilize = ["groupRejoin","Mobilize (Reactivate)","",{execVM "arma3mercenaries\set_group_captive\groupRejoin_proofOfConcept.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpMobilize] call ace_interact_menu_fnc_addActionToObject;

private _actGrpMountTurrets6 = ["groupMountTurrets6","Quick Load (6m)","",{ [6] execVM "arma3mercenaries\set_group_captive\groupMountTurrets.sqf" },{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpMountTurrets6] call ace_interact_menu_fnc_addActionToObject;

private _actGrpMountTurrets50 = ["groupMountTurrets50","Secure Base Turrets (50m)","",{ [50] execVM "arma3mercenaries\set_group_captive\groupMountTurrets.sqf" },{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpMountTurrets50] call ace_interact_menu_fnc_addActionToObject;

private _actGrpAssemble = ["groupAssemble","Assemble Formations","",{execVM "arma3mercenaries\set_group_captive\groupRejoin.sqf"},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_SquadCommand"], _actGrpAssemble] call ace_interact_menu_fnc_addActionToObject;


// 4. Database Controls -> [Constellis Database]
A3M_fnc_initMercenary = compileFinal (preprocessFileLineNumbers "arma3mercenaries\mercenaries\fn_initMercenary.sqf");
A3M_fnc_initSupplyDrop = compileFinal (preprocessFileLineNumbers "arma3mercenaries\supply_drops\fn_initSupplyDrop.sqf");

A3M_fnc_openPlayerCard = compileFinal (preprocessFileLineNumbers "arma3mercenaries\player_profile\fn_openPlayerCard.sqf");
A3M_fnc_openSquadDossier = compileFinal (preprocessFileLineNumbers "arma3mercenaries\player_profile\fn_openSquadDossier.sqf");
A3M_fnc_openFieldManual = compileFinal (preprocessFileLineNumbers "arma3mercenaries\player_profile\fn_openFieldManual.sqf");
A3M_fnc_receiveProfileData = compileFinal (preprocessFileLineNumbers "arma3mercenaries\player_profile\fn_receiveProfileData.sqf");
[] execVM "arma3mercenaries\player_profile\fn_initPedometer.sqf";

private _actPlayerCard = ["a3m_playerCard","View Player Dossier","",{[] call A3M_fnc_openPlayerCard},{true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "A3M_ConstellisDB"], _actPlayerCard] call ace_interact_menu_fnc_addActionToObject;

A3M_fnc_openSquadDossier = compileFinal (preprocessFileLineNumbers "arma3mercenaries\player_profile\fn_openSquadDossier.sqf");
A3M_fnc_receiveSquadDossierData = compileFinal (preprocessFileLineNumbers "arma3mercenaries\player_profile\fn_receiveSquadDossierData.sqf");

A3M_fnc_openLeaderboard = compileFinal (preprocessFileLineNumbers "arma3mercenaries\leaderboard\fn_openLeaderboard.sqf");
A3M_fnc_receiveLeaderboardData = compileFinal (preprocessFileLineNumbers "arma3mercenaries\leaderboard\fn_receiveLeaderboardData.sqf");
A3M_fnc_openTargetPlayerCard = compileFinal (preprocessFileLineNumbers "arma3mercenaries\leaderboard\fn_openTargetPlayerCard.sqf");

// Leaderboard action removed from self-interact menu to reduce clutter (Issue #??)
// Access is now solely through the Player Dossier UI.

// Virtual Barracks Client Functions
A3M_fnc_deployMercenary = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_deployMercenary.sqf");
A3M_fnc_stowMercenary = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_stowMercenary.sqf");

A3M_fnc_openShadowOpsDialog = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_openShadowOpsDialog.sqf");
A3M_fnc_receiveShadowOpsRoster = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_receiveShadowOpsRoster.sqf");
A3M_fnc_onShadowOpsMissionSelected = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_onShadowOpsMissionSelected.sqf");
A3M_fnc_onShadowOpsPlanChanged = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_onShadowOpsPlanChanged.sqf");
A3M_fnc_shadowOpsAddMerc = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_shadowOpsAddMerc.sqf");
A3M_fnc_shadowOpsRemoveMerc = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_shadowOpsRemoveMerc.sqf");
A3M_fnc_shadowOpsAddAsset = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_shadowOpsAddAsset.sqf");
A3M_fnc_shadowOpsRemoveAsset = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_shadowOpsRemoveAsset.sqf");
A3M_fnc_shadowOpsDispatch = compileFinal (preprocessFileLineNumbers "arma3mercenaries\barracks\fn_shadowOpsDispatch.sqf");

// 5. Survival Operations -> [Camp]
private _actSetCamp = [
    "A3M_SetCamp",
    "Set Camp (Advance Time)",
    "",
    {
        private _skipHours = missionNamespace getVariable ["A3M_Camping_SkipHours", 6];
        private _restoreFatigue = missionNamespace getVariable ["A3M_Camping_RestoreFatigue", true];
        
        private _titleMsg = format ["Setting Camp... Advancing %1 Hours.", _skipHours];
        if (_restoreFatigue) then { _titleMsg = _titleMsg + " Restoring Fatigue."; };
        
        titleText [_titleMsg, "BLACK", 2];
        
        if (_restoreFatigue) then { player setFatigue 0; };
        [_skipHours] remoteExecCall ["skipTime", 2];
        
        [] spawn {
            sleep 3;
            titleFadeOut 2;
        };
    },
    { missionNamespace getVariable ["A3M_Camping_Enabled", true] }
] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions"], _actSetCamp] call ace_interact_menu_fnc_addActionToObject;

// -------------------------------------------------------------------------
// --- A3M GLOBAL VENDOR ACE ACTIONS (JIP & Respawn Proof) ---
// -------------------------------------------------------------------------

// 1. A3M Barracks Kiosk
private _actBarracks = [
    "a3m_access_barracks",
    "Access Mercenary Barracks",
    "",
    { [true] call A3M_fnc_openSquadDossier; }, 
    { _target getVariable ["A3M_isBarracks", false] }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _actBarracks, true] call ace_interact_menu_fnc_addActionToClass;
["Thing", 0, ["ACE_MainActions"], _actBarracks, true] call ace_interact_menu_fnc_addActionToClass;
["Building", 0, ["ACE_MainActions"], _actBarracks, true] call ace_interact_menu_fnc_addActionToClass;
["ReammoBox_F", 0, ["ACE_MainActions"], _actBarracks, true] call ace_interact_menu_fnc_addActionToClass;

// 2. A3M Quartermaster Hub (Overarching UI)
A3M_fnc_openQuartermasterHub = compileFinal (preprocessFileLineNumbers "arma3mercenaries\a3m_blackmarket\fn_openQuartermasterHub.sqf");
A3M_fnc_openBlackMarket = compileFinal (preprocessFileLineNumbers "arma3mercenaries\a3m_blackmarket\fn_openBlackMarket.sqf");
A3M_fnc_drawNav = compileFinal (preprocessFileLineNumbers "arma3mercenaries\a3m_blackmarket\fn_drawNav.sqf");

private _actQuartermaster = [
    "A3M_QuartermasterHub",
    "Access Quartermaster",
    "",
    { [_target, player] call A3M_fnc_openQuartermasterHub; },
    { _target getVariable ["A3M_isQuartermaster", false] }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _actQuartermaster, true] call ace_interact_menu_fnc_addActionToClass;
["Thing", 0, ["ACE_MainActions"], _actQuartermaster, true] call ace_interact_menu_fnc_addActionToClass;
["Building", 0, ["ACE_MainActions"], _actQuartermaster, true] call ace_interact_menu_fnc_addActionToClass;
["ReammoBox_F", 0, ["ACE_MainActions"], _actQuartermaster, true] call ace_interact_menu_fnc_addActionToClass;

// Legacy A3M Black Market (Direct Armory Access) - CASH
private _actBlackMarket = [
    "A3M_BlackMarket",
    "Access Black Market Armory (Cash)",
    "",
    { [false] spawn A3M_fnc_openBlackMarket; },
    { _target getVariable ["A3M_isBlackMarket", false] }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _actBlackMarket, true] call ace_interact_menu_fnc_addActionToClass;
["Thing", 0, ["ACE_MainActions"], _actBlackMarket, true] call ace_interact_menu_fnc_addActionToClass;
["Building", 0, ["ACE_MainActions"], _actBlackMarket, true] call ace_interact_menu_fnc_addActionToClass;
["ReammoBox_F", 0, ["ACE_MainActions"], _actBlackMarket, true] call ace_interact_menu_fnc_addActionToClass;

// Legacy A3M Black Market (Direct Armory Access) - DEBIT CARD
private _actBlackMarketDebit = [
    "A3M_BlackMarket_Debit",
    "Access Black Market Armory (Debit Card)",
    "",
    { [true] spawn A3M_fnc_openBlackMarket; },
    { _target getVariable ["A3M_isBlackMarket", false] }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _actBlackMarketDebit, true] call ace_interact_menu_fnc_addActionToClass;
["Thing", 0, ["ACE_MainActions"], _actBlackMarketDebit, true] call ace_interact_menu_fnc_addActionToClass;
["Building", 0, ["ACE_MainActions"], _actBlackMarketDebit, true] call ace_interact_menu_fnc_addActionToClass;
["ReammoBox_F", 0, ["ACE_MainActions"], _actBlackMarketDebit, true] call ace_interact_menu_fnc_addActionToClass;

// 3. HG Garage & Vehicle Shops
private _actGarage = [ (localize "STR_HG_GARAGE"), (localize "STR_HG_GARAGE"), "HG\UI\Icons\garage.paa", {
    private _shop = _target getVariable ["A3M_isGarage", "HG_DefaultGarage"];
    [_shop] call HG_fnc_dialogOnLoadGarage;
}, { (alive player) && !dialog && ((_target getVariable ["A3M_isGarage", ""]) != "") }, {},[],[],3 ] call ace_interact_menu_fnc_createAction; 

private _actParkVehicle = [ (localize "STR_HG_GARAGE_PARK"), (localize "STR_HG_GARAGE_PARK"), "HG\UI\Icons\garage.paa", {
    private _shop = _target getVariable ["A3M_isGarage", "HG_DefaultGarage"];
    [_shop] call HG_fnc_storeVehicleClient;
}, { (alive player) && !dialog && ((_target getVariable ["A3M_isGarage", ""]) != "") }, {},[],[],3 ] call ace_interact_menu_fnc_createAction; 

private _actDealer = [ (localize "STR_HG_DEALER"), (localize "STR_HG_DEALER"), "HG\UI\Icons\car.paa", {
    private _shop = _target getVariable ["A3M_isDealer", "HG_DefaultDealer"];
    [_target, player, 0, _shop] call HG_fnc_dialogOnLoadDealer;
}, { (alive player) && !dialog && ((_target getVariable ["A3M_isDealer", ""]) != "") }, {},[],[],3 ] call ace_interact_menu_fnc_createAction;  

private _actVehiclesShop = [ (localize "STR_HG_VEHICLES_SHOP"), (localize "STR_HG_VEHICLES_SHOP"), "HG\UI\Icons\car.paa", { 
    params ["_target", "_caller"]; 
    private _shop = _target getVariable ["A3M_isVehiclesShop", "HG_DefaultShop"];
    [_shop, _target, _caller] call HG_fnc_dialogOnLoadVehicles; 
}, { (alive player) && !dialog && ((_target getVariable ["A3M_isVehiclesShop", ""]) != "") }, {},[],[],3 ] call ace_interact_menu_fnc_createAction; 

// 4. HG Gear, Items & Traders
private _actTrader = [ (localize "STR_HG_TRADER"), (localize "STR_HG_TRADER"), "HG\UI\Icons\money.paa", {
    private _shop = _target getVariable ["A3M_isTrader", "HG_DefaultTrader"];
    [_target, player, 0, _shop] call HG_fnc_dialogOnLoadTrader;
}, { (alive player) && !dialog && ((_target getVariable ["A3M_isTrader", ""]) != "") }, {},[],[],3 ] call ace_interact_menu_fnc_createAction;   

private _actGearShop = [ (localize "STR_HG_GEAR_SHOP"), (localize "STR_HG_GEAR_SHOP"), "HG\UI\Icons\money.paa", {
    private _shop = _target getVariable ["A3M_isGearShop", "HG_DefaultShop"];
    [_shop] call HG_fnc_dialogOnLoadGear;
}, { (alive player) && !dialog && ((_target getVariable ["A3M_isGearShop", ""]) != "") }, {},[],[],3 ] call ace_interact_menu_fnc_createAction; 

private _actItemsShop = [ (localize "STR_HG_ITEMS_SHOP"), (localize "STR_HG_ITEMS_SHOP"), "HG\UI\Icons\money.paa", { 
    params ["_target", "_caller", "_params"]; 
    private _shop = _target getVariable ["A3M_isItemsShop", "HG_DefaultShop"];
    [_shop, "HG_Items"] call HG_fnc_dialogOnLoadItems; 
}, { (alive player) && !dialog && ((_target getVariable ["A3M_isItemsShop", ""]) != "") }, {},[],[],3 ] call ace_interact_menu_fnc_createAction;   

// 5. HG ATM
private _actATM = [ (localize "STR_HG_ATM"), (localize "STR_HG_ATM"), "HG\UI\Icons\atm.paa", {
    call HG_fnc_dialogOnLoadATM;
}, { (alive player) && !dialog && (_target getVariable ["A3M_isATM", false]) }, {},[],[],3 ] call ace_interact_menu_fnc_createAction;

// Bind all HG interactions globally
{
    private _class = _x;
    {
        [_class, 0, ["ACE_MainActions"], _x, true] call ace_interact_menu_fnc_addActionToClass;
    } forEach [_actGarage, _actParkVehicle, _actDealer, _actVehiclesShop, _actTrader, _actGearShop, _actItemsShop, _actATM];
} forEach ["CAManBase", "Thing", "Building", "ReammoBox_F"];


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

// ------------------------------------------
// --- A3M CUSTOM VEHICLE OWNERSHIP LOGIC ---
// ------------------------------------------
A3M_fnc_dialogOnLoadGiftVehicle = {
    params ["_vehicle"];
    A3M_GIFT_VEHICLE = _vehicle;
    createDialog "A3M_GiftVehicle";
    
    disableSerialization;
    private _combo = (findDisplay 99800) displayCtrl 9980;
    lbClear _combo;
    A3M_GIFT_PLAYERS = [];
    
    // Get all players except headless clients and self
    private _all = (allPlayers - entities "HeadlessClient_F" - [player]);
    
    if ((count _all) > 0) then {
        {
            private _ind = _combo lbAdd format["%1 - %2", name _x, getPlayerUID _x];
            _combo lbSetData [_ind, getPlayerUID _x];
            _combo lbSetValue [_ind, _forEachIndex];
            A3M_GIFT_PLAYERS pushBack _x;
        } forEach _all;
        ((findDisplay 99800) displayCtrl 9981) ctrlEnable true;
    } else {
        _combo lbAdd "No players available";
        ((findDisplay 99800) displayCtrl 9981) ctrlEnable false;
    };
    _combo lbSetCurSel 0;
};

A3M_fnc_giftVehicleConfirm = {
    disableSerialization;
    private _combo = (findDisplay 99800) displayCtrl 9980;
    private _sel = lbCurSel _combo;
    if (_sel == -1) exitWith {};
    
    private _targetPlayer = A3M_GIFT_PLAYERS select (_combo lbValue _sel);
    private _targetName = name _targetPlayer;
    private _targetUID = getPlayerUID _targetPlayer;
    private _vehicle = A3M_GIFT_VEHICLE;
    
    closeDialog 0;
    
    [_vehicle, _targetPlayer, _targetName, _targetUID] spawn {
        params ["_vehicle", "_targetPlayer", "_targetName", "_targetUID"];
        private _msg = format ["Are you sure you want to give this vehicle away for free to %1?", _targetName];
        private _result = [_msg, "Confirm Gift Vehicle", true, true] call BIS_fnc_guiMessage;
        
        if (_result) then {
            // Transfer ownership completely
            private _newOwnerArray = [_targetUID, _targetName, side _targetPlayer, [_targetUID]];
            _vehicle setVariable ["HG_Owner", _newOwnerArray, true];
            
            // Notify giver
            private _a3mMsg = format ["<t align='center'><t font='RobotoCondensedBold' size='0.8' color='#00FF00'>VEHICLE GIFTED</t><br/><t font='PuristaMedium' size='0.6' color='#FFFFFF'>You gave the vehicle to %1.</t></t>", _targetName];
            [_a3mMsg, -1, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
            
            // Notify receiver
            private _recvMsg = format ["<t align='center'><t font='RobotoCondensedBold' size='0.8' color='#00FF00'>GIFT RECEIVED</t><br/><t font='PuristaMedium' size='0.6' color='#FFFFFF'>%1 gifted you a vehicle.</t></t>", name player];
            [_recvMsg, -1, 0.1, 5, 0.5, 0, 789] remoteExec ["BIS_fnc_dynamicText", _targetPlayer];
        };
    };
};

A3M_fnc_renounceOwnershipConfirm = {
    params ["_target"];
    private _result = ["Are you sure you want to completely renounce ownership of this vehicle? Anyone will be able to claim it.", "Confirm Renounce Ownership", true, true] call BIS_fnc_guiMessage;
    if (_result) then {
        _target setVariable ["HG_Owner", nil, true];
        private _a3mMsg = "<t align='center'><t font='RobotoCondensedBold' size='0.8' color='#FF0000'>OWNERSHIP RENOUNCED</t><br/><t font='PuristaMedium' size='0.6' color='#FFFFFF'>Vehicle is now unclaimed.</t></t>";
        [_a3mMsg, -1, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;
    };
};

// 3.5. Gift Vehicle
private _giftVehicleAction = ["A3M_GiftVehicleAction", "Gift Vehicle", "", {
    [_target] call A3M_fnc_dialogOnLoadGiftVehicle;
}, {
    private _ownerArray = _target getVariable ["HG_Owner", []];
    (count _ownerArray > 0) && { ((_ownerArray select 0) == getPlayerUID player) }
}] call ace_interact_menu_fnc_createAction;
["LandVehicle", 0, ["ACE_MainActions", "A3M_VehicleOps"], _giftVehicleAction, true] call ace_interact_menu_fnc_addActionToClass;
["Air", 0, ["ACE_MainActions", "A3M_VehicleOps"], _giftVehicleAction, true] call ace_interact_menu_fnc_addActionToClass;
["Ship", 0, ["ACE_MainActions", "A3M_VehicleOps"], _giftVehicleAction, true] call ace_interact_menu_fnc_addActionToClass;

// 3.6. Renounce Ownership
private _renounceAction = ["A3M_RenounceOwnershipAction", "Renounce Ownership", "", {
    [_target] spawn A3M_fnc_renounceOwnershipConfirm;
}, {
    private _ownerArray = _target getVariable ["HG_Owner", []];
    (count _ownerArray > 0) && { ((_ownerArray select 0) == getPlayerUID player) }
}] call ace_interact_menu_fnc_createAction;
["LandVehicle", 0, ["ACE_MainActions", "A3M_VehicleOps"], _renounceAction, true] call ace_interact_menu_fnc_addActionToClass;
["Air", 0, ["ACE_MainActions", "A3M_VehicleOps"], _renounceAction, true] call ace_interact_menu_fnc_addActionToClass;
["Ship", 0, ["ACE_MainActions", "A3M_VehicleOps"], _renounceAction, true] call ace_interact_menu_fnc_addActionToClass;

// 4. Flip Vehicle (ACE Contextual)
private _flipAction = ["A3M_FlipVehicle", "Flip Vehicle", "", {
    if (locked _target > 1) then {
        private _message = "<t color='#FF0000' size='0.6'>Flip Failed</t><br/><t size='0.5'>You must unlock this vehicle first.</t>";
        [_message, 0, 0.8, 3, 0, 0, 890] spawn BIS_fnc_dynamicText;
        playSound "FD_Target_PopDown_Large_F";
    } else {
        private _normalVec = surfaceNormal getPos _target;
        if (!local _target) then {
            [_target, _normalVec] remoteExec ["setVectorUp", _target];
            [_target, [getPosATL _target select 0, getPosATL _target select 1, 0]] remoteExec ["setPosATL", _target];
        } else {
            _target setVectorUp _normalVec;
            _target setPosATL [getPosATL _target select 0, getPosATL _target select 1, 0];
        };
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
    [west, _target] remoteExecCall ["BIS_fnc_addRespawnPosition", 0, true];
    [independent, _target] remoteExecCall ["BIS_fnc_addRespawnPosition", 0, true];

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

// -------------------------------------------------------------------------
// --- A3M PLAYER DOSSIER HOTKEY ---
// -------------------------------------------------------------------------
[] spawn {
    waitUntil { !isNull findDisplay 46 };
    (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
        // DIK Code 25 is 'P'. Ensure no modifiers are pressed to prevent conflicts with combinations.
        if (_key == 25 && !_shift && !_ctrl && !_alt) then {
            if (isNull (findDisplay 7020) && isNull (findDisplay 7030)) then {
                [] call A3M_fnc_openPlayerCard;
            };
            // Return true to consume the keypress and override default 'P' (Scoreboard) behavior
            true
        } else {
            false
        };
    }];
};

// -------------------------------------------------------------------------
// --- A3M CORPSE LOOTING (GRAD-FORTIFICATIONS) ---
// -------------------------------------------------------------------------
private _actLootForts = [
    "A3M_LootFortifications",
    "Fortifications",
    ([] call grad_fortifications_fnc_getModuleRoot) + "\data\sandbags.paa",
    {
        [grad_fortifications_fnc_loadVehicleDialog, [_target, player]] call CBA_fnc_execNextFrame;
    },
    {
        !alive _target && {count ((_target getVariable ["grad_fortifications_myFortsHash", [[],0] call CBA_fnc_hashCreate]) select 1) > 0}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _actLootForts, true] call ace_interact_menu_fnc_addActionToClass;

// -------------------------------------------------------------------------
// --- A3M AI SPEECH OVERHAUL (PHASE 1: STOPGAP MUTE) ---
// -------------------------------------------------------------------------
// The absolute nuclear option: Completely disables the native Arma 3 radio protocol.
// This prevents AI from generating any text or audio callouts globally.
enableSentences true;
enableRadio true;

// -------------------------------------------------------------------------
// --- A3M DEEP STAT TRACKING: Engineer Score (#65) ---
// -------------------------------------------------------------------------
["grad_fortifications_onPlace", {
    params ["_unit", "_fortification", "_vehicle"];
    if (_unit != player) exitWith {};
    
    // We send to server so we don't have to duplicate the dbSetSecure block on client
    [player, "Engineer_Score_Total"] remoteExecCall ["A3M_fnc_serverIncrementStat", 2];
}] call CBA_fnc_addEventHandler;

// -------------------------------------------------------------------------
// --- A3M DEEP STAT TRACKING: ACE Medical Revives ("The Lifesaver") ---
// -------------------------------------------------------------------------
["ace_medical_treatment_onTreatment", {
    params ["_caller", "_target", "_selectionName", "_className", "_itemUser", "_usedItem"];
    
    if (_caller != player) exitWith {}; // Only track local player actions
    if (_caller == _target) exitWith {}; // Exclude self-treatment
    
    // Only track major interventions on unconscious/cardiac arrest patients
    private _isUnconscious = _target getVariable ["ACE_isUnconscious", false];
    private _inArrest = _target getVariable ["ace_medical_inCardiacArrest", false];
    
    if (_isUnconscious || _inArrest) then {
        if (_className in ["Epinephrine", "CPR", "BloodIV", "BloodIV_500", "BloodIV_250", "PlasmaIV", "SalineIV", "PersonalAidKit", "SurgicalKit"]) then {
            private _targetName = name _target;
            if (!isPlayer _target) then {
                private _cfgName = getText(configFile >> "CfgVehicles" >> typeOf _target >> "displayName");
                if (_targetName == "" || _targetName == "Error: No unit") then { _targetName = _cfgName; };
            };
            
            [player, _targetName, _className] remoteExecCall ["A3M_fnc_serverLogRevive", 2];
        };
    };
}] call CBA_fnc_addEventHandler;