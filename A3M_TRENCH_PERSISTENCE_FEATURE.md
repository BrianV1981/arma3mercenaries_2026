# Feature: ACE3 Trenches to GRAD Persistence Integration

## 1. Overview
Currently, when a player uses the `ACE_EntrenchingTool` to dig a trench via the ACE3 Self-Interaction menu, the resulting trench object is treated by the Arma 3 engine as an "orphaned" world object. 

Because the trench was not spawned through the `grad-fortifications` build menu, it lacks the internal variables required for the `grad-persistence` module to recognize it. Consequently, when the server restarts or the mission saves, all player-dug ACE trenches are wiped from the map.

## 2. The Solution: CBA Event Handler Injection
We can bridge the gap between ACE3 and the GRAD ecosystem using a lightweight, server-side CBA Event Handler. 

The `ace_trenches` module broadcasts a global CBA event called `"ace_trenches_finished"` the exact millisecond a player's digging progress bar reaches 100%. By capturing this event on the server, we can dynamically inject the specific variable (`"grad_fortifications_fortOwner"`) that `grad-persistence` looks for when scanning the map for saveable statics.

## 3. Implementation Details

### Target File:
`initServer.sqf` (Or a dedicated server-side initialization script called from it).

### The Code Block:
```sqf
// -------------------------------------------------------------------------
// --- ACE3 Trenches to GRAD Fortifications/Persistence Bridge ---
// -------------------------------------------------------------------------
["ace_trenches_finished", {
    params ["_unit", "_trench"];

    // 1. Assign GRAD Ownership to the player who dug it
    // This allows GRAD Fortifications to manage it, and GRAD Persistence to save it to the SQLite DB.
    _trench setVariable ["grad_fortifications_fortOwner", _unit, true];

    // 2. Prevent the trench from taking collision damage (Standard GRAD behavior)
    _trench allowDamage false;

    diag_log format ["[A3M] ACE Trench %1 dug by %2. Tagged for GRAD Fortifications and Persistence.", typeOf _trench, name _unit];

}] call CBA_fnc_addEventHandler;
```

## 4. Technical Context & Proof of Concept
A deep search of the `modules/grad-persistence` directory (specifically `functions/save/fn_saveGradFortificationsStatics.sqf` and `fn_saveContainers.sqf`) confirmed that the persistence saving loop uses the following condition to validate an object:
`!isNil {_x getVariable "grad_fortifications_fortOwner"}`

By forcefully appending this variable to the newly spawned ACE trench object, the next iteration of the `grad_persistence_fnc_saveMission` loop will successfully serialize the trench's classname, exact 3D position, and vector direction into the A3M SQLite database. 

## 5. Performance Impact
**Zero.** Because this relies on a CBA Event Listener (`CBA_fnc_addEventHandler`) rather than a scheduled polling loop, it consumes no server resources until a player actually finishes digging a trench.