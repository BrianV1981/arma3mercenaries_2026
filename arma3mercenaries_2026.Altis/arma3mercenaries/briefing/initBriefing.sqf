/*
    A3M Map Diary Briefings
    Injects categorized tabs into the Map Screen (M)
*/

if (!hasInterface) exitWith {};

// Create the main category tab (Subject)
player createDiarySubject ["a3m_field_manual", "A3M Field Manual"];

// Note: createDiaryRecord is LIFO (Last In, First Out). 
// The last one created appears at the TOP of the list.

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

player createDiaryRecord ["a3m_field_manual", ["AI Mercenaries and Barracks", 
"
<font color='#ffaa00'>PURCHASING RECRUITS</font><br/>
When you buy an AI Mercenary, they are physically flown in via VTOL drop and parachute down to your location. They are instantly registered to your persistent database profile.<br/><br/>

<font color='#ffaa00'>THE VIRTUAL BARRACKS</font><br/>
Access the Virtual Barracks via terminals to manage your active squad. You can 'Stow' an active mercenary to safely store them in the database (they must be alive and within 50 meters). You can also 'Deploy' offline mercenaries directly to your position.<br/><br/>

<font color='#ffaa00'>SERVER RESTARTS AND MOBILIZATION</font><br/>
When the server restarts, any AI squad members that were actively deployed with you will spawn back in safely handcuffed and set to captive. This is a fail-safe to prevent them from dying while the server loads. Simply approach them and use your ACE Interaction menu to 'Mobilize' them and return them to combat readiness!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Vehicle Operations and Garage", 
"
<font color='#ffaa00'>CLAIMING AND LOCKING</font><br/>
Use your ACE Interaction menu on any vehicle or static weapon to 'Claim' it. Once claimed, you can Lock/Unlock it and give keys to other players. Only the owner or key-holders can access the inventory or driver seat.<br/><br/>

<font color='#ffaa00'>VIRTUAL GARAGE</font><br/>
Drive your vehicle to a designated Garage zone (marked on map) to safely store it. Storing a vehicle saves its exact damage state, fuel, and entire physical inventory securely in the database.<br/><br/>

<font color='#ffaa00'>OPEN WORLD PERSISTENCE</font><br/>
Any player-owned vehicle left out on the battlefield is persistent! When the server restarts, your claimed vehicles and static weapons will load exactly where you left them.
"
]];

player createDiaryRecord ["a3m_field_manual", ["The Economy and Alternative Income", 
"
<font color='#ffaa00'>BANK VS. WALLET</font><br/>
You have two separate balances: Cash (Wallet) and Bank. Cash is used for transactions in the field and is dropped on death. Bank funds are safely secured. Use ATMs to deposit your cash!<br/><br/>

<font color='#ffaa00'>ALTERNATIVE MONEY MAKERS</font><br/>
Don't just rely on interrogations! There are many ways to build your empire:<br/>
• <t color='#ffffff'>Vehicle Salvaging:</t> Find destroyed vehicle wrecks and use a toolkit to salvage them for massive resource payouts.<br/>
• <t color='#ffffff'>Looting & Fencing:</t> Strip weapons and gear from dead enemies. You can sell these commandeered weapons to the Black Market fence for pure profit.<br/>
• <t color='#ffffff'>Sector Control:</t> The deeper you push into enemy territory, the higher the payouts. Capture and hold sectors to earn massive payouts every 10 seconds.<br/><br/>

<font color='#ffaa00'>PENALTIES AND FINES</font><br/>
Watch your fire! Friendly Fire incidents will instantly dock your bank account and transfer those funds directly to the victim as compensation.
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

player createDiaryRecord ["a3m_field_manual", ["The Core Gameplay Loop", 
"
<font color='#ffaa00'>1. THE STARTER SECTOR</font><br/>
You will deploy into the world with a default set of Squad Leader gear. Your first objective is to head to <t color='#ffff00'>Fort MAGA</t>. This is the primary starter sector and the best staging area to hold and run your initial operations from.<br/><br/>

<font color='#ffaa00'>2. COMMANDEER GEAR</font><br/>
Keep your eyes peeled. While you start with basic gear, there are multiple ways to commandeer powerful weapons, armor, and supplies scattered around or held by hostiles.<br/><br/>

<font color='#ffaa00'>3. INTERROGATE FOR CASH</font><br/>
To generate your initial money, you must detain civilians and escort them to an Interrogation Point. Process them to earn cash and potentially uncover massive HVT missions.<br/><br/>

<font color='#ffaa00'>4. EXPAND & PROFIT</font><br/>
Once you have seed money, buy a vehicle, recruit AI mercenaries, build a Forward Operating Base using the logistics system, and push deeper into enemy territory where the sector payouts multiply!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Welcome", 
"
Welcome to <font color='#ffaa00'>Arma 3 Mercenaries (A3M)</font>!<br/><br/>
This server features custom MMO-style mechanics including a deeply persistent database, dynamic economies, player-built outposts, advanced ALiVE combat support, and AI mercenary management.<br/><br/>
Please read through the tabs below to understand how to survive and thrive as a contractor.<br/><br/>
You can also press the <font color='#00aaff'>'P'</font> key at any time to open your Player Dossier for live stats, leaderboards, and quick guides.
"
]];
