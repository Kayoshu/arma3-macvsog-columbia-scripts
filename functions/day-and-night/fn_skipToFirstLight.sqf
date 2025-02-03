/*
 * Skip To First Light Event
 * Global function to create the necessary CBA eventhandler to be present on all possible clients AND server.
 * Called as a post-init function.
 *
 * Arguments:
 * 0: _dawnBeforeTime start of the time window for dawn _sunriseTime - (colsog_dayAndNight_dawnDuration / 60)
 *
 * Example:
 * ["COLSOG_skipToFirstLight", [_dawnBeforeTime]] call CBA_fnc_globalEvent;
 *
 */

private _skipFirstLightid = ["COLSOG_skipToFirstLight", {
	
	params [["_dawnBeforeTime", -1]];
	
	// exclude zeus
	if (!isNull (getAssignedCuratorLogic player)) exitWith {};
	
	// exclude driver
	if (((driver (vehicle player)) isEqualTo player) && !((vehicle player) isKindOf "CAManBase")) exitWith {};

	if (_dawnBeforeTime == -1) then { // if _dawnBeforeTime is default then event is called from squad leader, calculate _dawnBeforeTime
		private _sunriseSunsetTime = date call BIS_fnc_sunriseSunsetTime;
		private _sunriseTime = (_sunriseSunsetTime select 0);
		_dawnBeforeTime = _sunriseTime - (colsog_dayAndNight_dawnDuration / 60);
	};
	
	[_dawnBeforeTime] spawn {
		params ["_dawnBeforeTime"];

		private _idLayer1 = ["Text1Display"] call BIS_fnc_rscLayer;
		_idLayer1 cutText ["", "BLACK OUT", 1];
		uiSleep 1;

		date params ["_year", "_month", "_day", "_hours", "_minutes"];

		if (_hours > 12) then {
			_day = _day + 1;
		};

		_hours = floor _dawnBeforeTime;
		_minutes = round ((_dawnBeforeTime - (floor _dawnBeforeTime)) * 60);
		_minutes = _minutes - 3; // substract 3min so night/dawn feedback can trigger

		setDate [_year, _month, _day, _hours, _minutes];

		uiSleep 4;
		_idLayer1 cutText ["", "BLACK IN", 1];

	};

}] call CBA_fnc_addEventHandler;