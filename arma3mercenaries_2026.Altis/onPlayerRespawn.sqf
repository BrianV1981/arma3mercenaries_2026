/*
    A3M onPlayerRespawn.sqf
    Executes locally when a player respawns.
*/

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

// CRITICAL SAFETY CHECK:
// If _oldUnit is null, it means the player is logging in for the very first time.
// We MUST exit immediately so we don't accidentally strip the loadout that GRAD persistence is trying to restore!
if (isNull _oldUnit) exitWith {};

// If _oldUnit exists, the player actually died in combat and is respawning.
// We strip them completely naked to ensure Arma 3 doesn't assign them a default NATO kit 
// and trick GRAD persistence into saving it.

removeAllWeapons _newUnit;
removeAllItems _newUnit;
removeAllAssignedItems _newUnit;
removeUniform _newUnit;
removeVest _newUnit;
removeBackpack _newUnit;
removeHeadgear _newUnit;
removeGoggles _newUnit;

// (Optional) You can add basic items here if you want them to spawn with a map or a radio later.
// _newUnit linkItem "ItemMap";

// Completely wipe the player's GRAD Fortifications virtual inventory
// This prevents them from keeping building supplies after death
_newUnit setVariable ["grad_fortifications_myFortsHash", [[], 0] call CBA_fnc_hashCreate, true];
_newUnit setVariable ["grad_fortifications_inventoryCargo", 0, true];
