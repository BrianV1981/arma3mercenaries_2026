/*  Reads item stocks from config publishes them in a hash
*
*/

if (!isServer) exitWith {};

GRAD_LBM_ITEMSTOCKS = [] call CBA_fnc_hashCreate;

_baseConfigs = "true" configClasses (missionConfigFile >> "CfgGradBuymenu");
{
    _baseConfig = _x;
    _baseConfigName = configName _baseConfig;

    _categoryConfigs = "true" configClasses _baseConfig;
    {
        _categoryConfig = _x;
        _categoryConfigName = configName _categoryConfig;

        _itemConfigs = "true" configClasses _categoryConfig;
        {
            _itemConfig = _x;
            _itemConfigName = configName _itemConfig;

            if (isNumber (_itemConfig >> "stock")) then {
                _hashKey = format ["%1_%2_%3", _baseConfigName, _categoryConfigName, _itemConfigName];
                
                private _baseStock = getNumber (_itemConfig >> "stock");
                private _actualStock = _baseStock;
                
                if (_baseStock >= 9999) then {
                    private _rand = random 100;
                    if (_rand < 10) then {
                        _actualStock = 0;
                    } else {
                        if (_rand < 30) then {
                            _actualStock = round(random [1, 3, 5]);
                        } else {
                            if (_rand > 85) then {
                                _actualStock = round(random [20, 50, 100]);
                            } else {
                                _actualStock = round(random [6, 12, 20]);
                            };
                        };
                    };
                };
                
                [GRAD_LBM_ITEMSTOCKS, _hashKey, _actualStock] call CBA_fnc_hashSet;
            };
        } forEach _itemConfigs;
    } forEach _categoryConfigs;
} forEach _baseConfigs;

publicVariable "GRAD_LBM_ITEMSTOCKS";
