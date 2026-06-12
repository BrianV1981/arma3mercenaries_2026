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
<t size='0.9'>1. <t color='#ffffff'>DEPLOY:</t> Spawn at the safezone, use the Armory to gear up, and purchase a vehicle from the Quartermaster.</t><br/>
<t size='0.9'>2. <t color='#ffffff'>ENGAGE:</t> Travel to marked operation zones. Help NATO eliminate OPFOR and Independent combatants.</t><br/>
<t size='0.9'>3. <t color='#ffffff'>PROFIT:</t> You earn credits (Cr) for every enemy killed. Check corpses for bonus cash and intel!</t><br/>
<t size='0.9'>4. <t color='#ffffff'>EXTRACT:</t> Bring your cash back to an ATM to deposit it safely before you die.</t><br/><br/>

<t size='1.2' color='#55aaff'>Advanced Operations</t><br/>
<t size='0.9'>• <t color='#ffffff'>SECTOR CONTROL:</t> Push into enemy territory. Capture and hold sectors to earn massive payouts every hour.</t><br/>
<t size='0.9'>• <t color='#ffffff'>BOUNTIES:</t> Got a grudge? Place a financial bounty on another player's head via the Player Dossier (P).</t><br/>
<t size='0.9'>• <t color='#ffffff'>INTERROGATIONS:</t> Capture specific enemies alive (use non-lethal methods) and deliver them to Enhanced Interrogation sites for massive payouts.</t><br/><br/>

<t size='1.2' color='#ff5555'>Death & Persistence</t><br/>
<t size='0.9'>• <t color='#ffffff'>YOUR WALLET:</t> Cash in your inventory is <t color='#ff0000'>dropped on death</t>. Always deposit it in an ATM!</t><br/>
<t size='0.9'>• <t color='#ffffff'>YOUR GEAR:</t> You have exactly <t color='#ffff00'>2 HOURS</t> to recover your gear from your corpse marker.</t><br/>
<t size='0.9'>• <t color='#ffffff'>PERSISTENCE:</t> Player stats, cash, bank, vehicles (in garage), and placed fortifications are fully persistent across server restarts.</t><br/><br/>

<t align='center' size='1.0' color='#aaaaaa'>For a highly detailed breakdown of the Base Building, Logistics, Persistence, Garages, and Economy systems, please open your Map Screen (Press 'M') and view the 'A3M Field Manual' tabs in the top left corner.</t>
";

_content ctrlSetStructuredText parseText _text;
