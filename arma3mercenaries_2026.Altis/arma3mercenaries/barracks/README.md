# A3M Virtual Barracks System

The A3M Virtual Barracks is the core physical deployment hub for the Arma 3 Mercenaries (A3M) framework. It acts as the bridge between the persistent CouchDB (where mercenaries exist as JSON data) and the live Arma 3 game world (where they exist as 3D AI units).

## Table of Contents
1. [Eden Editor Setup](#eden-editor-setup)
2. [Architecture Overview](#architecture-overview)
3. [Physical Deployment & The FSM Hack](#physical-deployment--the-fsm-hack)
4. [Stowing & Database Persistence](#stowing--database-persistence)
5. [Shadow Operations Module](#shadow-operations-module)

---

## 1. Eden Editor Setup

Because the A3M architecture uses Global ACE Actions, you **do not** need to execute any complex scripts on your objects to make them functional. The system automatically detects objects that are flagged as Barracks and attaches the ACE action for you. This makes your objects 100% immune to JIP (Join-In-Progress) and Respawn bugs.

### Setup Instructions:
1. Place any physical object in the Eden Editor (e.g., a whiteboard, a laptop, an NPC, or a sign).
2. Open the object's attributes (Double Click).
3. Paste the following line into the **Init** field:

```sqf
this setVariable ["A3M_isBarracks", true, true];
```

4. Click OK.

That's it! When a player approaches the object in-game, the "Access Mercenary Barracks" ACE interaction will automatically appear, opening the Barracks UI (`fn_openBarracks.sqf`).

---

## 2. Architecture Overview

The Barracks operates on a strict Server-Client divide to ensure database integrity and prevent duping.
* **Client-Side UI:** The UI requests a "Dossier" from the server. The server reads the DB and sends back arrays of "Stowed" and "Deployed" mercenaries.
* **Server-Side Execution:** All actions (Deploying, Stowing, Shadow Ops) are executed purely on the server via `remoteExecCall`. The server validates the request, updates the database, handles the physical spawning/deleting of the AI, and then sends a UI refresh command back to the client.

---

## 3. Physical Deployment & The FSM Hack

The deployment process (`fn_serverDeployMercenary.sqf`) contains highly complex workarounds for Arma 3 engine bugs.

### The Remote Group Corrupted FSM Bug
If a server uses `createUnit` to spawn an AI directly into a remote player's group, the AI's internal State Machine (FSM) permanently corrupts. They will refuse "Move" commands and freeze.
**The Fix:** The script spawns the AI into a server-local dummy group first, injects the custom ACE Name synchronously, and then uses `joinSilent` to transfer the fully initialized AI across the network to the player's group.

### The VCOM/ALiVE Shielding
A3M mercenaries are persistent elites meant to strictly obey the player. Because mods like VCOM and ALiVE will aggressively hijack AI groups, the deployment script executes `A3M_fnc_disableVcom` and strips `ALiVE_disableDynamicSimulation` to perfectly shield the AI from external logic.

### ACE Handcuffs Injection
To ensure players do not deploy a mercenary in the middle of a firefight as an instant meat-shield, mercenaries are spawned in a captive state (`setCaptive true`) and given ACE handcuffs. The player must physically walk up to them and "Mobilize" them before they can fight.

---

## 4. Stowing & Database Persistence

When a player clicks "STOW" (`fn_serverStowMercenary.sqf`), the following happens:
1. The server forces the AI object to save its current Loadout and Cash to the persistent CouchDB.
2. The AI object is physically deleted from the Arma 3 world.
3. The database profile is marked as `"Stowed"`, returning them to the UI list.

> **Note:** Dead mercenaries cannot be stowed. If an AI dies, the `MPKilled` event handler instantly flags their database profile as `IsDead = true`. Dead mercenaries permanently disappear from the Barracks UI.

---

## 5. Shadow Operations Module

The Barracks also houses the **Shadow Operations** terminal. This acts as a massive tactical mini-game allowing players to send "Stowed" mercenaries on covert, asynchronous, background missions for huge financial rewards. 

For deep technical details on the procedural generation, synergistic combat logic, and mathematical odds of Shadow Operations, please read the dedicated [SHADOW_OPS_README.md](SHADOW_OPS_README.md) located in this directory.
