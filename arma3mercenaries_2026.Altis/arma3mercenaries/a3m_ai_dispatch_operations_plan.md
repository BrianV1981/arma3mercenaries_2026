# A.I.M. Shadow Operations (Off-Screen AI Dispatch System)

## 1. Core Concept
**"Shadow Operations"** transforms the virtual barracks from a simple storage locker into an active, strategic asset. Players can dispatch stowed mercenaries on text-based, off-screen missions. The system runs entirely on weighted dice rolls (RNG) influenced by the squad's composition, gear, and size.

This feature adds a deep management-sim layer to the game, generating emergent stories through real-time A3M dynamic text updates.

---

## 2. Mission Generation & Archetypes
Missions are dynamically generated on a loop and visible via a new **Shadow Operations Terminal** at the FOB. 

*   **Reconnaissance:** High stealth requirement. *Bonus modifiers for Snipers, Marksmen, and Scouts.*
*   **Direct Action / Raid:** High combat requirement. *Bonus modifiers for Machine Gunners, Grenadiers, and Heavy Armor.*
*   **Asset Recovery / Rescue:** High survival requirement. *Bonus modifiers for Medics and balanced squads.*
*   **Sabotage:** High technical requirement. *Bonus modifiers for Engineers and Explosive Specialists.*

---

## 3. Difficulty & High-Priority Contracts
Instead of rigid "Easy/Medium/Hard" labels, difficulty is conveyed through narrative warnings in the mission briefing:

*   **Low Threat (Base Roll 30+):** "Local militia activity. Standard patrol should suffice."
*   **Medium Threat (Base Roll 50+):** "Heavily fortified compound. Recommend bringing heavy weapons."
*   **High Threat (Base Roll 75+):** "Warning: Tier-1 enemy presence. Send your baddest SOBs. Minimum squad size of 5 strongly advised."

**High-Priority Wildcards:** Periodically, a high-risk/high-reward contract will appear on the terminal. These offer massive payouts and rare loot but carry a devastating Base Roll requirement. 

---

## 4. The Math (Weighted Dice Rolls)
Every mission has a base **Difficulty Rating (1-100)**. To succeed a phase, the squad must roll higher than the difficulty threshold.

**Success Modifiers:**
1.  **Numbers Advantage:** +5 to the roll for every additional mercenary sent (up to a cap).
2.  **Class Synergy:** +15 to the roll if the squad contains the "Ideal Class" for the mission type.
3.  **Gear Quality:** The script evaluates the loadout value (e.g., weapon attachments, high-tier body armor) and adds a +1 to +10 bonus.
4.  **Veteran Status:** If we track AI survival/XP, higher level AI provide passive bonuses.

---

## 5. The 4-Phase Execution (The Story Engine)
Once dispatched, the mission plays out in real-time. Every few minutes, the player receives a narrative A3M dynamic text update detailing the phase.

1.  **Phase 1: Insertion**
    *   *Success:* "Bravo Team inserted undetected."
    *   *Failure:* "LZ was hot. Bravo Team took minor shrapnel." (Applies minor injury modifier to next rolls).
2.  **Phase 2: Execution / Entry**
    *   *Success:* "Target compound breached. Zero casualties."
    *   *Failure:* "Breach stalled by heavy resistance. Squad pinned down."
3.  **Phase 3: The Wildcard (Engagement)**
    *   *RNG Event:* "Enemy QRF inbound." or "Found high-value intel."
    *   *Player Choice (Optional):* Player is warned. They have 60 seconds to hit the "ABORT" button on their ACE menu.
4.  **Phase 4: Extraction**
    *   *Success:* "Dust off complete. Returning to base."
    *   *Failure:* "Chopper took heavy fire. Casualties sustained."

---

## 6. Consequences & Outcomes
Because the stakes are high, the rewards must match.

*   **Flawless / Critical Success:** Bonus cash payout, rare weapon drop directly to the quartermaster, high XP.
*   **Standard Success:** Base cash payout.
*   **Minor Failure (Injuries):** The mercenaries return but are flagged as "WIA" in the database. They cannot be deployed into the player's active squad or sent on Shadow Ops for a set real-time duration (e.g., 30 minutes in the Medbay).
*   **Critical Failure (KIA):** The mercenary's SQLite entry is permanently wiped. "Sgt. Adams was Killed In Action. We mourn his loss."
*   **Catastrophic Failure (MIA / Surrender):** If a mission goes horribly wrong and multiple KIA rolls occur, there is an RNG chance the surviving AI abandon the mission, quit, or surrender to the enemy. Their DB status changes to "MIA."

---

## 7. Advanced Simulation Mechanics (Phase 2)
To deepen the emotional investment and management strategy, the following features will be woven into the dispatch logic:

1.  **The Fatigue System:** Squads returning from a successful operation are temporarily assigned an "Exhausted" DB status. Dispatching an exhausted squad applies a severe penalty to all dice rolls, forcing the commander to rotate their roster and maintain a deep bench of reserves.
2.  **Mercenary Traits:** Upon recruitment, AI roll hidden passive modifiers:
    *   *Night Owl:* +15 bonus to operations dispatched at night.
    *   *Coward:* Doubles the probability of surrendering (MIA) if a mission fails.
    *   *Iron Will:* Cannot be killed outright. Critical failures result in severe WIA status instead.
    *   *Looter:* Generates a 20% bonus to cash payouts upon successful extraction.
3.  **Physical Rescue Operations:** When an AI squad is flagged as "MIA," the server dynamically generates a physical, live Arma 3 task on the Altis map. The player can take their active squad to the designated enemy compound, breach it, and physically rescue their captured mercenaries to return them to the barracks.
4.  **Persistent Scars:** Mercenaries who survive a "WIA" status permanently gain a "Scar" in their UI profile (e.g., "Shrapnel - Left Leg"). This creates a paper trail of their history and makes high-survival veterans incredibly valuable to the player.

---

## 8. Implementation Architecture (How we build it)
1.  **The Database Layer:** Add two columns to the `A3M_Mercenaries` SQLite table: `Status` (Stowed, Active, ShadowOps, WIA) and `ShadowOps_TimeLeft`.
2.  **The UI / Terminal:** Build an `A3M_ShadowOps_Dialog.hpp`. Left side shows available missions, right side allows selecting currently stowed barracks AI.
3.  **The Engine:** A server-side script `fn_shadowOpsManager.sqf` that uses `addEventHandler ["MissionCalculated", ...]` or a `PFH` (Per-Frame Handler loop) to manage the background timers and execute the dice rolls.
4.  **The Abort Switch:** A variable tied to the active mission that immediately forces the next phase to be "Emergency Extraction", taking a penalty to the roll but prioritizing survival over the objective.
