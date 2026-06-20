/*
    A3M Map Diary Briefings
    Injects categorized tabs into the Map Screen (M)
*/

if (!hasInterface) exitWith {};

// Create the main category tab (Subject)
player createDiarySubject ["a3m_field_manual", "A3M Field Manual"];

// Note: createDiaryRecord is LIFO (Last In, First Out). 
// The last one created appears at the TOP of the list.

player createDiaryRecord ["a3m_field_manual", ["The 3 Inventory Systems", 
"
<font color='#ffaa00'>1. FORTIFICATION</font><br/>
Holds unbuilt construction items (walls, bunkers). Has massive space limits.<br/><br/>
<font color='#ffaa00'>2. ACE CARGO</font><br/>
Used to haul physically built objects (like crates or statics) inside vehicles.<br/><br/>
<font color='#ffaa00'>3. NORMAL</font><br/>
Your standard player backpack and default vehicle trunks for guns, ammo, and cash.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Logistics, Survival, and Medical", 
"
<font color='#ffaa00'>REARMING</font><br/>
The cheapest option is the Vehicle Ammo Container from Logistics—unlimited refills for vehicles, turrets, mortars.<br/><br/>
<font color='#ffaa00'>MAINTENANCE</font><br/>
Use a Repair Center or Repair Vehicle. Buy a Gas Tank to keep big vehicles fueled and moving.<br/><br/>
<font color='#ffaa00'>SURVIVAL</font><br/>
You must drink Water to survive and cool off weapons. Med Centers are required to fully remove wounds.<br/><br/>
<font color='#ffaa00'>ESSENTIAL GEAR</font><br/>
You MUST carry <t color='#ffff00'>Zip Ties</t> for detaining civilians (Interrogations) and forcing AI onto static turrets! Also carry basic ACE Medical gear.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Ranks and Progression", 
"
<font color='#ffaa00'>RANKS AND REWARDS</font><br/>
There are 7 ranks. Ranking up increases paychecks, kill rewards, and unlocks Black Market discounts.<br/>
• PRIVATE (Start) | CORPORAL (1k) | SERGEANT (1.5k) | LIEUTENANT (2k) | CAPTAIN (2.5k) | MAJOR (3k) | COLONEL (3.5k Max)
"
]];

player createDiaryRecord ["a3m_field_manual", ["Welcome", 
"
Welcome to <font color='#ffaa00'>Arma 3 Mercenaries (A3M)</font>!<br/><br/>
This server features custom MMO-style mechanics including a deeply persistent database, dynamic economies, player-built outposts, advanced ALiVE combat support, and AI mercenary management.<br/><br/>

<font color='#00aaff'>USING YOUR MAP:</font> There is a massive amount of data, POIs, and markers available on your map. You must <t color='#ffff00'>zoom in</t> to make sense of it all and find specific Quartermasters, ATMs, and Barracks.<br/><br/>

Please read through the tabs below to understand how to survive and thrive as a contractor.<br/><br/>
You can also press the <font color='#00aaff'>'P'</font> key at any time to open your Player Dossier for live stats, leaderboards, and quick guides.
"
]];

player createDiaryRecord ["a3m_field_manual", ["The Core Gameplay Loop", 
"
<font color='#ffaa00'>1. INTERROGATE FOR SEED MONEY</font><br/>
You will deploy with a default set of Squad Leader gear. Your very first objective is to detain civilians and escort them to an Interrogation Point. Process them to earn cash.<br/><br/>

<font color='#ffaa00'>2. HIGH VALUE TARGETS (HVTs)</font><br/>
Keep doing interrogations until you uncover an HVT mission. These targets carry massive amounts of cash. Once you have a large bankroll from interrogations and HVTs, you will be strong enough to begin your military campaign.<br/><br/>

<font color='#ffaa00'>3. PUSH TO FORT MAGA</font><br/>
With your newfound wealth, recruit a squad and head to <t color='#ffff00'>Fort MAGA</t>. Defend this sector, build it up, and use it as your primary staging area to push into other hostile sectors across the island.<br/><br/>

<font color='#ffaa00'>4. LOGISTICS &amp; BASE BUILDING ARE CENTRAL</font><br/>
You cannot win this war with just infantry. Logistics and base building are <t color='#00ff00'>CENTRAL</t> to taking and holding areas. The A3M logistics system, especially when combined with ACE Cargo, is incredibly deep. Use the Quartermaster's Grad Store menu to purchase and build Turrets, Mortars, heavy weapons, ammo supplies, and defensive walls so you have a place to fall back, regroup, and rearm during heavy assaults!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Advanced Operations (HVTs)", 
"
<font color='#ffaa00'>INTERROGATIONS</font><br/>
Use your ACE interact menu to zip-tie and detain civilians or enemies. Escort them to an 'Interrogation Point' (Alpha, Bravo, Charlie) to process them. This is how you generate your initial seed money. The process is fully automated once they are brought to the interrogation desk.<br/><br/>

<font color='#ffaa00'>HIGH VALUE TARGETS (HVTs)</font><br/>
During interrogations, there is a chance you will uncover special intelligence that triggers an HVT mission. These are the crown jewels of the A3M economy.<br/>
The payout for triggering the HVT intel alone is massive (up to 600,000 Cr), and tracking down the physical HVT guarantees you will find at least 100,000 Cr physically on their body. Happy hunting.<br/><br/>

<font color='#ffaa00'>PLAYER BOUNTIES</font><br/>
Got a grudge? Place a financial bounty on another player's head using the Player Dossier (Press 'P'). Whoever kills them claims the cash instantly.
"
]];

player createDiaryRecord ["a3m_field_manual", ["The Economy and Alternative Income", 
"
<font color='#ffaa00'>BANK VS. WALLET</font><br/>
You have two separate balances: Cash (Wallet) and Bank. Cash is used for transactions in the field and is dropped on death. Bank funds are safely secured. Use ATMs to deposit your cash!<br/><br/>

<font color='#ffaa00'>ALTERNATIVE MONEY MAKERS</font><br/>
Don't just rely on interrogations! There are many ways to build your empire:<br/>
• <t color='#ffffff'>Vehicle Salvaging:</t> Find destroyed vehicle wrecks and use a toolkit to salvage them for massive resource payouts.<br/>
• <t color='#ffffff'>Looting and Fencing:</t> Strip weapons and gear from dead enemies. You can sell these commandeered weapons to the Black Market fence for pure profit.<br/>
• <t color='#ffffff'>Sector Control:</t> The deeper you push into enemy territory, the higher the payouts. Capture and hold sectors to earn massive payouts every 10 seconds.<br/><br/>

<font color='#ffaa00'>PENALTIES AND FINES</font><br/>
Watch your fire! Friendly Fire incidents will instantly dock your bank account and transfer those funds directly to the victim as compensation.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Death and Persistence", 
"
<font color='#ffaa00'>ABSOLUTE PERSISTENCE</font><br/>
The server runs on a custom SQLite backend. Your exact physical inventory, your active AI squad, their individual loadouts, your garage, and all world-placed fortifications/vehicles are saved continuously.<br/><br/>

<font color='#ffaa00'>ACE MEDICAL AND SURVIVAL</font><br/>
A3M uses full ACE Medical integration. Furthermore, your body's physical state is completely persistent. Your exact Health, Hunger, and Thirst levels are saved to the database. You must actively manage your nutrition and hydration, or you will starve across server restarts!<br/><br/>

<font color='#ffaa00'>YOUR WALLET &amp; FORTIFICATIONS DROP ON DEATH</font><br/>
Any loose cash (Cr) carried in your inventory, <t color='#ff0000'>AS WELL AS your entire physical fortification inventory</t>, is dropped physically on your corpse when you die. Always deposit your money into an ATM, and build your fortifications before pushing into dangerous areas!<br/><br/>

<font color='#ffaa00'>2-HOUR GEAR RECOVERY</font><br/>
When you die, a red marker appears on the map. Your corpse and gear will remain in the world for exactly 2 HOURS. If you do not recover your items before the timer expires, they are lost permanently.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Asymmetric Threats and Factions", 
"
<font color='#ffaa00'>THE INSURGENCY</font><br/>
This is not just a conventional war. There are two embedded asymmetric factions operating across the island:<br/>
• <t color='#ffffff'>Syndikat:</t> A local cartel allied with NATO forces.<br/>
• <t color='#ffffff'>FIA:</t> A rebel paramilitary force allied with CSAT/OPFOR.<br/><br/>

<font color='#ffaa00'>THE LOCAL POPULATION</font><br/>
Do not expect a warm welcome. The local civilian population is generally hostile to PMC presence. Be extremely careful when operating in populated areas.<br/><br/>

<font color='#ffaa00'>HIDDEN THREATS</font><br/>
The roads and towns are rigged. You must constantly scan for:<br/>
• <t color='#ffffff'>IEDs:</t> Improvised Explosive Devices hidden in trash, rubble, or along main supply routes.<br/>
• <t color='#ffffff'>VBIEDs:</t> Vehicle-Borne IEDs. Any abandoned civilian vehicle could be a trap.<br/>
• <t color='#ffffff'>Suicide Bombers:</t> Hostile locals who will rush your position and detonate. Shoot to kill if a civilian charges you!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Drones and Aerial Payloads", 
"
<font color='#ffaa00'>ATTACHING EXPLOSIVES</font><br/>
Any standard AR-2 Darter UAV can be weaponized. Using your ACE Interaction menu on a drone, you can attach explosives directly from your inventory. The drone supports Satchel Charges, Demo Charges (C4), Hand Grenades, 40mm HE Shells, and ACE_M14 Incendiary Grenades.<br/><br/>

<font color='#ffaa00'>BOMBER MODE</font><br/>
While piloting the UAV, use your scroll wheel to select <t color='#ff0000'>[DROP PAYLOAD]</t>. This will instantly drop a massive, live-armed ballistic equivalent of your explosive (e.g. C4 drops a heavy rocket explosion, Satchels drop a massive GBU, and M14s simulate a White Phosphorus artillery blast) straight down. It detonates instantly on impact.<br/><br/>

<font color='#ffaa00'>KAMIKAZE (FPV) MODE</font><br/>
Alternatively, once a payload is attached, pilots can select <t color='#ff8c00'>[ARM KAMIKAZE MODE]</t> from their scroll wheel. This locks the payload to the drone. The exact millisecond the drone crashes into a target, hits a wall, or is shot out of the sky, the massive payload will detonate instantly. An emergency <t color='#ffa500'>[DETONATE KAMIKAZE]</t> action is also provided for manual mid-airbursts.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Vehicle Operations and Garage", 
"
<font color='#ffaa00'>CLAIMING AND LOCKING</font><br/>
Use your ACE Interaction menu on any vehicle or static weapon to 'Claim' it. Once claimed, you can Lock/Unlock it and give keys to other players. Only the owner or key-holders can access the inventory or driver seat.<br/><br/>

<font color='#ffaa00'>VEHICLE FLIP</font><br/>
If your vehicle rolls over, you can flip it back onto its wheels using your ACE Interaction menu. <t color='#ff0000'>Note:</t> You must unlock the vehicle first before the system will allow you to flip it.<br/><br/>

<font color='#ffaa00'>MOBILE RESPAWNS</font><br/>
Heavy transport vehicles, medical trucks, and certain helicopters have a specialized ACE Action to 'Set Mobile Respawn'. Triggering this turns the vehicle into a permanent respawn point for your faction.<br/><br/>

<font color='#ffaa00'>CUSTOM A3M RADIO</font><br/>
When near or inside any vehicle, you can use the ACE Interaction menu to open the custom <t color='#00aaff'>A3M Radio</t>. This jukebox system allows you to broadcast custom tunes directly from the vehicle.<br/><br/>

<font color='#ffaa00'>VIRTUAL GARAGE</font><br/>
Drive your vehicle to a designated Garage zone (marked on map) to safely store it. Storing a vehicle saves its exact damage state, fuel, and entire physical inventory securely in the database.<br/><br/>

<font color='#ffaa00'>OPEN WORLD PERSISTENCE</font><br/>
Any player-owned vehicle left out on the battlefield is persistent! When the server restarts, your claimed vehicles and static weapons will load exactly where you left them.
"
]];

player createDiaryRecord ["a3m_field_manual", ["AI Mercenaries and Barracks", 
"
<font color='#ffaa00'>PURCHASING RECRUITS</font><br/>
When you buy an AI Mercenary, they are physically flown in via VTOL drop and parachute down to your location. They are instantly registered to your persistent database profile.<br/><br/>

<font color='#ffaa00'>THE VIRTUAL BARRACKS</font><br/>
Access the Virtual Barracks via terminals to manage your active squad. You can 'Stow' an active mercenary to safely store them in the database (they must be alive and within 50 meters). You can also 'Deploy' offline mercenaries directly to your position.<br/><br/>

<font color='#ffaa00'>SQUAD MANAGEMENT (P KEY)</font><br/>
Press the <t color='#ffff00'>'P'</t> key to open your Player Dossier, and click the 'My Squad' button. From this custom UI, you can manage your group functions, track your active AI squad members, and monitor their status in the field.<br/><br/>

<font color='#ffaa00'>SERVER RESTARTS AND MOBILIZATION</font><br/>
When the server restarts, any AI squad members that were actively deployed with you will spawn back in safely handcuffed and set to captive. This is a fail-safe to prevent them from dying while the server loads. Simply approach them and use your ACE Interaction menu to 'Mobilize' them and return them to combat readiness!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Logistics and Base Building", 
"
<font color='#ffaa00'>THE FOUR INVENTORIES</font><br/>
Logistics in A3M are deep and completely physical. You have four distinct inventories you must manage:<br/>
1. <t color='#ffffff'>Player Inventory:</t> Your personal gear and weapons.<br/>
2. <t color='#ffffff'>Vehicle Inventory:</t> The physical trunk space of your vehicle for gear.<br/>
3. <t color='#ffffff'>ACE Cargo:</t> Used to load physical crates, spare tires, and heavy items into vehicles.<br/>
4. <t color='#ffffff'>Fortification Inventory:</t> A specialized inventory system for building materials, walls, and bunkers that can be stored on players or in vehicles.<br/><br/>

<font color='#ffaa00'>GRAD FORTIFICATIONS</font><br/>
You can purchase and construct massive custom Forward Operating Bases (FOBs). Logistics can include everything needed to sustain a battle: gas, ammo crates, turrets, mortars, massive bunkers, walls, and tank traps. View the Grad Store menu at the Quartermaster for the full catalog.<br/><br/>

<font color='#ffaa00'>PLAYER OUTPOSTS</font><br/>
Any fortifications you build and place in the world are strictly persistent. They will survive server restarts. Build a base and stockpile your armory!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Combat Support (ALiVE)", 
"
<font color='#ffaa00'>THE ALiVE NETWORK</font><br/>
We utilize the advanced ALiVE Combat Support system. This is a highly robust, shared, and paid per-faction support network.<br/><br/>

<font color='#ffaa00'>CALLING IN SUPPORT</font><br/>
Access the Constellis Combat Support Terminal in the safezone to purchase temporary support assets. Once purchased, the asset is unlocked for your faction for the requested duration. You can command them using the ALiVE tablet or laser designators.<br/><br/>

<font color='#ffaa00'>SUPPORT TYPES</font><br/>
• <t color='#ffffff'>CAS (Close Air Support):</t> Call in Wipeouts, Black Wasps, or heavy attack helicopters to lay down devastating fire on painted targets.<br/>
• <t color='#ffffff'>TRANSPORT:</t> Need a lift? Call in a Ghost Hawk or heavy transport to fly you securely across the map, bypassing hostile territory.<br/>
• <t color='#ffffff'>ARTILLERY:</t> Rain fire on enemy compounds with pinpoint accuracy using high-explosive, illumination, or cluster munitions.
"
]];

player createDiaryRecord ["a3m_field_manual", ["The Dynamic ALiVE War", 
"
<font color='#ffaa00'>A LIVING, BREATHING BATTLEFIELD</font><br/>
The entire war raging across the island is completely dynamic. The only hand-placed units on the map are the player characters! Every other hostile, civilian, vehicle, and military patrol is dynamically generated and commanded by the ALiVE Military Commander engine.<br/><br/>

<font color='#ffaa00'>SECTOR CONTROL</font><br/>
The frontlines naturally shift as NATO and OPFOR clash. All Sector Control scripts and military objectives are entirely handled by ALiVE, creating a highly unpredictable and replayable warzone. You are just a contractor caught in the middle.
"
]];

