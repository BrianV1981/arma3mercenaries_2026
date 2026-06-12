# A.I.M. Sovereign SQLite Architecture Map
*Compiled: May 30, 2026*

This document serves as a complete technical map of the SQLite database transition attempted across versions `v801` through `v812`. It outlines the Rust extension bridge, the Arma 3 SQF wrappers, the database schema, and the known failure points in the `grad-persistence` parsing logic.

---

## 1. The Core Infrastructure

### The Rust Extension (`a3m_db_core`)
*   **Location:** `/home/brian-vasquez/aim-a3m/a3m-sqlite-bridge/`
*   **Compiled Binary:** `/home/brian-vasquez/arma3server/@a3m_db_core/a3m_db_core_x64.so`
*   **Function:** A lightweight C++ compatible wrapper written in Rust. It listens for `callExtension` commands from the Arma 3 engine, opens a direct connection to the SQLite `.sqlite` file, and executes raw SQL queries.
*   **String Formatting:** The Rust bridge was specifically modified to return data exactly as Arma 3 expects it: `[1, "data string"]` instead of boolean returns, ensuring `parseSimpleArray` can read it natively.
*   **Limitation:** The native Arma 3 `callExtension` buffer is hardcoded to a maximum of **10,240 characters**. Any data array exceeding this limit (e.g., saving 45 ALiVE map groups simultaneously) will truncate and corrupt the SQLite entry.

### The Database File
*   **Location:** `/home/brian-vasquez/arma3server/a3m_database.sqlite`
*   **Schema:** The database consists of a single, ultra-fast table named `store`.
*   **Structure:**
    *   `id` (TEXT PRIMARY KEY): The unique identifier for the data row (e.g., `Player_76561197997216797_Wallet`).
    *   `val` (TEXT): The serialized SQF array or HashMap string stored as raw text.

---

## 2. The Arma 3 SQF Wrappers

To bypass `profileNamespace` and write to the database, three distinct wrappers were injected into the root `initServer.sqf`.

### `A3M_fnc_dbSet`
Takes an ID and a raw SQF array/string, serializes it using `str`, and pushes it through the Rust bridge to the database.
```sqf
A3M_fnc_dbSet = {
    params ["_key", "_data"];
    "a3m_db_core" callExtension ["set", [_key, str _data]];
};
```

### `A3M_fnc_dbGet`
The standard parser for pulling Flat Arrays (like Player Inventory, Vehicles, or Groups).
```sqf
A3M_fnc_dbGet = {
    params ["_key", "_defaultValue"];
    private _extArray = "a3m_db_core" callExtension ["get", [_key]];
    private _rawString = _extArray select 0;
    private _result = parseSimpleArray _rawString;
    
    if ((_result select 0) isEqualTo 1 && {(_result select 1) != ""}) then { 
        private _valString = _result select 1;
        if (([_valString, 0, 0] call BIS_fnc_trimString) == "[") then {
            parseSimpleArray _valString
        } else {
            call compile _valString
        };
    } else { _defaultValue };
};
```

### `A3M_fnc_dbGetHash`
A specialized parser built exclusively for `grad-fortifications`. Because fortifications natively save as HashMaps rather than Arrays, using `parseSimpleArray` on them causes a fatal engine crash. This wrapper explicitly uses `call compile` to safely reconstruct the HashMap object from the database string.
```sqf
A3M_fnc_dbGetHash = {
    params ["_key", "_defaultValue"];
    private _extArray = "a3m_db_core" callExtension ["get", [_key]];
    private _rawString = _extArray select 0;
    private _result = parseSimpleArray _rawString;
    if ((_result select 0) isEqualTo 1 && {(_result select 1) != ""}) then { 
        private _parsed = call compile (_result select 1);
        if (typeName _parsed == "HASHMAP") then { _parsed } else { _defaultValue };
    } else { _defaultValue };
};
```

---

## 3. The `grad-persistence` Integration

The goal was to strip `CBA_HASH` logic out of the `grad-persistence` framework entirely, flattening the data into raw arrays for faster SQLite storage.

### Data Row Map
When a `#gradpersistenceSave` is triggered, the data is sliced into these specific SQLite rows:

| Category | SQLite `id` Key | Status |
| :--- | :--- | :--- |
| **HG Garage** | `HG_Garage_[UID]` | Working Flawlessly |
| **HG Inventory** | `HG_Inventory_[UID]_[VehicleID]` | Working Flawlessly |
| **Player Wallet** | `Player_[UID]_Wallet` | Working Flawlessly |
| **Player Bank** | `Player_[UID]_Bank` | Working Flawlessly |
| **Player Inventory** | `Player_[UID]_Inventory` | Working Flawlessly |
| **Player Damage** | `Player_[UID]_Damage_ACE` | Working Flawlessly |
| **Player Position** | `Player_[UID]_Position` | Working (Requires `fn_handleDisconnect` bypass) |
| **Vehicles** | `mcd_grad_persistence_my_persistent_mission_vehicles` | Database Works. *Load Script Broken.* |
| **Containers** | `mcd_grad_persistence_my_persistent_mission_containers` | Database Works. *Load Script Broken.* |
| **Fortifications**| `my_persistent_mission_fortifications` | Database Works. *Load Script Broken.* |
| **AI Groups** | `mcd_grad_persistence_my_persistent_mission_groups` | Database Works. *Load Script Broken.* |

---

## 4. The Point of Failure: The Parsing Cascade

The SQLite database and the `A3M_fnc_dbSet` wrappers **did not fail**. The data was successfully reaching the `.sqlite` file on the hard drive. 

The catastrophic failure occurred during the server reboot, specifically inside the `grad-persistence/functions/load/` scripts. 

### A. The Asynchronous `waitUntil` Loop
In the legacy `v771` build, every physical object (Vehicles, AI, Players) was wrapped in a `CBA_fnc_waitUntilAndExecute` loop. This forced the server to wait until the 3D model physically rendered in the engine before attempting to stuff it full of inventory data or custom variables.
When the arrays were flattened for SQLite, this loop was removed in an attempt to streamline the code. This resulted in the engine trying to apply data to objects that didn't exist yet, causing silent crashes.

### B. The `loadObjectVars` Argument Crash
Because the `waitUntil` loop was missing, the timing of array unpacking was thrown off. When `fn_loadVehicles.sqf` or `fn_loadContainers.sqf` attempted to reattach custom variables (like `HG_Owner` or `grad_moneymenu_isStorage`) using the `loadObjectVars` function, it crashed.
*   **The Error:** `Error foreach: Type Group, expected Array,HashMap`
*   **The Cause:** The argument order was accidentally reversed in the flat-array translation (`[_object, _vars]` instead of `[_vars, _object]`).
*   **The Result:** The script hit a fatal error on the very first vehicle in the database array. Because Arma 3 aborts the entire `forEach` loop upon a fatal error, it instantly stopped loading the rest of the database. This is why 1 Cargo Box would load, but the Ambulance, Repair Truck, and Water Tanks waiting in the queue behind it were permanently deleted from the world.

### C. The `loadVehicleInventory` Choke
Even if `loadObjectVars` succeeds, the vanilla `grad-persistence` inventory parser (`fn_loadVehicleInventory.sqf`) is notoriously fragile when handling complex mod items (like ACE medical supplies or nested backpacks). If the SQLite array feeds it an item classname it doesn't recognize or can't fit into the trunk, it aborts the inventory sequence, resulting in vehicles spawning completely empty. 

---

## 5. Conclusion & Recommendations

The SQLite bridge itself is highly performant and stable. The integration failure was caused entirely by disrupting the fragile, asynchronous execution timing of the `grad-persistence` load scripts while translating from Hashes to Flat Arrays.

If a future attempt is made to transition to SQLite, the safest path forward is:
1. **Do not flatten the arrays.** Keep the `v771` `CBA_HASH` structures entirely intact within `grad-persistence`.
2. Modify `A3M_fnc_dbSet` to serialize the `CBA_HASH` directly into a JSON string before sending it to Rust. 
3. This maintains 100% compatibility with the native `grad-persistence` parsers and avoids breaking the delicate `loadObjectVars` and `loadVehicleInventory` execution chains.