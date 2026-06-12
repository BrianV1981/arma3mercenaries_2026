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

<t size='1.2' color='#55aaff'>Logistics and Combat Support</t><br/>
<t size='0.9'>• <t color='#ffffff'>COMBAT SUPPORT:</t> Use the ALiVE CS terminals to purchase shared faction assets (CAS, Transport, Artillery) to dominate the battlefield.</t><br/>
<t size='0.9'>• <t color='#ffffff'>4-LAYER INVENTORY:</t> Manage your Player Inventory, Vehicle Inventory, ACE Cargo, and Fortification Inventory to build massive FOBs (Bunkers, Walls, Mortars).</t><br/><br/>

<t size='1.2' color='#ff5555'>Death and Persistence</t><br/>
<t size='0.9'>• <t color='#ffffff'>YOUR WALLET:</t> Cash in your inventory is <t color='#ff0000'>dropped on death</t>. Always deposit it in an ATM!</t><br/>
<t size='0.9'>• <t color='#ffffff'>PERSISTENCE:</t> Player stats, bank, vehicles (in garage), and placed fortifications are fully persistent across server restarts.</t><br/><br/>

<t align='center' size='1.0' color='#aaaaaa'>For a highly detailed breakdown of the Base Building, ALiVE Support, Garages, and Economy systems, please open your Map Screen (Press 'M') and view the 'A3M Field Manual' tabs in the top left corner.</t>
";

_content ctrlSetStructuredText parseText _text;
