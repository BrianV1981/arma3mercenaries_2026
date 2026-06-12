/*
    A3M Map Diary Briefings
    Injects categorized tabs into the Map Screen (M)
*/

if (!hasInterface) exitWith {};

// Create the main category tab (Subject)
player createDiarySubject ["a3m_field_manual", "A3M Field Manual"];

// Note: createDiaryRecord is LIFO (Last In, First Out). 
// The last one created appears at the TOP of the list.

player createDiaryRecord ["a3m_field_manual", ["Advanced Operations", 
"
<font size='16' color='#ffaa00'>SECTOR CONTROL</font><br/>
Push into enemy territory. Capture and hold sectors to earn massive payouts every 10 seconds. Base rewards scale up with consecutive payouts, multiplied by the sector's risk factor. After 6 consecutive payouts, the sector enters a 'Blocked' cooldown state to prevent infinite farming.<br/><br/>

<font size='16' color='#ffaa00'>PLAYER BOUNTIES</font><br/>
Got a grudge? Place a financial bounty on another player's head using the Player Dossier (Press 'P'). Whoever kills them claims the cash instantly.<br/><br/>

<font size='16' color='#ffaa00'>INTERROGATIONS & HVTs</font><br/>
High Value Targets (HVTs) are randomly generated across the map. You can also trigger missions by capturing specific enemies alive (use non-lethal methods) and delivering them to Enhanced Interrogation sites for massive payouts and intel.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Vehicle Operations & Garage", 
"
<font size='16' color='#ffaa00'>CLAIMING & LOCKING</font><br/>
Use your ACE Interaction menu on any vehicle or static weapon to 'Claim' it. Once claimed, you can Lock/Unlock it and give keys to other players. Only the owner or key-holders can access the inventory or driver seat.<br/><br/>

<font size='16' color='#ffaa00'>VIRTUAL GARAGE</font><br/>
Drive your vehicle to a designated Garage zone (marked on map) to safely store it. Storing a vehicle saves its exact damage state, fuel, and entire physical inventory securely in the database.<br/><br/>

<font size='16' color='#ffaa00'>OPEN WORLD PERSISTENCE</font><br/>
Any player-owned vehicle left out on the battlefield is persistent! When the server restarts, your claimed vehicles and static weapons will load exactly where you left them.
"
]];

player createDiaryRecord ["a3m_field_manual", ["AI Mercenaries & Barracks", 
"
<font size='16' color='#ffaa00'>PURCHASING RECRUITS</font><br/>
When you buy an AI Mercenary, they are physically flown in via VTOL drop and parachute down to your location. They are instantly registered to your persistent database profile.<br/><br/>

<font size='16' color='#ffaa00'>THE VIRTUAL BARRACKS</font><br/>
Access the Virtual Barracks via terminals to manage your active squad. You can 'Stow' an active mercenary to safely store them in the database (they must be alive and within 50 meters). You can also 'Deploy' offline mercenaries directly to your position.<br/><br/>

<font size='16' color='#ffaa00'>SERVER REstarts & MOBILIZATION</font><br/>
When the server restarts, any AI squad members that were actively deployed with you will spawn back in safely handcuffed and set to captive. This is a fail-safe to prevent them from dying while the server loads. Simply approach them and use your ACE Interaction menu to 'Mobilize' them and return them to combat readiness!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Logistics & Base Building", 
"
<font size='16' color='#ffaa00'>GRAD FORTIFICATIONS & ACE CARGO</font><br/>
A3M uses a highly robust logistics system. You can purchase fortifications, sandbags, bunkers, and static weapons and transport them to the frontlines using ACE Cargo in your vehicles.<br/><br/>

<font size='16' color='#ffaa00'>PLAYER OUTPOSTS & FOBs</font><br/>
Any fortifications you build and place in the world are strictly persistent. They will survive server restarts. You can construct massive custom Forward Operating Bases (FOBs) anywhere on the map.<br/><br/>

<font size='16' color='#ffaa00'>STORAGE CONTAINERS</font><br/>
You can purchase and place physical storage crates. These containers are fully persistent—meaning any weapons, ammo, or gear you put inside them will be saved securely across server reboots. Build a base and stockpile your armory!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Death & Persistence", 
"
<font size='16' color='#ffaa00'>ABSOLUTE PERSISTENCE</font><br/>
The server runs on a custom SQLite backend. Player stats, your exact physical inventory, your active AI squad, their individual loadouts, your garage, and all world-placed fortifications/vehicles are saved continuously.<br/><br/>

<font size='16' color='#ffaa00'>YOUR WALLET DROPS ON DEATH</font><br/>
Any loose cash (Cr) carried in your inventory is dropped physically on your corpse when you die. Always deposit your money into an ATM!<br/><br/>

<font size='16' color='#ffaa00'>2-HOUR GEAR RECOVERY</font><br/>
When you die, a red marker appears on the map. Your corpse and gear will remain in the world for exactly 2 HOURS. If you do not recover your items before the timer expires, they are lost permanently.
"
]];

player createDiaryRecord ["a3m_field_manual", ["The Economy & Banking", 
"
<font size='16' color='#ffaa00'>BANK VS. WALLET</font><br/>
You have two separate balances: Cash (Wallet) and Bank. Cash is used for physical transactions in the field and is dropped on death. Bank funds are safely secured. Use ATMs marked on the map to deposit your cash.<br/><br/>

<font size='16' color='#ffaa00'>KILL REWARDS</font><br/>
Standard faction kills instantly deposit randomized cash drops into your wallet. You can also search enemy corpses for bonus intel and loose cash.<br/><br/>

<font size='16' color='#ffaa00'>PENALTIES & FINES</font><br/>
Watch your fire! Friendly Fire incidents will instantly dock your bank account (e.g. -$10,000) and transfer those funds directly to the victim as compensation. Civilian casualties also incur heavy financial fines.
"
]];

player createDiaryRecord ["a3m_field_manual", ["The Core Loop", 
"
<font size='16' color='#ffaa00'>1. DEPLOY</font><br/>
Spawn at the safezone, use the Armory to gear up, and purchase a vehicle from the Quartermaster.<br/><br/>

<font size='16' color='#ffaa00'>2. ENGAGE</font><br/>
Travel to marked operation zones. Help NATO eliminate OPFOR and Independent combatants.<br/><br/>

<font size='16' color='#ffaa00'>3. PROFIT</font><br/>
Earn credits for every enemy killed. Capture sectors, complete HVT bounties, and recover physical gear from the battlefield.<br/><br/>

<font size='16' color='#ffaa00'>4. EXTRACT</font><br/>
Bring your cash back to an ATM to deposit it securely, and safely store your vehicle in the Garage before you log off or die.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Welcome", 
"
Welcome to <font color='#ffaa00'>Arma 3 Mercenaries (A3M)</font>!<br/><br/>
This server features custom MMO-style mechanics including a deeply persistent database, dynamic economies, player-built outposts, and AI mercenary management.<br/><br/>
Please read through the tabs below to understand how to survive and thrive as a contractor.<br/><br/>
You can also press the <font color='#00aaff'>'P'</font> key at any time to open your Player Dossier for live stats, leaderboards, and quick guides.
"
]];
