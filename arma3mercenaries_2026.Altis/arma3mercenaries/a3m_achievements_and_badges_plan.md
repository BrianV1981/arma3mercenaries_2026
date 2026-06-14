# A.I.M. Achievements & Badges System (Player & AI)

## 1. Core Concept
The A.I.M. Achievements system is a comprehensive, persistent tracking engine that rewards both the **Player Commander** and their **AI Mercenaries** for reaching specific milestones. This taps heavily into achievement hunting, giving players a reason to grind, explore, and keep their favorite AI alive.

This data will be persistently tracked in the `a3m_database.sqlite` and presented via a dedicated "Service Record" or "Medals" UI.

---

## 2. Tracking Categories
The system will silently tally statistics in the background using Arma 3 event handlers (`EntityKilled`, `GetInMan`, `FiredMan`, etc.).

### A. Combat Mastery (Kills & Accuracy)
*   **Marksman:** 10, 50, 100, 500 Confirmed Infantry Kills.
*   **Tank Hunter:** Destroy 1, 5, 20 Enemy Armor Vehicles.
*   **Bird Catcher:** Shoot down a helicopter with unguided rockets or small arms.
*   **One Shot, One Kill:** Achieve 5 consecutive headshots without missing.

### B. Endurance & Travel
*   **Rucksack Warrior:** Travel 10km, 50km, 100km on foot.
*   **Motorpool:** Drive 50km, 100km, 500km in land vehicles.
*   **Frequent Flyer:** Spend 5, 10, 24 cumulative hours in helicopters/planes.

### C. Survival & Medical (Battle Wounds)
*   **Purple Heart:** Survive being revived from a critical state (ACE Unconscious).
*   **Combat Medic:** Revive 10, 50, 100 friendly AI or players.
*   **Iron Man (AI Only):** Survive 5, 10, 20 consecutive "Shadow Operations" without hitting WIA status.

### D. Leadership & Economy
*   **Warlord:** Accumulate $1,000,000 in your Grad Money account.
*   **Quartermaster's Best Friend:** Purchase 50 weapons from the Black Market.
*   **Recruiter:** Hire 10, 50, 100 mercenaries over your career.

---

## 3. Rewards & Incentives
Achieving milestones isn't just for a shiny icon; it provides tangible gameplay benefits.

*   **Titles / Tags:** Earning "Tank Hunter" unlocks the title to be displayed next to the player/AI's name in the UI.
*   **Financial Bounties:** Earning a badge instantly deposits a massive cash bonus into the player's account.
*   **Passive Buffs (AI):** If an AI earns the "Rucksack Warrior" badge, their fatigue generation drops by 10%. If they earn "Marksman", they gain a +5 bonus to their Shadow Operations combat rolls.
*   **Unique Gear Unlocks:** Certain high-tier weapons in the Quartermaster Hub are completely locked until the player earns the requisite badge (e.g., unlocking the thermal sniper requires the "Marksman" badge).

---

## 4. The Database Architecture
To facilitate this without lagging the server, the SQLite database will require:
1.  **`A3M_PlayerStats` Table:**
    `UID | Kills | DistanceFoot | DistanceVeh | Revives | VehiclesDestroyed | MoneyEarned | Badges`
2.  **`A3M_MercenaryStats` Table:**
    `MercID | Kills | OpsSurvived | OpsWIA | Badges`

Stats are cached locally on the client/server and flushed to the SQLite database every 10 minutes to prevent database lockups.

---

## 5. UI Integration (The Service Record)
A new tablet interface or physical board at the FOB called the **"Service Record"**.
*   **Player Tab:** Displays the player's total stats, unlocked badges (colored), and locked badges (grayed out with progress bars).
*   **Roster Tab:** Allows the player to inspect their current AI squad and view their specific commendations, ribbons, and combat history.
