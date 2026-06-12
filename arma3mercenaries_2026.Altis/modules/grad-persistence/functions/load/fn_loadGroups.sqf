/*


---

# Grad-Persistence Group Saves
### Enhanced By: BrianV1981

## Summary of Changes and Logic

### Objective
The objective is to create a persistent system for saving and loading AI units linked to specific player groups in Arma 3. The system assigns unique identifiers to both AI units and player groups based on the player's UID, ensuring that these identifiers are consistently saved and reloaded across game sessions.

### Key Concepts

1. **AI Unit ID (`arma3mercenaries_aiUnit`)**:
   - **Purpose**: To uniquely identify each AI unit associated with a player.
   - **Format**: `arma3mercenaries_aiUnit_*uniqueUnitID*_*playerUID*`.
   - **Logic**: Generated during the unit creation process, ensuring each AI unit has a distinct ID tied to the player who created it.

2. **Group ID (`arma3mercenaries_groupID`)**:
   - **Purpose**: To uniquely identify a group of AI units associated with a player.
   - **Format**: `arma3mercenaries_groupID_*playerUID*`.
   - **Logic**: Generated once for each player's group, ensuring that all units within that group are correctly associated with the player. This ID is used to restore groups upon loading.

3. **AI Unit Loadout**:
   - **Purpose**: To save and restore the loadout (inventory) of AI units.
   - **Logic**: The AI unit's loadout is saved using the `getUnitLoadout` command and stored in the mission namespace. During loading, the saved loadout is retrieved and applied to the unit using `setUnitLoadout`.

### Implementation Details

#### 1. **Unit Creation Script**
   - **Logic**:
     - When an AI unit is created, it is assigned an `arma3mercenaries_aiUnit` variable, which includes a unique identifier and the player’s UID.
     - It also receives an `arma3mercenaries_groupID` variable based solely on the player’s UID.
   - **Purpose**: Ensures that each unit is correctly tagged with identifiers that can be used for saving and reloading.

#### 2. **Saving Script**
   - **Logic**:
     - The script checks whether the group leader (the player) has a valid `arma3mercenaries_groupID`.
     - During the save process, the group of AI units is processed, and their relevant data, including their AI Unit ID, Group ID, and loadout, is saved.
   - **Purpose**: Ensures that all relevant data for units and groups, including loadouts, is stored for later retrieval, preserving the structure, relationships, and state of each unit.

#### 3. **Loading Script**
   - **Logic**:
     - The script retrieves saved groups and units based on their saved data.
     - Each unit is reassigned its `arma3mercenaries_aiUnit`, `arma3mercenaries_groupID`, and loadout, ensuring they are placed back into their correct group with their original inventory.
	- Each unit is reassigned the `ALiVE_disableDynamicSimulation` and `Vcm_Disable` variables, disableing them from VCOM and ALiVE
   - **Purpose**: Ensures that when the mission is reloaded, all units and groups are restored to their original state, maintaining consistency across sessions, including their equipment.

### Rationale Behind the Logic

- **Consistency**: By tying both the AI Unit ID and Group ID to the player's UID, and saving the loadout, the relationship between the player, their AI units, and their groups remains consistent across save/load cycles.
- **Simplicity**: The format and assignment of IDs, along with the handling of loadouts, are straightforward, making it easier to debug and manage within the mission.
- **Persistence**: The use of Grad Persistence functions ensures that all relevant data, including loadouts, is saved and reloaded correctly, minimizing the risk of data loss or corruption.

---

## Installation Instructions

### 1. **Setting Up `CfgGradPersistence`**
   
Add the following configuration to your mission's `description.ext` file:

```cpp
class CfgGradPersistence {
    missionTag = "my_persistent_mission";
    loadOnMissionStart = 1;
    missionWaitCondition = "true";
    playerWaitCondition = "true";

    saveUnits = 3;
    saveVehicles = 3;
    saveContainers = 3;
    saveStatics = 0;
    saveGradFortificationsStatics = 3;

    savePlayerInventory = 1;
    savePlayerDamage = 1;
    savePlayerPosition = 1;
    savePlayerMoney = 1;

    saveMarkers = 3;
    saveTasks = 0;
    saveTriggers = 0;
    saveTeamAccounts = 0;
    saveTimeAndDate = 0;

    class customVariables {
        class aiUnit {
            varName = "arma3mercenaries_aiUnit";
            varNamespace = "unit";
            public = 1;  // Broadcast across the network
        };
        class groupID {
            varName = "arma3mercenaries_groupID";
            varNamespace = "unit";
            public = 1;
        };
    };
};
```

### 2. **Setting Up `initPlayerLocal.sqf`**

In your mission's `initPlayerLocal.sqf`, add the following:

```sqf
// Get the player's UID
private _playerUID = getPlayerUID player;

// Create the group ID using the player's UID
private _groupID = format ["arma3mercenaries_groupID_%1", _playerUID];

// Assign the group ID to the player
player setVariable ["arma3mercenaries_groupID", _groupID, true];
```

### 3. **Reassign AI Units to Player's Group**

To ensure AI units rejoin the player's group upon loading:

```sqf
{
    private _unit = _x;
    if (!isPlayer _unit) then {
        [_unit] joinSilent group player;
    };
} forEach (allUnits select {
    _x getVariable ["arma3mercenaries_groupID", ""] == player getVariable ["arma3mercenaries_groupID", ""]
});
```

### 4. **Updating the Save Script**

Ensure your save script captures the `arma3mercenaries_groupID`, `arma3mercenaries_aiUnit`, and loadout for each unit:

```cpp
// Logic to save groups and units based on the variables assigned
// Include saving the loadout using `getUnitLoadout` and storing it under the "inventory" key
```

### 5. **Updating the Load Script**

Ensure your load script reassigns the saved `arma3mercenaries_groupID`, `arma3mercenaries_aiUnit`, and loadout to the appropriate units:

```cpp
// Logic to load and reassign the saved variables
// Ensure the loadout is retrieved using the "inventory" key and applied using `setUnitLoadout`
```

---


*/

#include "script_component.hpp"

if (!isServer) exitWith {};

private _missionTag = [] call grad_persistence_fnc_getMissionTag;
private _groupsTag = _missionTag + "_groups";

// --- A.I.M. v812+ Architecture: SQLite Per-Entity Loading ---
private _countKey = format ["%1_COUNT", _groupsTag];
private _dbCount = [_countKey, -1, false] call A3M_fnc_dbGetSecure;

private _groupsData = [];

if (_dbCount > -1) then {
    // New Iterative Architecture
    for "_i" from 0 to (_dbCount - 1) do {
        private _uniqueEntityKey = format ["%1_grp_%2", _groupsTag, _i];
        // Fetch group array [side, [units], [vars], ownerUID] from SQLite
        private _entityData = [_uniqueEntityKey, [], false] call A3M_fnc_dbGetSecure;
        
        if (count _entityData > 0) then {
            _groupsData pushBack _entityData;
        };
    };
};

{
    _x params ["_rawGroupSide","_thisGroupUnits","_thisGroupVars"];
    
    // --- PHASE 8 DESANITIZATION: Side Reconstruction ---
    private _thisGroupSide = switch (_rawGroupSide) do {
        case "WEST": { WEST };
        case "EAST": { EAST };
        case "GUER": { GUER };
        case "CIVILIAN": { CIVILIAN };
        default { sideUnknown };
    };
    
    private _thisGroup = createGroup _thisGroupSide;

    {
        // --- PHASE 10: FLAT ARRAY OVERHAUL ---
        // [0:type, 1:posASL, 2:dir, 3:damage, 4:aiUnitID, 5:groupID, 6:inventory, 7:vars, 8:varName]
        _x params [
            ["_type", ""],
            ["_posASL", [0,0,0]],
            ["_dir", 0],
            ["_damage", 0],
            ["_aiUnitID", ""],
            ["_groupID", ""],
            ["_loadout", []],
            ["_vars", []],
            ["_vehVarName", ""]
        ];

        // Fetch DB early to prevent ACE from caching a generic name
        private _mercProfile = createHashMap;
        private _name = "";
        private _firstName = "";
        private _lastName = "";
        private _cash = 0;

        if (_aiUnitID != "") then {
            _mercProfile = [format["A3M_MERC_%1", _aiUnitID], createHashMap, true] call A3M_fnc_dbGetSecure;
            _name = _mercProfile getOrDefault ["Name", ""];
            if (_name != "") then {
                private _parts = _name splitString " ";
                _firstName = if (count _parts > 0) then { _parts select 0 } else { _name };
                _lastName = if (count _parts > 1) then { _parts select 1 } else { "" };
            };
            _cash = _mercProfile getOrDefault ["CashCarried", 0];
            if (_cash isEqualType "") then { _cash = parseNumber _cash; };
        };

        private _thisUnit = objNull;
        private _editorVehicleFound = false;
        if (_vehVarName != "") then {
            // editor-placed object that already exists
            private _editorVehicle = call compile _vehVarName;
            if (!isNil "_editorVehicle") then {
                _thisUnit = _editorVehicle;
                _editorVehicleFound = true;
            };
        };

        if (!_editorVehicleFound) then {
            // A3M: Inject ACE names into the init string so they are applied on the exact frame of creation
            private _initString = if (_name != "") then {
                format["this setVariable ['ACE_Name', '%1', true]; this setVariable ['ACE_name', '%1', true]; this setVariable ['ace_name', '%1', true]; A3M_TEMP_SPAWN_UNIT = this;", _name]
            } else {
                "A3M_TEMP_SPAWN_UNIT = this;"
            };
            
            _type createUnit [[0,0,0], _thisGroup, _initString];
            _thisUnit = A3M_TEMP_SPAWN_UNIT;

            if (_vehVarName != "") then {
                [_thisUnit,_vehVarName] remoteExec ["setVehicleVarName",0,_thisUnit];
            };
        };

        // A3M: Synchronous variable assignments before the frame ends
        if (_name != "") then {
            _thisUnit setVariable ["ACE_Name", _name, true];
            _thisUnit setVariable ["ACE_name", _name, true];
            _thisUnit setVariable ["ace_name", _name, true];
            [_thisUnit, [_name, _firstName, _lastName]] remoteExecCall ["setName", 0, _thisUnit];
        };
        
        if (_cash > 0) then {
            _thisUnit setVariable ["A3M_LoadedCash", _cash, true];
        };

        [{!isNull (_this select 0)}, {
            params ["_thisUnit", "_posASL", "_dir", "_damage", "_aiUnitID", "_groupID", "_loadout", "_vars"];

            _thisUnit setDir _dir;
            _thisUnit setPosASL _posASL;
            _thisUnit setDamage _damage;

            // Reapply the AI Unit ID and Group ID variables
            _thisUnit setVariable ["arma3mercenaries_aiUnit", _aiUnitID, true];
            _thisUnit setVariable ["arma3mercenaries_groupID", _groupID, true];
			_thisUnit setVariable ["ALiVE_disableDynamicSimulation", true, true];    
            _thisUnit setVariable ["Vcm_Disable", true, true];   

            // Apply the saved loadout to the unit
            if (count _loadout > 0) then {
                _thisUnit setUnitLoadout [_loadout, false];
            } else {
                diag_log format ["Vasquez/log: ERROR: [arma3mercenaries_loadScript] Invalid or missing loadout for unit %1", _thisUnit];
            };

            // --- A3M: DEACTIVATE AI ON LOAD (Vanilla SQF Server Guard — Layer 1) ---
            _thisUnit setCaptive true;
            _thisUnit allowDamage false;
            _thisUnit disableAI "ALL";
            _thisUnit setVariable ["A3M_AwaitingActivation", true, true];

            [_vars,_thisUnit] call FUNC(loadObjectVars);
        }, [_thisUnit, _posASL, _dir, _damage, _aiUnitID, _groupID, _loadout, _vars]] call CBA_fnc_waitUntilAndExecute;

    } forEach _thisGroupUnits;

    [_thisGroupVars,_thisGroup] call FUNC(loadObjectVars);

} forEach _groupsData;

// --- A.I.M. v812+ Architecture: Delete SQLite Killed Units ---
private _killedVarnamesKey = format ["%1_killedVarnames", _missionTag];
private _killedVarnames = [_killedVarnamesKey, [[],[],[]]] call A3M_fnc_dbGetSecure;
private _killedUnitsVarnames = _killedVarnames param [0,[]];

{
    private _editorVehicle = call compile _x;
    if (!isNil "_editorVehicle") then {deleteVehicle _editorVehicle};
} forEach _killedUnitsVarnames;
