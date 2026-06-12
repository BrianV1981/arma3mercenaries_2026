# 🛠️ A3M Vehicle Salvage Ecosystem

A lightweight, highly optimized, event-driven vehicle salvaging module for Arma 3. 

## 📖 Overview
This module allows players to earn money by salvaging destroyed enemy (or friendly) vehicles. It is designed to be completely plug-and-play and operates with **zero background performance cost**. 

Unlike other scripts that rely on heavy `while` loops or `forEach` checks that miss dynamically spawned ALiVE/Zeus vehicles, this module uses a native `EntityKilled` engine hook. The exact millisecond a vehicle is destroyed, the salvage interaction is attached to the flaming wreck.

## ✨ Features
*   **Zero Background Loops:** Fully event-driven. Consumes 0% CPU until a player clicks the salvage button.
*   **Dynamic Spawn Support:** Instantly works on vehicles spawned by ALiVE, Zeus, or standard editor placement.
*   **Item Requirements:** Enforce inventory requirements (e.g., must hold a `"ToolKit"`) to successfully salvage.
*   **Dynamic Payouts:** Set a default payout, or configure specific payouts based on vehicle classnames (e.g., T-100 Varsuk pays more than a Quadbike).
*   **Global Cleanup:** Automatically and globally deletes the wreckage upon successful salvage, keeping the server clean.
*   **Immersive UI:** Uses clean, non-intrusive `BIS_fnc_dynamicText` notifications instead of clunky vanilla hints.

## ⚙️ Configuration
Server Administrators can tweak the ecosystem directly at the top of `functions/fn_initSalvage.sqf`:

```sqf
A3M_Salvage_RequiredItem = "ToolKit";   // Item required to initiate salvage
A3M_Salvage_Time = 60;                  // Time (in seconds) the salvage takes
A3M_Salvage_DefaultReward = 50000;      // Default payout to bank account

// Optional: Specific payouts for specific classnames
A3M_Salvage_Values = [
    ["O_MBT_02_cannon_F", 75000],  // T-100 Varsuk
    ["O_Heli_Attack_02_F", 100000] // Mi-48 Kajman
]; 
```

## 🚀 Dependencies
Currently configured for **A3M (Arma 3 Mercenaries)** environments.
*   **ACE3:** Utilizes `ace_interact_menu` and `ace_common_fnc_progressBar`.
*   **grad_moneymenu:** Wires payouts directly to the player's bank account.

*(Note: If porting to a vanilla standalone mod, ACE interactions can be swapped for native `BIS_fnc_holdActionAdd`)*
