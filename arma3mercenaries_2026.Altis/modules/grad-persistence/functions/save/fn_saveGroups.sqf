/*  Saves groups in format:
*   [[side of group, unitsData],[side of group, unitsData],[...]]
*
*   unitsData:
*   [unit hash, unit hash, unit hash, [...]]
*/


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

params [["_area",false],["_allVariableClasses",[]]];

private _allGroupsVariableClasses = _allVariableClasses select {
    ([_x,"varNamespace",""] call BIS_fnc_returnConfigEntry) == "group"
};

private _allUnitsVariableClasses = _allVariableClasses select {
    ([_x,"varNamespace",""] call BIS_fnc_returnConfigEntry) == "unit"
};

if (_area isEqualType []) then {
    _area params ["_center","_a","_b",["_angle",0],["_isRectangle",false],["_c",-1]];
    if (isNil "_b") then {_b = _a};
    _area = [_center,_a,_b,_angle,_isRectangle,_c];
};

private _missionTag = [] call FUNC(getMissionTag);
private _groupsTag = _missionTag + "_groups";
private _foundUnitsVarnames = GVAR(allFoundVarNames) select 0;

private _allGroups = allGroups;
private _saveGroupsMode = [missionConfigFile >> "CfgGradPersistence", "saveUnits", 1] call BIS_fnc_returnConfigEntry;

// A.I.M. v812+ Architecture: DB Index Tracking
private _savedGroupsCount = 0;

{
    private _thisGroup = _x;
    
    // --- PHASE 8 SANITIZATION: Side Stringification ---
    // Stringify the side to prevent unquoted token crash (e.g. WEST -> "WEST")
    private _thisGroupData = [str (side _x),[],[]];
    private _thisUnitsData = _thisGroupData select 1;

    // Generate a Group ID using the player's UID (if the group leader is a player)
    private _groupOwner = leader _thisGroup;
    private _groupOwnerUID = _groupOwner getVariable ["arma3mercenaries_groupID", ""];

    if (!isNil "_groupOwnerUID" && {_groupOwnerUID != ""}) then {
        _thisGroupData pushBack _groupOwnerUID; // Store the group ID in the group's data

        {
            private _thisUnit = _x;

            if (
                !(isPlayer _thisUnit) &&
                {!(isNull _thisUnit)} &&
                {alive _thisUnit} &&
                {!([_thisUnit] call FUNC(isBlacklisted))} &&
                {!((group _thisUnit) getVariable [QGVAR(isExcluded),false])} &&
                {
                    _saveGroupsMode == 2 ||
                    (_thisUnit getVariable [QGVAR(isEditorObject),false]) isEqualTo (_saveGroupsMode == 1)
                } &&
                {if (_area isEqualType false) then {true} else {_thisUnit inArea _area}}
            ) then {

                // --- PHASE 10: FLAT ARRAY OVERHAUL ---
                // [0:type, 1:posASL, 2:dir, 3:damage, 4:aiUnitID, 5:groupID, 6:inventory, 7:vars, 8:varName]

                private _vehVarName = vehicleVarName _thisUnit;
                if (_vehVarName != "") then {
                    _foundUnitsVarnames deleteAt (_foundUnitsVarnames find _vehVarName);
                };

                private _thisUnitData = [
                    typeOf _thisUnit,
                    getPosASL _thisUnit,
                    getDir _thisUnit,
                    damage _thisUnit,
                    _thisUnit getVariable ["arma3mercenaries_aiUnit", ""],
                    _groupOwnerUID,
                    getUnitLoadout _thisUnit,
                    [_allUnitsVariableClasses,_thisUnit] call FUNC(saveObjectVars),
                    _vehVarName
                ];

                _thisUnitsData pushBack _thisUnitData;
            };

        } forEach (units _thisGroup);

        // only save if group has units that were saved
        if (count (_thisGroupData select 1) > 0) then {
            _thisGroupData set [2,[_allGroupsVariableClasses,_thisGroup] call FUNC(saveObjectVars)];
            
            // --- A.I.M. Per-Entity Save Pipeline ---
            // Note: Groups are saved as an array containing [side, [units], [vars], ownerUID]
            private _uniqueEntityKey = format ["%1_grp_%2", _groupsTag, _savedGroupsCount];
            [_uniqueEntityKey, _thisGroupData] call A3M_fnc_dbSetSecure;
            
            _savedGroupsCount = _savedGroupsCount + 1;
        };
    };

} forEach _allGroups;

// --- Save the COUNT integer ---
private _countKey = format ["%1_COUNT", _groupsTag];
[_countKey, _savedGroupsCount] call A3M_fnc_dbSetSecure;

// ALSO delete the old INDEX array so we don't duplicate logic if mixing load systems
private _indexKey = format ["%1_INDEX", _groupsTag];
[_indexKey, []] call A3M_fnc_dbSetSecure;

// --- A.I.M. v812+ Architecture: SQLite Killed Tracker ---
// all _foundVehiclesVarnames that were not saved must have been removed or killed --> add to killedVarNames array
private _killedVarnamesKey = format ["%1_killedVarnames", _missionTag];
private _killedVarnames = [_killedVarnamesKey, [[],[],[]]] call A3M_fnc_dbGetSecure; // Index 0 is for units
private _killedUnitsVarnames = _killedVarnames param [0,[]];

_killedUnitsVarnames append _foundUnitsVarnames;
_killedUnitsVarnames arrayIntersect _killedUnitsVarnames;
_killedVarnames set [0,_killedUnitsVarnames];

[_killedVarnamesKey, _killedVarnames] call A3M_fnc_dbSetSecure;
