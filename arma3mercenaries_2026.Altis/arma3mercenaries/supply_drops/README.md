# A.I.M. VTOL Supply Drop Overhaul

Welcome to the new, unified VTOL Supply Drop engine for Arma 3 Mercenaries. 

## 1. Overview
Historically, supply drops in this project were handled via 6+ separate, hardcoded scripts (e.g., `supplyDrop_medical.sqf`, `supplyDrop_AA.sqf`). These legacy scripts did not spawn real aircraft; they merely played an audio file and teleported a crate 100 meters above the player's head.

This folder now contains a single, unified master engine: **`fn_initSupplyDrop.sqf`**. 

When triggered, this engine:
1. Dynamically calculates the buyer's faction (NATO, CSAT, AAF, etc.).
2. Spawns a physical, faction-appropriate VTOL heavy lifter 1,500 meters away.
3. Issues waypoints forcing the VTOL to physically fly across the map towards the buyer.
4. Executes a physical paradrop of the requested cargo crate exactly as the VTOL passes overhead.
5. Populates the crate with the custom items, magazines, and fortifications specified in the UI configuration.
6. Automatically tags the crate with the buyer's `getPlayerUID` to ensure seamless `grad-fortifications` packing and ownership rights.
7. Orders the VTOL to fly away and despawn.

## 2. Grad-Fortifications Integration
Previously, players could buy a supply drop but could not pack up or persist the heavy crate (e.g., `B_Slingload_01_Cargo_F`) because it was spawned by the server with no ownership rights.

The new engine explicitly executes the following line upon paradrop:
```sqf
_cargo setVariable ["grad_fortifications_fortOwner", getPlayerUID _buyer, true];
```
This guarantees that the player who purchased the drop is the legal owner of the container across the multiplayer network, granting them full rights to pack it up, drag it, or store it in their HG Garage.

## 3. How to Create a New Supply Drop
You **do not** need to create new `.sqf` scripts to add new supply drops to the game.

Because the unified engine is entirely dynamic, you can add an infinite number of new supply drops simply by adding a new class to your store UI configuration (e.g., `modules/supplyDropStoreMenu_1.hpp`).

### The Architecture Array:
The `A3M_fnc_initSupplyDrop` engine expects exactly 5 parameters passed as an array:
`["_cargoClass", _buyer, [_fortsArray], [_magsArray], [_itemsArray]] spawn A3M_fnc_initSupplyDrop;`

* **`_cargoClass`**: The classname of the crate or container being dropped (e.g., `"B_Slingload_01_Cargo_F"`).
* **`_buyer`**: Always pass `_this select 0` to ensure the HG UI passes the purchasing player.
* **`_fortsArray`**: An array of `grad-fortification` items to inject into the crate. Format: `[["ClassName", Amount], ["ClassName2", Amount]]`.
* **`_magsArray`**: An array of magazines or missiles to inject into the crate.
* **`_itemsArray`**: An array of standard weapons, backpacks, or inventory items to inject into the crate.

### Example: Adding a "Sniper Care Package"
To add a brand new sniper supply drop, you simply add this entry to your store menu:

```cpp
class Sniper_Care_Package {
    displayName = "Sniper Care Package";
    description = "Air-drops a small crate containing ghillie suits, a sniper rifle, and ammo.";
    price = 15000;
    amount = 1;
    stock = 9999;
    
    // The Magic Line:
    code = ["Box_NATO_Support_F", _this select 0, [], [["7Rnd_408_Mag", 10]], [["srifle_LRR_F", 1], ["U_B_GhillieSuit", 2]]] spawn A3M_fnc_initSupplyDrop;
};
```

This single line of configuration completely replaces the need for a dedicated `.sqf` script!

## 4. Maintenance & Upgrades
If you ever want to change how supply drops behave (e.g., adding a smoke grenade color based on faction, changing the drop altitude, or altering the VTOL spawn distance), you only have to edit **one** file: `fn_initSupplyDrop.sqf`. All drops across the entire server will instantly inherit the upgrade.
