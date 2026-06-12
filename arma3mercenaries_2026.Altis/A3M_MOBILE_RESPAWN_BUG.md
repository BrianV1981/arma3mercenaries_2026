# Bug: ACE3 Mobile Respawn Implementation Failure

## 1. Overview
During the previous global overhaul where legacy `addAction` scripts were converted into `ace_interact_menu` features, the logic for deploying Mobile Respawn points on vehicles was severely broken. 

Players can currently interact with specific heavy vehicles (CRVs, medical trucks, heavy helicopters) via the ACE menu and select "Set Mobile Respawn". The script will hint "Mobile Respawn Set", but the respawn point is never actually created on the dedicated server.

## 2. Root Cause Analysis
The failure stems from a fundamental misunderstanding of the `BIS_fnc_addRespawnPosition` parameter signature by the agent who originally transitioned the code.

### The Original (Working) Logic (v788):
In the legacy `mobileRespawnAddaction.sqf`, the respawn was created via:
```sqf
private _westRespawnID = [[west, _target], BIS_fnc_addRespawnPosition] remoteExec ["call", 0, true];
```
This correctly passed `west` (the faction) as the first parameter, and `_target` (the physical vehicle object) as the second parameter. The Arma 3 engine natively handled tracking the vehicle's movement.

### The Broken (Current) Logic:
In `initPlayerLocal.sqf`, the modernized ACE action attempts to execute:
```sqf
private _id = netId _target;
private _westRespawn = format ["respawn_west_%1", _id];
[_target, _westRespawn] remoteExec ["BIS_fnc_addRespawnPosition", 0, true];
```
This fails silently on the dedicated server for two reasons:
1. **Invalid Target:** It passes `_target` (a vehicle object) as the faction/target parameter instead of `west` or `independent`. 
2. **Missing Marker:** It passes a dynamically generated string (`"respawn_west_12345"`) as the location parameter. The engine interprets this string as a map marker, but no such marker was ever created.

## 3. Proposed Fix
We need to revert the internal execution block of the ACE action in `initPlayerLocal.sqf` to utilize the legacy, proven parameter structure. 

The broken `remoteExec` lines must be replaced with:
```sqf
[[west, _target], BIS_fnc_addRespawnPosition] remoteExec ["call", 0, true];
[[independent, _target], BIS_fnc_addRespawnPosition] remoteExec ["call", 0, true];
```
This will restore full functionality to mobile respawns across the JIP multiplayer network.