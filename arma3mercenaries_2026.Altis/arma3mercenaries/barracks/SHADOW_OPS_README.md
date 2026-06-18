# A3M Shadow Operations (V2 Engine)

The Shadow Operations module is a massive, highly-tactical, asynchronous "away mission" system that allows players to deploy stowed AI mercenaries on covert contracts. It acts as an elite money-sink and high-risk economic gamble.

## Core Features

### 1. Procedural Mission Generation
Missions are not static. The `fn_openShadowOpsDialog.sqf` script procedurally generates **30 unique contracts** per UI session by combining:
* **Target & Location:** Determines the base difficulty and context.
* **Forecasted Weather & Time:** The engine assigns a specific execution time (e.g., 0200 Night, 1200 Noon) and a forecasted weather state (Clear, Severe Storm, etc.).
* **Required Specialists:** Missions randomly demand a specific class of mercenary (e.g., `Engineer`, `Sniper`, `Medic`).

### 2. The Asset Requisition Cart (Shopping Cart UI)
Players must carefully plan their operations by spending money on external assets. 
* Players can purchase **multiple Intel and Support assets** (e.g., buying both a Mortar Strike and Loitering CAS).
* The UI strictly enforces that only **one Insertion (INFIL)** and **one Extraction (EXFIL)** method can be purchased per contract.

### 3. Synergistic Combat Logic (Execution Thread)
The actual dice rolls happen server-side inside `fn_serverShadowOpsThread.sqf`. The engine is brutal and does not just grant flat bonuses. It calculates **Synergies**:

* **Weather Deviation:** The forecasted weather in the briefing has a **30% chance to be wrong**. If meteorology is wrong, the server will roll a random weather event right before execution, forcing the squad to adapt to unexpected storms or fog.
* **Asset/Weather Synergy:** If a player buys `Loitering CAS (Wipeout)` but the actual weather is a `Severe Storm` or `Dense Fog`, the CAS cannot see the target and provides a **massive penalty** instead of a bonus.
* **Time/Asset Synergy:** If a player buys a `HALO Drop` but the mission is planned for `1200 Noon`, the drop is highly visible and severely penalizes the insertion. Conversely, a `HALO Drop` at `0200 Night` provides massive stealth bonuses.
* **Specialist Penalties:** If the mission requires an `Engineer` to blow a bridge and the squad does not have one, the execution phase suffers a crippling **-30 penalty**. Bringing the correct specialist yields a **+15 bonus**.

### 4. Mathematical Odds & Cascading Failures
The system uses a 3-Phase dice roll (Insertion, Execution, Extraction).
* Rolling `random 100` + `Modifiers` >= `Base Difficulty`
* **Cascading Failures:** Failing Phase 1 does not end the mission. Instead, it alerts the enemy, which permanently increases the difficulty of Phase 2 and Phase 3 by +10 and +15, respectively.
* **Total Wipes:** A squad that completely fails Phase 2 and Phase 3 will be wiped out (WIA). No payout is awarded.

## File Structure Reference

| File | Purpose |
|------|---------|
| `a3m_shadowOps_dialog.hpp` | The V2 UI layout featuring the dual squad-lists and Asset Requisition cart. |
| `fn_openShadowOpsDialog.sqf` | Procedurally generates the 30 session missions and populates the UI catalogs. |
| `fn_shadowOpsAddAsset.sqf` | Client-side logic for adding an asset to the shopping cart (enforces 1 Infil/Exfil rule). |
| `fn_shadowOpsRemoveAsset.sqf` | Client-side logic for removing an asset from the shopping cart. |
| `fn_onShadowOpsPlanChanged.sqf` | The "Calculate Impact" logic. Parses the cart, the squad classes, and the forecasted weather to give the player a projected odds warning in the UI. |
| `fn_shadowOpsDispatch.sqf` | Verifies the player has enough funds, deducts the cash, packages the purchased assets, deletes the mission from the local UI session, and sends the payload to the server. |
| `fn_serverShadowOpsThread.sqf` | **The Brain.** The server-side async thread that rolls the actual weather, processes synergies, rolls the dice for the 3 phases, updates the player via systemChat/hints, and handles final database state/payouts. |

## Modifying the Module
* To add new assets or upgrades, edit the `_allAssets` array in `fn_openShadowOpsDialog.sqf`.
* To modify the payout multipliers, edit the `_basePayout` variables in `fn_serverShadowOpsThread.sqf`.
* To add new synergy rules (e.g., adding an AT Specialist bonus against Convoys), you must update **both** the UI calculator (`fn_onShadowOpsPlanChanged.sqf`) and the server thread (`fn_serverShadowOpsThread.sqf`).
