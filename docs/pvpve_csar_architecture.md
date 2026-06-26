# PvPvE CSAR Architecture (The Golden Egg)

## 1. Core Philosophy
The CSAR ecosystem is a dynamic, multi-phase **PvPvE "Capture the Flag"** state machine. The pilot (or their corpse) serves as the "Golden Egg." 
*   **Human Players:** OPFOR and BLUFOR players compete directly against each other for the pilot to secure massive payouts.
*   **AI Forces:** AI QRFs act as reinforcements to fill out the battlefield, assisting human players of their respective factions or attempting to secure the pilot themselves if players are absent.
*   **Dynamic Flow:** A single ambient helicopter crash can seamlessly transition through multiple distinct mission phases (Rescue -> Transport -> Corpse Recovery) based entirely on the live actions of the combatants.

## 2. The Mission States (The State Machine)

### State 1: The Crash (CSAR Phase)
When an ambient aircraft is destroyed, the pilot ejects. 
*   **Dynamic Tasking:** The mission generated depends entirely on the pilot's native faction.
    *   *If the pilot is BLUFOR:* BLUFOR receives a "Rescue" task. OPFOR receives a "Capture/Bounty" task.
    *   *If the pilot is OPFOR:* OPFOR receives a "Rescue" task. BLUFOR receives a "Capture" task.
*   **The Race:** Both factions (and their AI QRFs) race to the crash site.

### State 2: The Tug-of-War (Transport Phase)
The moment a faction (Player or AI) secures the pilot using the Ace Interaction (`holdAction`), the original CSAR task fails/cancels.
*   **Task Transformation:** A new **Transport/Hostage** mission is instantly generated for the capturing faction.
*   **Dynamic Extraction:** The extraction coordinate is dynamically assigned to the capturer's faction base.
*   **The Hostage Beacon:** This is the most dangerous leg of the quest. If enabled via the CBA Settings, a map marker will broadcast the captive pilot's live location every 5 seconds, drawing massive PvP and AI heat.
*   **The Hijack:** If the opposing faction intercepts the convoy and captures the pilot back, the current Transport task fails, and a *new* Transport task is generated pointing back to their own base.

### State 3: The KIA Branch (Corpse Recovery Phase)
If the pilot is killed at *any* point during State 1 or State 2, all active rescue/transport tasks fail immediately.
*   **Task Transformation:** The mission seamlessly transitions into a **Corpse Recovery** op.
*   **BLUFOR Motivation:** Code of Honor (No man left behind).
*   **OPFOR Motivation:** The corpse contains highly classified intel.
*   **Mechanics:** Players must secure the corpse (e.g., using Ace body dragging or a custom intel interaction) and return it to their respective base for a reduced, but still valuable, payout.

## 3. Implementation Plan

To achieve this without creating a monolithic, unreadable script, we need to modularize our logic:

- [ ] **Phase 1: Hostage Beacon Integration**
  - Add a new CBA Setting in `XEH_preInit.sqf`: `A3M_CSAR_HostageBeacon` (Toggle).
  - Inject the live-tracking marker loop into the `holdAction` execution block, broadcasting the pilot's position every 5 seconds if the setting is true.

- [ ] **Phase 2: Task State Transformations**
  - Refactor the `holdAction` to instantly transition the ALiVE/Arma Task from "CSAR" to a new "Transport" task when the pilot is secured.
  - Build the logic to handle "Hijacks" (re-assigning the task and flipping the extraction zone if the opposing side intercepts the pilot).

- [ ] **Phase 3: The Corpse Recovery Branch**
  - Update the PFH `!alive _pilot` check.
  - Instead of gracefully exiting and deleting the marker when the pilot is KIA, spawn the Corpse Recovery task (`fn_generateCorpseRecovery.sqf` or similar) centered on the pilot's body.
  - Implement a new `holdAction` on the corpse to secure the intel or bag the body.
