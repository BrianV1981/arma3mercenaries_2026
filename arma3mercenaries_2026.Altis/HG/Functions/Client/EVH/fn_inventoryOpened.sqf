/*
    Author - HoverGuy
    GitHub - https://github.com/Ppgtjmad/SimpleShops
	Steam - https://steamcommunity.com/id/HoverGuy/
*/
params["_unit","_targetContainer","_secContainer",["_handled",false]];

if((_targetContainer isKindOf "LandVehicle") OR (_targetContainer isKindOf "Ship") OR (_targetContainer isKindOf "Air") OR (_targetContainer isKindOf "Submarine")) then
{
	if((locked _targetContainer) isEqualTo 2) then
	{
        private _ownerData = _targetContainer getVariable ["HG_Owner", []];
        if (count _ownerData > 0) then {
		    private _originalOwnerUID = _ownerData select 0;
            private _sharedOwners = _ownerData select 3;
            private _myUID = getPlayerUID player;

		    if (_myUID != _originalOwnerUID && {!(_myUID in _sharedOwners)}) then
		    {
			    _handled = true;
			    hint (localize "STR_HG_CANNOT_OPEN_INVENTORY");
		    };
        };
	};
};

_handled;
