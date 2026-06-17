# Changelog

## [v1.22.3] - 2026-06-16
- Fix: Player profile skipping, CfgRemoteExec whitelist blocking ALiVE, and player guide text truncation


## [v1.22.2] - 2026-06-16
- Fix: Refactored Lobby Dummy Overwrite lock to safely unlock for new or killed players


## [v1.22.1] - 2026-06-16
- Fix: Whitelisted Blackfish remoteExec functions in CfgRemoteExec


## [v1.22.0] - 2026-06-16
- Feature: Restored Satellite Sweep and added independent 5-min Blackfish Gunship Strike (Closes #89)


## [v1.21.0] - 2026-06-16
- Feature: Implemented Remote Blackfish Gunship Control (Closes #89)


## [v1.20.15] - 2026-06-16
- Fix: Re-centered player spoofing, extended delay, and added N key optics toggle


## [v1.20.14] - 2026-06-16
- Fix: Implement Vcom AI review recommendations (Closes #84)


## [v1.20.13] - 2026-06-16
- Fix: Added ALiVE synchronization delay and offset the physical player teleportation to hide the local player body


## [v1.20.12] - 2026-06-16
- Fix: Implemented the definitive Zeus Camera Trick teleportation to natively force ALiVE to spawn AI


## [v1.20.11] - 2026-06-16
- Fix: Switched UAV logic to an invisible SwitchableUnit to properly spoof ALiVE's player array


## [v1.20.10] - 2026-06-16
- Fix: Implement Write-Protection Lock for grad-persistence to prevent Dummy Overwrite (Closes #87)


## [v1.20.9] - 2026-06-16
- Fix: Utilized physical UAV to natively trigger ALiVE virtual spawning during satellite sweep


## [v1.20.8] - 2026-06-16
- Fix: Area looter overflow system (Closes #88)


## [v1.20.7] - 2026-06-16
- Fix: Utilized ALIVE_fnc_forceSpawnRadius to force HVT AI guards to physically spawn during satellite sweep


## [v1.20.6] - 2026-06-16
- Fix: Whitelisted BIS_fnc_dynamicText and systemChat in CfgRemoteExec


## [v1.20.5] - 2026-06-16
- Fix: Whitelisted database and persistence functions for CfgRemoteExec mode 1


## [v1.20.4] - 2026-06-16
- Fix: Patched CfgRemoteExec vulnerability (mode 2 -> 1)


## [v1.20.3] - 2026-06-16
- Fix: Synchronized default CBA settings for Satellite UI


## [v1.20.2] - 2026-06-16
- Fix: Swapped UAV spoof for explicit ALIVE_playerList injection array trick


## [v1.20.1] - 2026-06-16
- Fix: Refined ALiVE UAV unvirtualization, fuzzy offset, and UI cost defaults


## [v1.20.0] - 2026-06-16
- Feature: Added fuzzy HVT locations, ALiVE spoof spawning, and SpaceX enhancements


## [v1.19.1] - 2026-06-16
- Fix: Corrected SQF return syntax error in camera and added SpaceX branding


## [v1.19.0] - 2026-06-16
- Feature: Replaced establishing shot with fully interactive satellite drone camera


## [v1.18.18] - 2026-06-16
- Fix: Added new mission.sqm and fixed boolean operator precedence causing silent crash


## [v1.18.17] - 2026-06-16
- Fix: Removed CBA formatting dependency that was causing silent crash on satellite purchase


## [v1.18.16] - 2026-06-16
- Fix: Added strict type safety to task parsing to prevent silent crash


## [v1.18.15] - 2026-06-16
- Fix: Corrected syntax arrays in BIS functions to prevent silent UI crash


## [v1.18.14] - 2026-06-16
- Fix: Dynamically query HVT tasks from engine instead of broken array


## [v1.18.13] - 2026-06-16
- Fix: Salted HVT task IDs to prevent diag_tickTime collisions


## [v1.18.12] - 2026-06-16
- Fix: Intercept Enter key to prevent dialog closure


## [v1.18.11] - 2026-06-16
- Fix: Repatched SQF sanitization and Python parser


## [v1.18.10] - 2026-06-16
- Fix: Registered ticketing functions inside CfgFunctions to bypass remoteExec packet dropping (Closes #76)


## [v1.18.9] - 2026-06-15
- Fix: Refactored HVT UI to use pure public string array instead of HashMaps


## [v1.18.8] - 2026-06-15
- Fix: Refactored HVT UI to parse A3M_ActiveTasks HashMap directly to bypass native array assignment blindspots


## [v1.18.7] - 2026-06-15
- Fix: HVT UI empty list bug caused by Arma 3 native uppercase conversion


## [v1.18.6] - 2026-06-15
- Fix: Vcom AI Module Overhaul


## [v1.18.5] - 2026-06-15
- Fix: HVT logic completely rewritten for robust JIP network handling


## [v1.18.4] - 2026-06-14
- Fix: Camping time skip blocked by RemoteExec


## [v1.18.3] - 2026-06-14
- Fix: Server regexReplace crash in Ticket Logger


## [v1.18.2] - 2026-06-14
- Fix: Ticketing DB Dependency Removed (Closes #73)


## [v1.18.1] - 2026-06-14
- Fix: Ticket Dialog Class Inheritance


## [v1.18.0] - 2026-06-14
- Feature: In-Game Ticketing Pipeline (Closes #70)


## [v1.17.1] - 2026-06-14
- Fix: Track Generic Stat Script


## [v1.17.0] - 2026-06-14
- Feature: Batch Stat Tracking & Drone Mechanics


## [v1.16.1] - 2026-06-14
- Fix: Track Medical Hero Script


## [v1.16.0] - 2026-06-14
- Feature: Advanced Player Dossier Stats


## [v1.15.1] - 2026-06-14
- Fix: Add missing transaction logger file


## [v1.15.0] - 2026-06-14
- Feature: Log vehicle purchases to ledger


## [v1.14.1] - 2026-06-14
- Fix: Player Card Name Clipping


## [v1.14.0] - 2026-06-14
- Feature: Add Squad Stats to UI


## [v1.13.3] - 2026-06-14
- Fix: Synchronize A3M_ActiveTasks globally


## [v1.13.2] - 2026-06-14
- Fix: Synchronize AI Stand Down dismounts


## [v1.13.1] - 2026-06-14
- Fix: Patch Supply Drop execution


## [v1.13.0] - 2026-06-14
- Feature: Add Set Camp ACE action


## [v1.12.0] - 2026-06-14
- Feature: Implement Dynamic Stock Shortages


## [v1.11.0] - 2026-06-14
- Feature: Add ACE Gift Vehicle and Renounce Vehicle Ownership


## [v1.10.0] - 2026-06-14
- Feature: Add ACE Gift Vehicle and Renounce Vehicle Ownership


## [v1.9.2] - 2026-06-14
- Fix: Force absolute over-abundance for ALiVE CS ammo limits


## [v1.9.1] - 2026-06-14
- Fix: Corrected ALiVE Artillery CS Ammo Limits


## [v1.9.0] - 2026-06-14
- Feature: Critical Infrastructure Penalties


## [v1.8.2] - 2026-06-14
- Fix: HG Vehicle Shop Bank Button


## [v1.8.1] - 2026-06-14
- Fix: Restore Interrogation dynamicText


## [v1.8.0] - 2026-06-14
- Feature: Interrogation Intel Lettering


## [v1.7.2] - 2026-06-14
- Fix: Re-linked Shop to Mercenary Initializer


## [v1.7.1] - 2026-06-14
- Fix: Minimal Paradrop Bug Tweak


## [v1.7.0] - 2026-06-14
- Feature: Styled A3M Auto-Save Notification


## [v1.6.0] - 2026-06-14
- Feature: Grad Store 3-Column UI overhaul


## [v1.5.22] - 2026-06-14
- Fix: Overhaul mercenary paradrop physics and cleanup logic


## [v1.5.21] - 2026-06-14
- Fix: Cvehicles syntax error


## [v1.5.20] - 2026-06-14
- Fix: Turn AI chatter back on


## [v1.5.19] - 2026-06-13
- Fix: Separate Independent Supply Drops tab


## [v1.5.18] - 2026-06-13
- Fix: Revert Turret Drops UI separation


## [v1.5.17] - 2026-06-13
- Fix: Move Turret Drops to separate tab


## [v1.5.16] - 2026-06-13
- Fix: Balance combat drone drop quantities


## [v1.5.15] - 2026-06-13
- Fix: Supply drop backpack parser


## [v1.5.14] - 2026-06-13
- Fix: Mercenary cloning and parachutes


## [v1.5.13] - 2026-06-13
- Fix: Garage and Spawning logic


## [v1.5.12] - 2026-06-13
- Fix: Arsenal contraband error on default weapons magazines


## [v1.5.11] - 2026-06-12
- Fix: Arsenal pricing omitting magazines and weapon attachments


## [v1.5.10] - 2026-06-12
- Fix: Free items in HG Shops due to lbValue failure


## [v1.5.9] - 2026-06-12
- Fix: Escaped ampersands in Map Diary


## [v1.5.8] - 2026-06-12
- Fix: HG Shops pricing and HUD deductions


## [v1.5.7] - 2026-06-12
- Fix: Player Dossier UI colors and navigation


## [v1.5.6] - 2026-06-12
- Fix: Structured text formatting bug


## [v1.5.5] - 2026-06-12
- Fix: Redo Field Manual in correct active directory


## [v1.5.4] - 2026-06-12
- Fix: Expand Field Manual with highly detailed documentation


## [v1.5.3] - 2026-06-12
- Fix: Add missing untracked field manual files


## [v1.5.2] - 2026-06-12
- Fix: Synchronize description.ext version


## [v1.5.1] - 2026-06-12
- Fix: Implement Field Manual UI, Map Diary, and Dossier Hotkey (Closes #19)


## [Bv8.94] - 2026-06-12
- Feature: Redesign Vehicle Shop UI and wire ATM integration natively
- Feature: Implement native A3M lightweight drone payload system
- Fix: Prevent camera glitch by awaiting absolute display destruction
- Fix: Resolve fatal arsenal trapdoor stacking leak
- Fix: Mirrored HG Vehicle Store config to exactly match GRAD Motorpool
- Fix: Remove duplicate colored vehicle variants from Master and HG stores
- Fix: Restore A3M player rank and condition progression logic
- Fix: Eradicate config/engine capitalization mismatches with toLower
- Fix: BI Arsenal UI camera collision when switching to HG Motorpool
- Fix: Synchronize UI percentages and remove outdated cargo hints
