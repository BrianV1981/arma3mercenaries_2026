/*	
	arma3mercenaries_killFeed.sqf
	Author: BrianV1981

	Description:
	This script handles the display of a kill feed in Arma 3, providing real-time notifications to players when they 
	achieve a kill. The kill feed includes visual and auditory feedback, showing detailed information about the 
	enemy killed, the distance of the kill, and the weapon used.

	The script checks whether the killer is local to the machine and if the killed unit is a human-like entity 
	(CAManBase). It then formats a HUD message with the name of the killed unit, the distance of the kill, and the 
	weapon used. The message is displayed on the player's screen for a configurable duration and can be accompanied 
	by a notification sound if enabled in the CBA settings.

	Features:
	- Killfeed HUD: Displays the name of the killed unit, distance, and weapon used.
	- Killfeed Sound: Plays a configurable sound upon a successful kill.
	- Customization: Duration and sound can be customized via CBA settings.
	- Faction Colors: The kill feed uses faction-specific colors for better clarity.

	Usage:
	Integrate this script into your mission to provide players with immersive feedback on their combat performance. 
	This script enhances situational awareness by immediately informing players of their successful kills and providing 
	contextual information about the engagement.

	Dependencies:
	- The script relies on CBA (Community Base Addons) for settings management.
	- Works in conjunction with other modules from the arma3mercenaries framework.
*/
/*
    arma3mercenaries_killFeed.sqf
    Author: BrianV1981
    Version: v0.005
    Notes: Added Penalty Warning Duration setting usage. Using profile names & specified positioning. Defines Warning HUD function.
*/
diag_log "//________________ arma3mercenaries Kill Feed & Warnings Script v0.005 ________________";

//======================================================
// FUNCTION to display Penalty/Warning Dynamic Text (Client Side)
//======================================================
A3M_fnc_showWarningHUD = {
    params ["_message"];
    if (isNull player || !hasInterface) exitWith {};

    // <<< USE NEW CBA SETTING FOR DURATION >>>
    private _duration = if (isNil "arma3mercenaries_penaltyWarningDuration") then { 6 } else { arma3mercenaries_penaltyWarningDuration };

    // --- Display Parameters (Using your specified values) ---
    private _posX = 0.00; // Your left-aligned value
    private _posY = 1.00; // Your bottom-edge value
    // Duration fetched above
    private _fadeInTime = 0.5;
    private _deltaY = 0; // Stationary
    private _rscLayer = 7018;

    // Spawn dynamic text using the fetched duration
    try {
        [_message, _posX, _posY, _duration, _fadeInTime, _deltaY, _rscLayer] spawn bis_fnc_dynamicText;
    } catch {
        diag_log format["[A3M WARNING CLI %1] ERROR Spawning Warning HUD: %2", player, _exception];
    };
};

//======================================================
// Kill Feed Event Handler (Client Side)
//======================================================
addMissionEventHandler ["entityKilled", {
    params ["_killed", "_killer", "_instigator"];
    if (isNull _instigator) then { _instigator = _killer };

    // Run only on the killer's machine for their specific HUD
    if (local _instigator && _killed isKindOf "CAManBase" && isPlayer _instigator) then {
        private _killFeedEnabled = if (isNil "arma3mercenaries_killFeedEnabled") then { true } else { arma3mercenaries_killFeedEnabled };
        if (_killFeedEnabled) then {
            private _prefix = format["[A3M KF CLI %1]", player];
            private _killedType = typeOf _killed;
            private _killed_Name = name _killed;
            private _killed_Color = "#FFFFFF"; try { _killed_Color = (side group _killed call BIS_fnc_sideColor) call BIS_fnc_colorRGBtoHTML; } catch {};
            private _distance = _instigator distance2D _killed;
            private _weapon = currentWeapon _instigator;
            private _weaponDisplayName = "Unknown"; try { if (_weapon != "") then { _weaponDisplayName = getText(configFile >> "CfgWeapons" >> _weapon >> "displayName"); }; if (_killer != _instigator && {!isNull _killer}) then { _weaponDisplayName = getText(configFile >> "CfgVehicles" >> typeOf _killer >> "displayName"); }; } catch {};
            // Use kill feed duration setting
            private _killFeedDuration = if (isNil "arma3mercenaries_killFeedDuration") then { 5 } else { arma3mercenaries_killFeedDuration };

            // Format HUD text
            private _kill_HUD = format[ "<t size='0.45' align='center' shadow='1'>Killed </t><t size='0.65' align='center' shadow='1' color='%1'>%2 </t><t size='0.45' align='center' shadow='1'>[%3m | %4]</t>", _killed_Color, _killed_Name, floor _distance, _weaponDisplayName ];

             // --- Position Parameters (Using your specified values) ---
             private _posX = 0.00;
             private _posY = 0.00;
             private _deltaY = 0; // Stationary
             private _rscLayer = 7017;
             private _fadeInTime = 0.5;

             // --- Spawn dynamic text ---
             try { [_kill_HUD, _posX, _posY, _killFeedDuration, _fadeInTime, _deltaY, _rscLayer] spawn bis_fnc_dynamicText; } catch { diag_log format["%1 ERROR Spawning KF HUD: %2", _prefix, _exception]; };

            // Play Sound
            private _soundEnabled = if (isNil "arma3mercenaries_killNotificationSound") then { true } else { arma3mercenaries_killNotificationSound };
             if ( _soundEnabled ) then { playSound "Killfeed_notification"; };
        };
    };
}];
diag_log "//________________ arma3mercenaries Kill Feed & Warnings Script v0.005 Finished Loading ________________";