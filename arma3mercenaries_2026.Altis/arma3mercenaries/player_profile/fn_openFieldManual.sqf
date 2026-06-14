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
<t align='center' size='1.5' color='#ffaa00'>Welcome to Arma 3 Mercenaries</t><br/><br/>

<t size='1.2' color='#55aaff'>The Core Gameplay Loop</t><br/>
<t size='0.9'>1. <t color='#ffffff'>FORT MAGA:</t> You start with basic Squad Leader gear. Head to Fort MAGA, the best staging area to run initial operations. Keep your eyes peeled to commandeer better gear!</t><br/>
<t size='0.9'>2. <t color='#ffffff'>INTERROGATIONS:</t> Detain civilians and escort them to an Interrogation Point. This is how you generate your initial seed money.</t><br/>
<t size='0.9'>3. <t color='#ffffff'>HVT MISSIONS:</t> Interrogations can uncover special intelligence. This triggers an HVT mission yielding massive payouts (up to 600k Cr) and the HVT themselves always carry at least 100k Cr physically!</t><br/>
<t size='0.9'>4. <t color='#ffffff'>EXPAND:</t> Push deeper into enemy territory to capture sectors for higher payouts, salvage vehicles, and fence looted weapons for pure profit.</t><br/><br/>

<t size='1.2' color='#55aaff'>Ranks and Progression</t><br/>
<t size='0.9'>There are 7 ranks. Ranking up increases your passive paycheck, boosts kill rewards, and unlocks massive discounts at the Black Market shops.</t><br/>
<t size='0.9'>• <t color='#ffffff'>PRIVATE:</t> Starting Rank</t><br/>
<t size='0.9'>• <t color='#ffffff'>CORPORAL:</t> Requires 1,000 XP</t><br/>
<t size='0.9'>• <t color='#ffffff'>SERGEANT:</t> Requires 1,500 XP</t><br/>
<t size='0.9'>• <t color='#ffffff'>LIEUTENANT:</t> Requires 2,000 XP</t><br/>
<t size='0.9'>• <t color='#ffffff'>CAPTAIN:</t> Requires 2,500 XP</t><br/>
<t size='0.9'>• <t color='#ffffff'>MAJOR:</t> Requires 3,000 XP</t><br/>
<t size='0.9'>• <t color='#ffffff'>COLONEL:</t> Requires 3,500 XP (Max Rank)</t><br/><br/>

<t size='1.2' color='#55aaff'>Logistics, Survival, & Medical</t><br/>
<t size='0.9'>Logistics are the key to staying alive and keeping your FOBs running. Make sure you load up before deploying!</t><br/>
<t size='0.9'>• <t color='#ffffff'>REARMING:</t> Turrets can be reloaded with loose ammo boxes, but the best method is a Vehicle Ammo Box or Ammo Vehicle. The cheapest option is the <t color='#00ff00'>Vehicle Ammo Container</t> from Logistics—it provides unlimited refills for nearby vehicles, turrets, and mortars.</t><br/>
<t size='0.9'>• <t color='#ffffff'>MAINTENANCE:</t> Use a Repair Center or Repair Vehicle to fix damaged assets. Buy a Gas Tank to keep big vehicles fueled and moving.</t><br/>
<t size='0.9'>• <t color='#ffffff'>SURVIVAL:</t> You must drink Water to survive and cool off weapons. Med Centers are required to fully remove wounds.</t><br/>
<t size='0.9'>• <t color='#ffffff'>ESSENTIAL GEAR:</t> Beyond basic weapons, you MUST carry <t color='#ffff00'>Zip Ties</t>. They are essential for detaining civilians (Interrogations) and physically forcing AI units onto static turrets/mortars! Also carry basic ACE Medical (Bandages, Morphine, Epi-pens, Splints, Blood bags).</t><br/><br/>

<t size='1.2' color='#55aaff'>The 3 Inventory Systems</t><br/>
<t size='0.9'>Everything you build or carry is persistent across server restarts, but there are three completely separate inventory types:</t><br/>
<t size='0.9'>1. <t color='#ffffff'>FORTIFICATION INVENTORY:</t> Holds unbuilt construction items (walls, bunkers). Has massive space limits.</t><br/>
<t size='0.9'>2. <t color='#ffffff'>ACE CARGO SYSTEM:</t> Used to haul physically built objects (like crates or statics) inside vehicles.</t><br/>
<t size='0.9'>3. <t color='#ffffff'>NORMAL INVENTORY:</t> Your standard player backpack and default vehicle trunks for guns, ammo, and cash.</t><br/><br/>

<t size='1.2' color='#ff5555'>Asymmetric Threats & Penalties</t><br/>
<t size='0.9'>• <t color='#ffffff'>FACTIONS:</t> Syndikat (allied w/ NATO) and FIA (allied w/ CSAT) operate across the island. Watch for IEDs and VBIEDs!</t><br/>
<t size='0.9'>• <t color='#ffffff'>PENALTIES:</t> You will lose XP for dying, teamkilling, and killing unarmed civilians!</t><br/>
<t size='0.9'>• <t color='#ffffff'>YOUR WALLET:</t> Cash in your inventory is <t color='#ff0000'>dropped on death</t>. Always deposit it in an ATM!</t><br/>
";

_content ctrlSetStructuredText parseText _text;
