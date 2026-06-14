params [["_waitTime","?"]];

_message = format ["<t align='left'><t size='0.8' color='#00FF00'>A3M PERSISTENCE</t><br/><t size='0.6' color='#FFFFFF'>Mission state will be saved in %1 seconds.</t></t>",_waitTime];
[_message,0.0,0.1,4,0.3,0,795] spawn BIS_fnc_dynamicText;
