if (!hasInterface) exitWith {};

waitUntil {!isNull player};

// Add the backstory record directly to the default "Briefing" (Diary) tab
player createDiaryRecord ["Diary", ["A3M: Narrative", "
<font size='18' color='#FFA500'>A3M: The Shadow War (Narrative Briefing)</font><br/><br/>
<font face='PuristaBold'>DATE:</font> October 14, 2026<br/>
<font face='PuristaBold'>LOCATION:</font> Altis, Mediterranean Sea<br/>
<font face='PuristaBold'>CLASSIFICATION:</font> TOP SECRET // NOFORN // EYES ONLY<br/><br/>

<font size='16' color='#FFA500'>The Geopolitical Flashpoint</font><br/>
The Mediterranean is boiling. Following the collapse of diplomatic talks, the Iranian-backed Canton-Protocol Strategic Alliance Treaty (CSAT) has established a massive, heavily fortified foothold on the island nation of Altis. With Gravia Airfield acting as their logistical crown jewel, CSAT has flooded the region with heavy armor, advanced anti-air networks, and thousands of regular infantry.<br/><br/>

Under the Trump administration, NATO forces—headquartered at the Molos Airfield in the northeast—are unwilling to trigger an overt World War III by launching a full-scale conventional invasion. Instead, the CIA has authorized <font face='PuristaBold'>Operation Black Shield</font>.<br/><br/>

They aren't sending in the Marines. They're sending in the blank checks.<br/><br/>

<font size='16' color='#FFA500'>The Constellis Mandate</font><br/>
You are an elite, highly autonomous operator flying under the banner of <font face='PuristaBold'>Constellis</font> (formerly Blackwater/Academi). Your presence on Altis is completely deniable. If you are captured, the U.S. Government will disavow any knowledge of your actions.<br/><br/>

Your mandate is to tip the scales of power using asymmetric warfare, deep-strike sabotage, and targeted assassinations. You are expected to operate entirely off the grid, funding your own campaign by bleeding the local economy, salvaging enemy hardware, and claiming bounties.<br/><br/>

<font size='16' color='#FFA500'>The Technology Edge &amp; Hardware</font><br/>
While the FIA insurgents rely on rusty technicals and the local population despises you, you have a distinct technological advantage over the conventional forces occupying the island, powered by real-world defense contractors:<br/><br/>

<execute>•</execute> <font face='PuristaBold'>Palantir Gotham on Panasonic Toughbooks:</font> The heart of your intelligence network. Out in the field, operators carry Panasonic Rugged Tablets running Palantir Gotham. By zip-tying and interrogating hostile locals and CSAT sympathizers, you feed raw HUMINT into the system. Palantir processes these data streams in real-time, generating actionable dossiers on High Value Targets (HVTs) hidden deep within enemy territory.<br/>
<execute>•</execute> <font face='PuristaBold'>Anduril Menace Servers (Palantir AIP):</font> To process this AI-driven intelligence at the tactical edge without relying on vulnerable local infrastructure, Constellis outfits your FOBs and armored vehicles with Anduril Menace-X edge servers. These ruggedized compute modules act as the local brain for the Palantir Artificial Intelligence Platform (AIP), ensuring you have uninterrupted targeting data even in the harshest conditions.<br/>
<execute>•</execute> <font face='PuristaBold'>SpaceX Starshield:</font> CSAT has jammed conventional radio networks across Altis. Your encrypted tactical comms, drone telemetry, and connections back to CIA handlers run exclusively through the SpaceX Starshield military constellation. This secure uplink is what allows you to use your Panasonic tablet to call in precision Artillery, Close Air Support (CAS), and heavy transport from NATO-aligned offshore carriers.<br/>
<execute>•</execute> <font face='PuristaBold'>Weaponized Commercial Drones:</font> Taking a page from modern asymmetric conflicts, operators are heavily utilizing modified AR-2 Darter commercial drones. Rigged with C4, Satchel Charges, or M14 Incendiaries, these cheap platforms are flown in FPV Kamikaze mode or used as high-altitude bombers to devastate armored columns before a firefight even begins.<br/><br/>

<font size='16' color='#FFA500'>Tactical Operations: Expanding the Network</font><br/>
CSAT is actively trying to blind the Starshield and Palantir networks by deploying localized signal jammers and locking down communications infrastructure.<br/><br/>

To expand Constellis' operational reach, PMCs are regularly contracted to conduct high-risk <font face='PuristaBold'>Network Infiltration Missions</font>. These missions require operators to assault heavily defended CSAT radio towers and antennas scattered across the AO. Once the perimeter is secured, operators must physically install and hardwire Palantir AIP server blades into the enemy's own infrastructure, hijacking their sensor data and feeding it directly back into the Constellis intelligence grid.<br/><br/>

<font size='16' color='#FFA500'>The Ground Reality &amp; Banking</font><br/>
Survival requires brutal pragmatism. You'll build massive Forward Operating Bases (FOBs) like <font face='PuristaBold'>Fort MAGA</font> using HESCO barriers and heavy turrets hauled in via ACE Cargo networks. You must manage your own hydration, medical supplies, and vehicle maintenance.<br/><br/>

Every road is a gamble. The FIA insurgents have seeded the highways with IEDs, rigged abandoned vehicles as VBIEDs, and deployed suicide bombers into civilian populations.<br/><br/>

<font face='PuristaLight'>Note: The underground financial systems that facilitate PMC payouts, bounties, and offshore accounts are currently being restructured. A massive banking overhaul is impending, which will fully integrate real-world financial institutions and corporate brands into the A3M economy, allowing PMCs to launder and secure their combat earnings with unprecedented realism.</font><br/><br/>

<font size='16' color='#FFA500'>The Shadow War (PvP Directive)</font><br/>
The true danger, however, isn't just AI.<br/><br/>

The battlefield on Altis is fully asymmetric. <font face='PuristaBold'>The Red Faction (CSAT and FIA) is playable.</font> While you operate as a high-tech PMC, other players will drop in directly as OPFOR commanders and insurgents to actively hunt you down. They will use the terrain against you, setting up player-controlled ambushes, rigging VBIEDs, and coordinating the massive CSAT AI war machine to crush your operations.<br/><br/>

Furthermore, within the PMC ranks themselves, alliances are fragile. While friendly fire and rogue PMC-on-PMC firefights over HVT contracts or salvaged armor are a very real possibility, your primary PvP threat comes from human players commanding the vast OPFOR network against you.<br/><br/>

If a rival player gets in your way—whether they are a rogue PMC or a player-controlled CSAT commander—you are authorized to place a bounty on their head via the Palantir network and wipe their FOB off the map. In the Altis buffer zone, there are no war crimes—only profit margins.
"]];
