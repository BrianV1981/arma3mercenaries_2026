import os

M_FILE = "/home/brian-vasquez/aim-a3m/workspace/issue-102/arma3mercenaries_2026.Altis/arma3mercenaries/briefing/initBriefing.sqf"
P_FILE = "/home/brian-vasquez/aim-a3m/workspace/issue-102/arma3mercenaries_2026.Altis/arma3mercenaries/player_profile/fn_openFieldManual.sqf"

sections = [
    {
        "title": "Welcome to Arma 3 Mercenaries",
        "m_text": """Welcome to <font color='#ffaa00'>Arma 3 Mercenaries (A3M)</font>!<br/><br/>
This server features custom MMO-style mechanics including a deeply persistent database, dynamic economies, player-built outposts, advanced ALiVE combat support, and AI mercenary management.<br/><br/>

<font color='#00aaff'>USING YOUR MAP:</font> There is a massive amount of data, POIs, and markers available on your map. You must <t color='#ffff00'>zoom in</t> to make sense of it all and find specific Quartermasters, ATMs, and Barracks.<br/><br/>

Please read through the tabs below to understand how to survive and thrive as a contractor.<br/><br/>
You can also press the <font color='#00aaff'>'P'</font> key at any time to open your Player Dossier for live stats, leaderboards, and quick guides.""",
        "p_text": """<t align='center' size='1.3' color='#ffaa00'>Welcome to Arma 3 Mercenaries</t><br/><br/>
<t size='0.75'>This server features custom MMO-style mechanics including a deeply persistent database, dynamic economies, player-built outposts, advanced ALiVE combat support, and AI mercenary management.</t><br/><br/>
<t size='0.75'><t color='#00aaff'>USING YOUR MAP:</t> There is a massive amount of data, POIs, and markers available on your map. You must <t color='#ffff00'>zoom in</t> to make sense of it all and find specific Quartermasters, ATMs, and Barracks.</t><br/>"""
    },
    {
        "title": "The Core Gameplay Loop",
        "m_text": """<font color='#ffaa00'>1. INTERROGATE FOR SEED MONEY</font><br/>
You deploy with default Squad Leader gear. Detain civilians and escort them to an Interrogation Point to process them for cash. You <t color='#ffff00'>MUST carry Zip Ties</t> for this.<br/><br/>

<font color='#ffaa00'>2. HIGH VALUE TARGETS (HVTs)</font><br/>
Keep doing interrogations until you uncover an HVT mission. These targets carry massive amounts of cash (up to 600,000 Cr trigger, 100k on body).<br/><br/>

<font color='#ffaa00'>3. PUSH TO FORT MAGA</font><br/>
With your wealth, recruit a squad and head to <t color='#ffff00'>Fort MAGA</t>. Use it as your primary staging area to push into hostile sectors.<br/><br/>

<font color='#ffaa00'>4. EXPAND and LOGISTICS</font><br/>
You cannot win with just infantry. Logistics and base building are <t color='#00ff00'>CENTRAL</t>. Use the Quartermaster's Grad Store to build Turrets, Mortars, and defenses.""",
        "p_text": """<t size='1.0' color='#55aaff'>The Core Gameplay Loop</t><br/>
<t size='0.75'>1. <t color='#ffffff'>INTERROGATE:</t> Detain civilians with Zip Ties and escort to an Interrogation Point for seed money.</t><br/>
<t size='0.75'>2. <t color='#ffffff'>HVTs:</t> Interrogations uncover HVT missions with massive payouts (up to 600k Cr).</t><br/>
<t size='0.75'>3. <t color='#ffffff'>FORT MAGA:</t> Recruit a squad and head to Fort MAGA as your staging area.</t><br/>
<t size='0.75'>4. <t color='#ffffff'>EXPAND:</t> Push into enemy territory, capture sectors, and build defenses using Logistics.</t><br/>"""
    },
    {
        "title": "Ranks and Progression",
        "m_text": """<font color='#ffaa00'>RANKS AND PAYCHECKS</font><br/>
There are 7 ranks. Ranking up increases paychecks, kill rewards, and unlocks Black Market discounts.<br/><br/>
• PRIVATE (Start)<br/>
• CORPORAL (1k)<br/>
• SERGEANT (1.5k)<br/>
• LIEUTENANT (2k)<br/>
• CAPTAIN (2.5k)<br/>
• MAJOR (3k)<br/>
• COLONEL (3.5k Max)""",
        "p_text": """<t size='1.0' color='#55aaff'>Ranks and Progression</t><br/>
<t size='0.75'>There are 7 ranks. Ranking up increases paychecks, kill rewards, and unlocks Black Market discounts.</t><br/>
<t size='0.75'>• PRIVATE (Start) | CORPORAL (1k) | SERGEANT (1.5k) | LIEUTENANT (2k) | CAPTAIN (2.5k) | MAJOR (3k) | COLONEL (3.5k Max)</t><br/>"""
    },
    {
        "title": "The Economy and Income",
        "m_text": """<font color='#ffaa00'>BANK VS. WALLET</font><br/>
Cash (Wallet) is used in the field and dropped on death. Bank funds are safely secured. Use ATMs to deposit!<br/><br/>

<font color='#ffaa00'>ALTERNATIVE MONEY</font><br/>
• <t color='#ffffff'>Vehicle Salvaging:</t> Use a toolkit on wrecks for massive payouts.<br/>
• <t color='#ffffff'>Looting and Fencing:</t> Sell commandeered weapons to the Black Market fence.<br/>
• <t color='#ffffff'>Sector Control:</t> Capture sectors for massive payouts every 10 seconds.<br/><br/>

<font color='#ffaa00'>PENALTIES AND FINES</font><br/>
Friendly Fire instantly docks your bank account and transfers funds to the victim.""",
        "p_text": """<t size='1.0' color='#55aaff'>The Economy and Income</t><br/>
<t size='0.75'>• <t color='#ffffff'>BANK VS. WALLET:</t> Cash is dropped on death. Always deposit at an ATM!</t><br/>
<t size='0.75'>• <t color='#ffffff'>ALTERNATIVE MONEY:</t> Salvage vehicles, fence weapons, and capture sectors.</t><br/>
<t size='0.75'>• <t color='#ffffff'>PENALTIES:</t> Friendly Fire instantly docks your bank account to pay the victim.</t><br/>"""
    },
    {
        "title": "Advanced Operations (HVTs)",
        "m_text": """<font color='#ffaa00'>INTERROGATIONS</font><br/>
Use ACE interact to zip-tie civilians/enemies. Escort to Interrogation Point (Alpha, Bravo, Charlie) to process them.<br/><br/>

<font color='#ffaa00'>PLAYER BOUNTIES</font><br/>
Place a financial bounty on another player's head via the Player Dossier ('P'). Whoever kills them claims the cash.""",
        "p_text": """<t size='1.0' color='#55aaff'>Advanced Operations</t><br/>
<t size='0.75'>• <t color='#ffffff'>INTERROGATIONS:</t> Escort zip-tied captives to Interrogation Points for cash and HVT intel.</t><br/>
<t size='0.75'>• <t color='#ffffff'>PLAYER BOUNTIES:</t> Place bounties on other players via the Player Dossier ('P').</t><br/>"""
    },
    {
        "title": "Death and Persistence",
        "m_text": """<font color='#ffaa00'>ABSOLUTE PERSISTENCE</font><br/>
Your exact inventory, active AI squad, garage, and world-placed fortifications/vehicles are saved continuously.<br/><br/>

<font color='#ffaa00'>WALLET AND FORTIFICATIONS DROP ON DEATH</font><br/>
Cash and your <t color='#ff0000'>entire physical fortification inventory</t> are dropped on your corpse! Build them before you push!<br/><br/>

<font color='#ffaa00'>2-HOUR GEAR RECOVERY</font><br/>
Your corpse and gear remain in the world for 2 HOURS. Recover them or they are lost permanently.""",
        "p_text": """<t size='1.0' color='#55aaff'>Death and Persistence</t><br/>
<t size='0.75'>• <t color='#ffffff'>ABSOLUTE PERSISTENCE:</t> Inventories, AI squads, and placed fortifications save continuously.</t><br/>
<t size='0.75'>• <t color='#ffffff'>WALLET &amp; FORTIFICATIONS:</t> Dropped physically on death. Build them or bank cash before pushing!</t><br/>
<t size='0.75'>• <t color='#ffffff'>2-HOUR RECOVERY:</t> Your corpse stays for 2 HOURS before items are permanently lost.</t><br/>"""
    },
    {
        "title": "Logistics, Survival, Medical",
        "m_text": """<font color='#ffaa00'>THE FOUR INVENTORIES</font><br/>
1. <t color='#ffffff'>Player Inventory:</t> Standard gear.<br/>
2. <t color='#ffffff'>Vehicle Inventory:</t> Standard trunk.<br/>
3. <t color='#ffffff'>ACE Cargo:</t> Physical crates/statics loaded inside vehicles.<br/>
4. <t color='#ffffff'>Fortification Inventory:</t> Massive capacity for walls/bunkers.<br/><br/>

<font color='#ffaa00'>SURVIVAL AND MEDICAL</font><br/>
You must drink Water to survive and cool off weapons. Med Centers are required to fully remove wounds. Your Health, Hunger, and Thirst levels save across restarts.<br/><br/>

<font color='#ffaa00'>REARMING AND MAINTENANCE</font><br/>
Buy a Vehicle Ammo Container for unlimited refills. Use Repair Centers or Repair Vehicles. Buy Gas Tanks to keep vehicles moving.""",
        "p_text": """<t size='1.0' color='#55aaff'>Logistics, Survival, Medical</t><br/>
<t size='0.75'>• <t color='#ffffff'>INVENTORIES:</t> Player (Standard), Vehicle (Standard), ACE Cargo (Statics), Fortifications (Walls/Bunkers).</t><br/>
<t size='0.75'>• <t color='#ffffff'>SURVIVAL:</t> Health, Hunger, and Thirst persist across restarts. Drink water to survive!</t><br/>
<t size='0.75'>• <t color='#ffffff'>MAINTENANCE:</t> Use Vehicle Ammo Containers to rearm, and Repair Centers for damage.</t><br/>"""
    },
    {
        "title": "Logistics and Base Building",
        "m_text": """<font color='#ffaa00'>GRAD FORTIFICATIONS</font><br/>
Purchase and construct massive custom FOBs via the Quartermaster Grad Store.<br/><br/>

<font color='#ffaa00'>PLAYER OUTPOSTS</font><br/>
Any fortifications you build are strictly persistent and survive server restarts. Build a base and stockpile your armory!""",
        "p_text": """<t size='1.0' color='#55aaff'>Base Building</t><br/>
<t size='0.75'>• <t color='#ffffff'>GRAD FORTIFICATIONS:</t> Purchase custom FOB materials from the Quartermaster.</t><br/>
<t size='0.75'>• <t color='#ffffff'>PLAYER OUTPOSTS:</t> Fortifications placed in the world are strictly persistent across restarts.</t><br/>"""
    },
    {
        "title": "Vehicle Ops and Garage",
        "m_text": """<font color='#ffaa00'>CLAIMING AND LOCKING</font><br/>
Use ACE Interact to 'Claim' vehicles/statics. Once claimed, you can Lock/Unlock and give keys.<br/><br/>

<font color='#ffaa00'>VEHICLE FLIP</font><br/>
Unlock the vehicle, then use ACE Interact to flip it.<br/><br/>

<font color='#ffaa00'>MOBILE RESPAWNS</font><br/>
Heavy transports and medical trucks can be set as permanent respawns.<br/><br/>

<font color='#ffaa00'>VIRTUAL GARAGE</font><br/>
Drive to a Garage zone to safely store vehicles with their exact damage, fuel, and inventory intact.<br/><br/>

<font color='#ffaa00'>A3M RADIO</font><br/>
Use ACE interact near vehicles to broadcast custom tunes.""",
        "p_text": """<t size='1.0' color='#55aaff'>Vehicle Ops and Garage</t><br/>
<t size='0.75'>• <t color='#ffffff'>CLAIMING &amp; LOCKING:</t> Use ACE Interact to Claim vehicles and share keys.</t><br/>
<t size='0.75'>• <t color='#ffffff'>VIRTUAL GARAGE:</t> Store vehicles in Garage zones to save exact damage, fuel, and inventory.</t><br/>
<t size='0.75'>• <t color='#ffffff'>PERSISTENCE:</t> Claimed vehicles left in the world will load exactly where you left them.</t><br/>"""
    },
    {
        "title": "AI Mercenaries and Barracks",
        "m_text": """<font color='#ffaa00'>PURCHASING</font><br/>
AI are flown in via VTOL drop and instantly registered to your persistent profile.<br/><br/>

<font color='#ffaa00'>VIRTUAL BARRACKS</font><br/>
'Stow' active mercenaries (within 50m) to safely store them, or 'Deploy' offline ones.<br/><br/>

<font color='#ffaa00'>SQUAD MANAGEMENT</font><br/>
Press 'P' to manage group functions and track active members via the Player Dossier.<br/><br/>

<font color='#ffaa00'>SERVER RESTARTS</font><br/>
Actively deployed AI will spawn safely handcuffed/captive on restart. Use ACE Interaction to 'Mobilize' them.""",
        "p_text": """<t size='1.0' color='#55aaff'>AI Mercenaries and Barracks</t><br/>
<t size='0.75'>• <t color='#ffffff'>PURCHASING:</t> AI VTOL drop in and bind to your persistent profile.</t><br/>
<t size='0.75'>• <t color='#ffffff'>BARRACKS:</t> 'Stow' or 'Deploy' mercenaries using Barracks terminals.</t><br/>
<t size='0.75'>• <t color='#ffffff'>RESTARTS:</t> Deployed AI will spawn handcuffed on restart to protect them. 'Mobilize' them via ACE.</t><br/>"""
    },
    {
        "title": "Drones and Aerial Payloads",
        "m_text": """<font color='#ffaa00'>ATTACHING EXPLOSIVES</font><br/>
Use ACE Interact on AR-2 Darter UAVs to attach Satchels, C4, Grenades, etc.<br/><br/>

<font color='#ffaa00'>BOMBER MODE</font><br/>
Scroll wheel [DROP PAYLOAD] to drop a live-armed ballistic equivalent straight down.<br/><br/>

<font color='#ffaa00'>KAMIKAZE (FPV) MODE</font><br/>
Scroll wheel [ARM KAMIKAZE MODE]. The payload detonates instantly on impact.""",
        "p_text": """<t size='1.0' color='#55aaff'>Drones and Aerial Payloads</t><br/>
<t size='0.75'>• <t color='#ffffff'>EXPLOSIVES:</t> Use ACE Interact on Darter UAVs to attach Satchels and C4.</t><br/>
<t size='0.75'>• <t color='#ffffff'>BOMBER &amp; KAMIKAZE:</t> Drop payloads via scroll wheel or arm Kamikaze mode for instant impact detonation.</t><br/>"""
    },
    {
        "title": "Combat Support (ALiVE)",
        "m_text": """<font color='#ffaa00'>SUPPORT TERMINAL</font><br/>
Access the Constellis terminal in the safezone to purchase temporary CAS, Transport, or Artillery.<br/><br/>

<font color='#ffaa00'>COMMAND AND CONTROL</font><br/>
Command them via ALiVE tablet or laser designators.""",
        "p_text": """<t size='1.0' color='#55aaff'>Combat Support (ALiVE)</t><br/>
<t size='0.75'>• <t color='#ffffff'>CONSTELLIS TERMINAL:</t> Purchase CAS, Transport, or Artillery in the safezone.</t><br/>
<t size='0.75'>• <t color='#ffffff'>COMMAND:</t> Direct support units using the ALiVE tablet or laser designators.</t><br/>"""
    },
    {
        "title": "Asymmetric Threats and Factions",
        "m_text": """<font color='#ffaa00'>THE INSURGENCY</font><br/>
Syndikat (allied with NATO) and FIA (allied with CSAT) operate across the island. The local civilian population is generally hostile to PMC presence.<br/><br/>

<font color='#ffaa00'>HIDDEN THREATS</font><br/>
Watch for IEDs in trash/rubble, VBIEDs (abandoned civilian cars), and Suicide Bombers (shoot charging civilians!). You will lose XP for killing unarmed civilians.<br/><br/>

<font color='#ffaa00'>THE DYNAMIC ALiVE WAR</font><br/>
The war is completely dynamic. Sector control and military objectives are handled by the ALiVE engine.""",
        "p_text": """<t size='1.0' color='#ff5555'>Asymmetric Threats and Factions</t><br/>
<t size='0.75'>• <t color='#ffffff'>INSURGENCY:</t> Syndikat and FIA operate across the island. Civilians are often hostile.</t><br/>
<t size='0.75'>• <t color='#ffffff'>HIDDEN THREATS:</t> Watch for IEDs, VBIEDs, and Suicide Bombers. You lose XP for killing unarmed civilians!</t><br/>
<t size='0.75'>• <t color='#ffffff'>ALiVE WAR:</t> The entire war and frontlines are dynamically generated.</t>"""
    }
]

# Generate M Guide (initBriefing.sqf)
# Note: createDiaryRecord is LIFO, so we reverse the sections
m_content = '''/*
    A3M Map Diary Briefings
    Injects categorized tabs into the Map Screen (M)
*/

if (!hasInterface) exitWith {};

// Create the main category tab (Subject)
player createDiarySubject ["a3m_field_manual", "A3M Field Manual"];

// Note: createDiaryRecord is LIFO (Last In, First Out). 
// The last one created appears at the TOP of the list.

'''

for sec in reversed(sections):
    title = sec['title']
    body = sec['m_text']
    m_content += f'player createDiaryRecord ["a3m_field_manual", ["{title}", \n"\n{body}\n"\n]];\n\n'

with open(M_FILE, "w") as f:
    f.write(m_content)


# Generate P Guide (fn_openFieldManual.sqf)
p_content = '''/*
    A3M_fnc_openFieldManual
    Initializes and populates the Player Guides / Field Manual dialog.
*/
disableSerialization;
createDialog "A3M_FieldManualDialog";
waitUntil {!isNull (findDisplay 7030)};

private _display = findDisplay 7030;
private _content = _display displayCtrl 7031;

private _text = "
'''

for sec in sections:
    body = sec['p_text']
    p_content += f"{body}\n<br/>\n"

p_content += '''";

_content ctrlSetStructuredText parseText _text;
'''

with open(P_FILE, "w") as f:
    f.write(p_content)

print("Generated both guides successfully.")
