/*
    A3M Map Diary Briefings
    Injects categorized tabs into the Map Screen (M)
*/

if (!hasInterface) exitWith {};

// Create the main category tab (Subject)
player createDiarySubject ["a3m_field_manual", "A3M Field Manual"];

// Note: createDiaryRecord is LIFO (Last In, First Out). 
// The last one created appears at the TOP of the list.

player createDiaryRecord ["a3m_field_manual", ["Asymmetric Threats and Factions", 
"
<font color='#ffaa00'>THE INSURGENCY</font><br/>
Syndikat (allied with NATO) and FIA (allied with CSAT) operate across the island. The local civilian population is generally hostile to PMC presence.<br/><br/>

<font color='#ffaa00'>HIDDEN THREATS</font><br/>
Watch for IEDs in trash/rubble, VBIEDs (abandoned civilian cars), and Suicide Bombers (shoot charging civilians!). You will lose XP for killing unarmed civilians.<br/><br/>

<font color='#ffaa00'>THE DYNAMIC ALiVE WAR</font><br/>
The war is completely dynamic. Sector control and military objectives are handled by the ALiVE engine.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Combat Support (ALiVE)", 
"
<font color='#ffaa00'>SUPPORT TERMINAL</font><br/>
Access the Constellis terminal in the safezone to purchase temporary CAS, Transport, or Artillery.<br/><br/>

<font color='#ffaa00'>COMMAND AND CONTROL</font><br/>
Command them via ALiVE tablet or laser designators.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Drones and Aerial Payloads", 
"
<font color='#ffaa00'>ATTACHING EXPLOSIVES</font><br/>
Use ACE Interact on AR-2 Darter UAVs to attach Satchels, C4, Grenades, etc.<br/><br/>

<font color='#ffaa00'>BOMBER MODE</font><br/>
Scroll wheel [DROP PAYLOAD] to drop a live-armed ballistic equivalent straight down.<br/><br/>

<font color='#ffaa00'>KAMIKAZE (FPV) MODE</font><br/>
Scroll wheel [ARM KAMIKAZE MODE]. The payload detonates instantly on impact.
"
]];

player createDiaryRecord ["a3m_field_manual", ["AI Mercenaries and Barracks", 
"
<font color='#ffaa00'>PURCHASING</font><br/>
AI are flown in via VTOL drop and instantly registered to your persistent profile.<br/><br/>

<font color='#ffaa00'>VIRTUAL BARRACKS</font><br/>
'Stow' active mercenaries (within 50m) to safely store them, or 'Deploy' offline ones.<br/><br/>

<font color='#ffaa00'>SQUAD MANAGEMENT</font><br/>
Press 'P' to manage group functions and track active members via the Player Dossier.<br/><br/>

<font color='#ffaa00'>SERVER RESTARTS</font><br/>
Actively deployed AI will spawn safely handcuffed/captive on restart. Use ACE Interaction to 'Mobilize' them.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Vehicle Ops and Garage", 
"
<font color='#ffaa00'>CLAIMING AND LOCKING</font><br/>
Use ACE Interact to 'Claim' vehicles/statics. Once claimed, you can Lock/Unlock and give keys.<br/><br/>

<font color='#ffaa00'>VEHICLE FLIP</font><br/>
Unlock the vehicle, then use ACE Interact to flip it.<br/><br/>

<font color='#ffaa00'>MOBILE RESPAWNS</font><br/>
Heavy transports and medical trucks can be set as permanent respawns.<br/><br/>

<font color='#ffaa00'>VIRTUAL GARAGE</font><br/>
Drive to a Garage zone to safely store vehicles with their exact damage, fuel, and inventory intact.<br/><br/>

<font color='#ffaa00'>A3M RADIO</font><br/>
Use ACE interact near vehicles to broadcast custom tunes.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Logistics and Base Building", 
"
<font color='#ffaa00'>GRAD FORTIFICATIONS</font><br/>
Purchase and construct massive custom FOBs via the Quartermaster Grad Store.<br/><br/>

<font color='#ffaa00'>PLAYER OUTPOSTS</font><br/>
Any fortifications you build are strictly persistent and survive server restarts. Build a base and stockpile your armory!
"
]];

player createDiaryRecord ["a3m_field_manual", ["Logistics, Survival, Medical", 
"
<font color='#ffaa00'>THE FOUR INVENTORIES</font><br/>
1. <t color='#ffffff'>Player Inventory:</t> Standard gear.<br/>
2. <t color='#ffffff'>Vehicle Inventory:</t> Standard trunk.<br/>
3. <t color='#ffffff'>ACE Cargo:</t> Physical crates/statics loaded inside vehicles.<br/>
4. <t color='#ffffff'>Fortification Inventory:</t> Massive capacity for walls/bunkers.<br/><br/>

<font color='#ffaa00'>SURVIVAL AND MEDICAL</font><br/>
You must drink Water to survive and cool off weapons. Med Centers are required to fully remove wounds. Your Health, Hunger, and Thirst levels save across restarts.<br/><br/>

<font color='#ffaa00'>REARMING AND MAINTENANCE</font><br/>
Buy a Vehicle Ammo Container for unlimited refills. Use Repair Centers or Repair Vehicles. Buy Gas Tanks to keep vehicles moving.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Death and Persistence", 
"
<font color='#ffaa00'>ABSOLUTE PERSISTENCE</font><br/>
Your exact inventory, active AI squad, garage, and world-placed fortifications/vehicles are saved continuously.<br/><br/>

<font color='#ffaa00'>WALLET AND FORTIFICATIONS DROP ON DEATH</font><br/>
Cash and your <t color='#ff0000'>entire physical fortification inventory</t> are dropped on your corpse! Build them before you push!<br/><br/>

<font color='#ffaa00'>2-HOUR GEAR RECOVERY</font><br/>
Your corpse and gear remain in the world for 2 HOURS. Recover them or they are lost permanently.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Advanced Operations (HVTs)", 
"
<font color='#ffaa00'>INTERROGATIONS</font><br/>
Use ACE interact to zip-tie civilians/enemies. Escort to Interrogation Point (Alpha, Bravo, Charlie) to process them.<br/><br/>

<font color='#ffaa00'>PLAYER BOUNTIES</font><br/>
Place a financial bounty on another player's head via the Player Dossier ('P'). Whoever kills them claims the cash.
"
]];

player createDiaryRecord ["a3m_field_manual", ["The Economy and Income", 
"
<font color='#ffaa00'>BANK VS. WALLET</font><br/>
Cash (Wallet) is used in the field and dropped on death. Bank funds are safely secured. Use ATMs to deposit!<br/><br/>

<font color='#ffaa00'>ALTERNATIVE MONEY</font><br/>
• <t color='#ffffff'>Vehicle Salvaging:</t> Use a toolkit on wrecks for massive payouts.<br/>
• <t color='#ffffff'>Looting and Fencing:</t> Sell commandeered weapons to the Black Market fence.<br/>
• <t color='#ffffff'>Sector Control:</t> Capture sectors for massive payouts every 10 seconds.<br/><br/>

<font color='#ffaa00'>PENALTIES AND FINES</font><br/>
Friendly Fire instantly docks your bank account and transfers funds to the victim.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Ranks and Progression", 
"
<font color='#ffaa00'>RANKS AND PAYCHECKS</font><br/>
There are 7 ranks. Ranking up increases paychecks, kill rewards, and unlocks Black Market discounts.<br/><br/>
• PRIVATE (Start)<br/>
• CORPORAL (1k)<br/>
• SERGEANT (1.5k)<br/>
• LIEUTENANT (2k)<br/>
• CAPTAIN (2.5k)<br/>
• MAJOR (3k)<br/>
• COLONEL (3.5k Max)
"
]];

player createDiaryRecord ["a3m_field_manual", ["The Core Gameplay Loop", 
"
<font color='#ffaa00'>1. INTERROGATE FOR SEED MONEY</font><br/>
You deploy with default Squad Leader gear. Detain civilians and escort them to an Interrogation Point to process them for cash. You <t color='#ffff00'>MUST carry Zip Ties</t> for this.<br/><br/>

<font color='#ffaa00'>2. HIGH VALUE TARGETS (HVTs)</font><br/>
Keep doing interrogations until you uncover an HVT mission. These targets carry massive amounts of cash (up to 600,000 Cr trigger, 100k on body).<br/><br/>

<font color='#ffaa00'>3. PUSH TO FORT MAGA</font><br/>
With your wealth, recruit a squad and head to <t color='#ffff00'>Fort MAGA</t>. Use it as your primary staging area to push into hostile sectors.<br/><br/>

<font color='#ffaa00'>4. EXPAND and LOGISTICS</font><br/>
You cannot win with just infantry. Logistics and base building are <t color='#00ff00'>CENTRAL</t>. Use the Quartermaster's Grad Store to build Turrets, Mortars, and defenses.
"
]];

player createDiaryRecord ["a3m_field_manual", ["Welcome to Arma 3 Mercenaries", 
"
Welcome to <font color='#ffaa00'>Arma 3 Mercenaries (A3M)</font>!<br/><br/>
This server features custom MMO-style mechanics including a deeply persistent database, dynamic economies, player-built outposts, advanced ALiVE combat support, and AI mercenary management.<br/><br/>

<font color='#00aaff'>USING YOUR MAP:</font> There is a massive amount of data, POIs, and markers available on your map. You must <t color='#ffff00'>zoom in</t> to make sense of it all and find specific Quartermasters, ATMs, and Barracks.<br/><br/>

Please read through the tabs below to understand how to survive and thrive as a contractor.<br/><br/>
You can also press the <font color='#00aaff'>'P'</font> key at any time to open your Player Dossier for live stats, leaderboards, and quick guides.
"
]];

