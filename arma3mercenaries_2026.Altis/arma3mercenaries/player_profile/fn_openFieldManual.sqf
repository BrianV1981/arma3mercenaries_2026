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

<t size='1.0' color='#55aaff'>The Core Gameplay Loop</t><br/>
<t size='0.75'>1. <t color='#ffffff'>FORT MAGA:</t> You start with basic Squad Leader gear. Head to Fort MAGA, the best staging area to run initial operations.</t><br/>
<t size='0.75'>2. <t color='#ffffff'>INTERROGATIONS:</t> Detain civilians and escort them to an Interrogation Point. This is how you generate your initial seed money.</t><br/>
<t size='0.75'>3. <t color='#ffffff'>HVT MISSIONS:</t> Interrogations uncover intel triggering HVT missions yielding payouts up to 600k Cr and 100k Cr on their bodies.</t><br/>
<t size='0.75'>4. <t color='#ffffff'>EXPAND:</t> Push deeper into enemy territory to capture sectors for higher payouts, salvage vehicles, and fence looted weapons.</t><br/>

<t size='1.0' color='#55aaff'>Ranks and Progression</t><br/>
<t size='0.75'>There are 7 ranks. Ranking up increases paychecks, kill rewards, and unlocks Black Market discounts.</t><br/>
<t size='0.75'>• PRIVATE (Start) | CORPORAL (1k) | SERGEANT (1.5k) | LIEUTENANT (2k) | CAPTAIN (2.5k) | MAJOR (3k) | COLONEL (3.5k Max)</t><br/>

<t size='1.0' color='#55aaff'>Logistics, Survival, and Medical</t><br/>
<t size='0.75'>• <t color='#ffffff'>REARMING:</t> The cheapest option is the Vehicle Ammo Container from Logistics—unlimited refills for vehicles, turrets, mortars.</t><br/>
<t size='0.75'>• <t color='#ffffff'>MAINTENANCE:</t> Use a Repair Center or Repair Vehicle. Buy a Gas Tank to keep big vehicles fueled and moving.</t><br/>
<t size='0.75'>• <t color='#ffffff'>SURVIVAL:</t> You must drink Water to survive and cool off weapons. Med Centers are required to fully remove wounds.</t><br/>
<t size='0.75'>• <t color='#ffffff'>ESSENTIAL GEAR:</t> You MUST carry <t color='#ffff00'>Zip Ties</t> for detaining civilians (Interrogations) and forcing AI onto static turrets! Also carry basic ACE Medical gear.</t><br/>

<t size='1.0' color='#55aaff'>The 3 Inventory Systems</t><br/>
<t size='0.75'>1. <t color='#ffffff'>FORTIFICATION:</t> Holds unbuilt construction items (walls, bunkers). Has massive space limits.</t><br/>
<t size='0.75'>2. <t color='#ffffff'>ACE CARGO:</t> Used to haul physically built objects (like crates or statics) inside vehicles.</t><br/>
<t size='0.75'>3. <t color='#ffffff'>NORMAL:</t> Your standard player backpack and default vehicle trunks for guns, ammo, and cash.</t><br/>

<t size='1.0' color='#ff5555'>Asymmetric Threats and Penalties</t><br/>
<t size='0.75'>• <t color='#ffffff'>FACTIONS:</t> Syndikat (NATO) and FIA (CSAT) operate across the island. Watch for IEDs and VBIEDs!</t><br/>
<t size='0.75'>• <t color='#ffffff'>PENALTIES:</t> You will lose XP for dying, teamkilling, and killing unarmed civilians!</t><br/>
<t size='0.75'>• <t color='#ffffff'>YOUR WALLET:</t> Cash in your inventory is <t color='#ff0000'>dropped on death</t>. Always deposit it in an ATM!</t>

";

_content ctrlSetStructuredText parseText _text;
