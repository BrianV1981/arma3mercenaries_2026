/*
File: arma3mercenaries/jukebox/arma3mercenaries_jukebox_customInterface.hpp
Purpose: Defines the custom interface for the Arma3Mercenaries jukebox, including track buttons and a mute button.

// Add arma3mercenaries Radio action to bring up interface
_this addAction ["arma3mercenaries Radio", {
    createDialog "customInterface";
}, "", 0, false, false, "", "player distance _target < 5"];

*/

class CustomInterface {
    idd = -1;
    movingEnable = 0;
    enableSimulation = 1;
    controlsBackground[] = {CustomBackground};
    objects[] = {};
    controls[] = {
        Title, MuteButton,
        TrackButton1, TrackButton2, TrackButton3, TrackButton4, TrackButton5,
        TrackButton6, TrackButton8, TrackButton9, TrackButton11, TrackButton12,
        TrackButton20, TrackButton21, TrackButton22, TrackButton23,
        TrackButton24, TrackButton25, TrackButton26, TrackButton27, TrackButton28,
        TrackButton29, MercenaryRadioButton
    };

    class CustomBackground {
        idc = -1;
        type = 0; // CT_STATIC
        style = 512; // ST_HUD_BACKGROUND
        text = "";
        colorText[] = {0, 0, 0, 0};
        font = "RobotoCondensed";
        sizeEx = 0.04;
        shadow = 0;
        colorBackground[] = {0, 0, 0, 0.6};
        x = 0.2; // Adjusted for the new title and buttons
        y = 0.2;
        w = 0.6; // adjust width
        h = 0.6; // adjust height
    };

    class CustomButton {
        idc = -1;
        type = 1; // CT_BUTTON
        style = 2; // ST_CENTER
        text = "";
        colorText[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.1};
        colorBackground[] = {0,0,0,0.8};
        colorFocused[] = {1,1,1,0.5};
        colorBackgroundActive[] = {1,1,1,0.8}; // hover
        colorBackgroundDisabled[] = {0.3,0.3,0.3,1};
        colorBackgroundFocused[] = {0,0,0,0.5};
        colorShadow[] = {0,0,0,0};
        colorBorder[] = {0,0,0,1};
        soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
        soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
        soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
        soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
        animTextureDefault = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
        animTextureNormal = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
        animTextureDisabled = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
        animTextureOver = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\over_ca.paa";
        animTextureFocused = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\focus_ca.paa";
        animTexturePressed = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\down_ca.paa";
        shadow = 0;
        font = "RobotoCondensed";
        sizeEx = 0.03;
        offsetX = 0.003;
        offsetY = 0.003;
        offsetPressedX = 0.002;
        offsetPressedY = 0.002;
        borderSize = 0;
        w = 0.25; // Button width
        h = 0.03; // Button height
    };

    class Title {
        idc = -1;
        type = 0; // CT_STATIC
        style = 2; // ST_CENTER
        text = "arma3mercenaries Radio";
        colorText[] = {1, 1, 1, 1};
        font = "RobotoCondensed";
        sizeEx = 0.06;
        shadow = 0;
        colorBackground[] = {0, 0.5, 0, 1};
        x = 0.2; // Adjusted to match background
		y = 0.2;
		w = 0.6; // Adjusted to match background width
		h = 0.05;
    };
    
    // Track buttons
	class TrackButton1: CustomButton {
		text = "Surfing Bird";
		x = 0.23;	// left/right (.52 is right of .23)
		y = 0.3;	// up/down (.34 is down from .3)
		action = "['myTrack1'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Trashmen', 'Surfing Bird'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};
	
	class TrackButton2: CustomButton {
		text = "Paint It, Black";
		x = 0.52; 
		y = 0.3;
		action = "['myTrack2'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Rolling Stones', 'Paint It, Black'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton3: CustomButton {
		text = "These Boots Are Made For Walkin";
		x = 0.23; 
		y = 0.34;
		action = "['myTrack3'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Nancy Sinatra', 'These Boots Are Made For Walkin'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton4: CustomButton {
		text = "Wooly Bully";
		x = 0.52; 
		y = 0.34;
		action = "['myTrack4'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Sam the Sham & the Pharaos', 'Wooly Bully'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton5: CustomButton {
		text = "Cisco Kid";
		x = 0.23; 
		y = 0.38;
		action = "['myTrack5'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'WAR', 'Cisco Kid'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton6: CustomButton {
		text = "Fortunate Son";
		x = 0.52; 
		y = 0.38;
		action = "['myTrack6'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Creedence Clearwater Revival', 'Fortunate Son'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton8: CustomButton {
		text = "Hush";
		x = 0.23;
		y = 0.42;
		action = "['myTrack8'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Deep Purple', 'Hush'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton9: CustomButton {
		text = "The Letter";
		x = 0.52;
		y = 0.42;
		action = "['myTrack9'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Box Tops', 'The Letter'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton11: CustomButton {
		text = "Son of a Preacher Man";
		x = 0.23;
		y = 0.46;
		action = "['myTrack11'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Dusty Springfield', 'Son of a Preacher Man'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton12: CustomButton {
		text = "Shakin All Over";
		x = 0.52;
		y = 0.46;
		action = "['myTrack12'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Guess Who', 'Shakin All Over'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton20: CustomButton {
		text = "Gimmie Some Lovin";
		x = 0.23;
		y = 0.5;
		action = "['myTrack20'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Spencer Davis Group', 'Gimmie Some Lovin'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton21: CustomButton {
		text = "Gimmie Shelter";
		x = 0.52; 
		y = 0.5;
		action = "['myTrack21'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Rolling Stones', 'Gimmie Shelter'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton22: CustomButton {
		text = "Hello, I Love You";
		x = 0.23; 
		y = 0.54;
		action = "['myTrack22'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Doors', 'Hello, I Love You'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton23: CustomButton {
		text = "White Rabbit";
		x = 0.52; 
		y = 0.54;
		action = "['myTrack23'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Jefferson Airplane', 'White Rabbit'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton24: CustomButton {
		text = "Mellow Yellow";
		x = 0.23; 
		y = 0.58;
		action = "['myTrack24'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Donovan', 'Mellow Yellow'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton25: CustomButton {
		text = "Time Has Come Today";
		x = 0.52; 
		y = 0.58;
		action = "['myTrack25'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Chambers Brothers', 'Time Has Come Today'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton26: CustomButton {
		text = "House Of The Rising Sun";
		x = 0.23; 
		y = 0.62;
		action = "['myTrack26'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Animals', 'House Of The Rising Sun'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton27: CustomButton {
		text = "Light My Fire";
		x = 0.52; 
		y = 0.62;
		action = "['myTrack27'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'The Doors', 'Light My Fire'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton28: CustomButton {
		text = "Sittin On The Dock Of The Bay";
		x = 0.23; 
		y = 0.66;
		action = "['myTrack28'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Otis Redding', 'Sittin On The Dock Of The Bay'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class TrackButton29: CustomButton {
		text = "All Along The Watchtower";
		x = 0.52; 
		y = 0.66;
		action = "['myTrack29'] remoteExecCall ['playMusic', 0, true]; [format ['<t align=""left""><t size=""0.8"" color=""#00FF00"">NOW PLAYING</t><br/><t size=""0.6"" color=""#FFFFFF"">%1</t><br/><t size=""0.5"" color=""#AAAAAA"">%2</t></t>', 'Jimmi Hendrix', 'All Along The Watchtower'], 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class MercenaryRadioButton: CustomButton {
		text = "Arma3mercenaries Radio";
		x = 0.33;
		y = 0.70;
		w = 0.34;
		action = "['<t align=""left""><t size=""1.2"" color=""#00FF00"">A3M RADIO</t><br/><t size=""0.8"" color=""#FFFFFF"">Created By: BrianV1981</t></t>', 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};

	class MuteButton: CustomButton {
		text = "Mute";
		x = 0.33;
		y = 0.74;
		w = 0.34;
		action = "['myTrack14'] remoteExecCall ['playMusic', 0, true]; ['<t align=""left""><t size=""0.8"" color=""#FF0000"">RADIO MUTED</t></t>', 0.0, 0.1, 5, 0.5, 0, 789] spawn BIS_fnc_dynamicText;";
	};
};