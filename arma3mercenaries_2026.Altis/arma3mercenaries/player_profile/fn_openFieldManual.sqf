/*
    A3M_fnc_openFieldManual
    Initializes and populates the Player Guides / Field Manual dialog.
*/
disableSerialization;
createDialog "A3M_FieldManualDialog";
waitUntil {!isNull (findDisplay 7030)};

private _display = findDisplay 7030;
private _content = _display displayCtrl 7031;

private _text = "
<t align='center' size='1.3' color='#ffaa00'>Welcome to Arma 3 Mercenaries</t><br/><br/>
<t size='0.75'>This server features custom MMO-style mechanics including a deeply persistent database, dynamic economies, player-built outposts, advanced ALiVE combat support, and AI mercenary management.</t><br/><br/>
<t size='0.75'><t color='#00aaff'>USING YOUR MAP:</t> There is a massive amount of data, POIs, and markers available on your map. You must <t color='#ffff00'>zoom in</t> to make sense of it all and find specific Quartermasters, ATMs, and Barracks.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>The Core Gameplay Loop</t><br/>
<t size='0.75'>1. <t color='#ffffff'>INTERROGATE:</t> Detain civilians with Zip Ties and escort to an Interrogation Point for seed money.</t><br/>
<t size='0.75'>2. <t color='#ffffff'>HVTs:</t> Interrogations uncover HVT missions with massive payouts (up to 600k Cr).</t><br/>
<t size='0.75'>3. <t color='#ffffff'>FORT MAGA:</t> Recruit a squad and head to Fort MAGA as your staging area.</t><br/>
<t size='0.75'>4. <t color='#ffffff'>EXPAND:</t> Push into enemy territory, capture sectors, and build defenses using Logistics.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>Ranks and Progression</t><br/>
<t size='0.75'>There are 7 ranks. Ranking up increases paychecks, kill rewards, and unlocks Black Market discounts.</t><br/>
<t size='0.75'>• PRIVATE (Start) | CORPORAL (1k) | SERGEANT (1.5k) | LIEUTENANT (2k) | CAPTAIN (2.5k) | MAJOR (3k) | COLONEL (3.5k Max)</t><br/>
<br/>
<t size='1.0' color='#55aaff'>The Economy and Income</t><br/>
<t size='0.75'>• <t color='#ffffff'>BANK VS. WALLET:</t> Cash is dropped on death. Always deposit at an ATM!</t><br/>
<t size='0.75'>• <t color='#ffffff'>ALTERNATIVE MONEY:</t> Salvage vehicles, fence weapons, and capture sectors.</t><br/>
<t size='0.75'>• <t color='#ffffff'>PENALTIES:</t> Friendly Fire instantly docks your bank account to pay the victim.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>Advanced Operations</t><br/>
<t size='0.75'>• <t color='#ffffff'>INTERROGATIONS:</t> Escort zip-tied captives to Interrogation Points for cash and HVT intel.</t><br/>
<t size='0.75'>• <t color='#ffffff'>PLAYER BOUNTIES:</t> Place bounties on other players via the Player Dossier ('P').</t><br/>
<br/>
<t size='1.0' color='#55aaff'>Death and Persistence</t><br/>
<t size='0.75'>• <t color='#ffffff'>ABSOLUTE PERSISTENCE:</t> Inventories, AI squads, and placed fortifications save continuously.</t><br/>
<t size='0.75'>• <t color='#ffffff'>WALLET &amp; FORTIFICATIONS:</t> Dropped physically on death. Build them or bank cash before pushing!</t><br/>
<t size='0.75'>• <t color='#ffffff'>2-HOUR RECOVERY:</t> Your corpse stays for 2 HOURS before items are permanently lost.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>Logistics, Survival, Medical</t><br/>
<t size='0.75'>• <t color='#ffffff'>INVENTORIES:</t> Player (Standard), Vehicle (Standard), ACE Cargo (Statics), Fortifications (Walls/Bunkers).</t><br/>
<t size='0.75'>• <t color='#ffffff'>SURVIVAL:</t> Health, Hunger, and Thirst persist across restarts. Drink water to survive!</t><br/>
<t size='0.75'>• <t color='#ffffff'>MAINTENANCE:</t> Use Vehicle Ammo Containers to rearm, and Repair Centers for damage.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>Base Building</t><br/>
<t size='0.75'>• <t color='#ffffff'>GRAD FORTIFICATIONS:</t> Purchase custom FOB materials from the Quartermaster.</t><br/>
<t size='0.75'>• <t color='#ffffff'>PLAYER OUTPOSTS:</t> Fortifications placed in the world are strictly persistent across restarts.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>Vehicle Ops and Garage</t><br/>
<t size='0.75'>• <t color='#ffffff'>CLAIMING &amp; LOCKING:</t> Use ACE Interact to Claim vehicles and share keys.</t><br/>
<t size='0.75'>• <t color='#ffffff'>VIRTUAL GARAGE:</t> Store vehicles in Garage zones to save exact damage, fuel, and inventory.</t><br/>
<t size='0.75'>• <t color='#ffffff'>PERSISTENCE:</t> Claimed vehicles left in the world will load exactly where you left them.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>AI Mercenaries and Barracks</t><br/>
<t size='0.75'>• <t color='#ffffff'>PURCHASING:</t> AI VTOL drop in and bind to your persistent profile.</t><br/>
<t size='0.75'>• <t color='#ffffff'>BARRACKS:</t> 'Stow' or 'Deploy' mercenaries using Barracks terminals.</t><br/>
<t size='0.75'>• <t color='#ffffff'>RESTARTS:</t> Deployed AI will spawn handcuffed on restart to protect them. 'Mobilize' them via ACE.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>Drones and Aerial Payloads</t><br/>
<t size='0.75'>• <t color='#ffffff'>EXPLOSIVES:</t> Use ACE Interact on Darter UAVs to attach Satchels and C4.</t><br/>
<t size='0.75'>• <t color='#ffffff'>BOMBER &amp; KAMIKAZE:</t> Drop payloads via scroll wheel or arm Kamikaze mode for instant impact detonation.</t><br/>
<br/>
<t size='1.0' color='#55aaff'>Combat Support (ALiVE)</t><br/>
<t size='0.75'>• <t color='#ffffff'>CONSTELLIS TERMINAL:</t> Purchase CAS, Transport, or Artillery in the safezone.</t><br/>
<t size='0.75'>• <t color='#ffffff'>COMMAND:</t> Direct support units using the ALiVE tablet or laser designators.</t><br/>
<br/>
<t size='1.0' color='#ff5555'>Asymmetric Threats and Factions</t><br/>
<t size='0.75'>• <t color='#ffffff'>INSURGENCY:</t> Syndikat and FIA operate across the island. Civilians are often hostile.</t><br/>
<t size='0.75'>• <t color='#ffffff'>HIDDEN THREATS:</t> Watch for IEDs, VBIEDs, and Suicide Bombers. You lose XP for killing unarmed civilians!</t><br/>
<t size='0.75'>• <t color='#ffffff'>ALiVE WAR:</t> The entire war and frontlines are dynamically generated.</t>
<br/>
";

_content ctrlSetStructuredText parseText _text;
