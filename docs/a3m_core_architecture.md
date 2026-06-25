# A3M Core (The Sovereign Mod)
**Project Codename:** Operation Sovereignty
**Goal:** Fork ALiVE, ACE, and CBA into a single, stripped-down, high-performance master mod (`@a3m_core`). Take absolute root-level control of Arma 3's engine.

## Phase 1: Deconstruction & Bloat Removal (The Great Purge)
The first step is pulling down the open-source repositories for ALiVE, ACE3, and CBA_A3, and ruthlessly stripping out everything Arma 3 Mercenaries does not use.

**ALiVE Purge:**
*   **Keep:** OPCOM, Virtual AI Profiler, Military Logistics (basic), C2ISTAR.
*   **Delete:** Civilian Population, CQB module, Player Combat Support, Multiskill, Intel, ALiVE Menu bloat.

**ACE3 Purge:**
*   **Keep:** Medical (basic), Interaction Menu, Explosives, Hearing, Ballistics (lite), Fatigue.
*   **Delete:** Advanced Ballistics, Advanced Fatigue, Cookoff, Frag, Logistics, Fast Roping, Weather, Map Tools, Captives (we use our own logic).

**Result:** A hyper-lean mod that loads 10x faster and frees up massive amounts of server CPU overhead.

## Phase 2: Core Injections (The Northstar Protocol)
Once we have the bare-bones framework, we stop writing external scripts and start writing *internal engine logic*.

*   **Native Virtualization:** We inject the `A3M_Northstar` target directly into ALiVE's `fnc_profileEntity.sqf`. When a QRF virtualizes to save FPS, they don't forget their mission. They unpack 20 minutes later and instantly resume marching to the target.
*   **Vcom Annihilation:** We don't even run Vcom as a separate script anymore. We surgically graft the "Trojan Horse" peeling logic and the "Radio Carrier" communication limits directly into ALiVE's OPCOM decision-making tree.
*   **Native Event Handlers:** Instead of our server constantly checking `alive _pilot` in a loop, we tie directly into ACE Medical's `ace_medical_fatalDamage` event handler. The exact millisecond the pilot takes a fatal bullet, our code fires instantly. 

## Phase 3: The Unified Namespace
We rewrite the global configurations so everything falls under the `A3M_` prefix. 
*   No more conflicting mod variables.
*   No more guessing if a variable belongs to CBA or ACE.
*   We create a centralized UI in the pause menu for the Operator to tweak Northstar aggressiveness, QRF spawn rates, and economy payouts on the fly without ever restarting the server.

## Phase 4: Compilation & Deployment
We compile the raw source code into a single, cohesive `@a3m_core` mod folder. 
*   The server only loads **ONE** mod.
*   The clients only download **ONE** mod.
*   We gain 100% control over the entire ecosystem. We answer to no one.
