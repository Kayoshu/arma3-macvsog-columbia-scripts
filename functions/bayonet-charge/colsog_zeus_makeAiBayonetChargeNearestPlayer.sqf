/*
 * Custom Zeus module: Makes AI group bayonet charge the nearest player.
 *
 * Arguments:
 * 0: logic position (not used)
 * 1: attached object
 *
 * Return Value:
 * None
 *
 */

params [["_pos", [0,0,0] , [[]], 3], ["_unit", objNull, [objNull]]];

if (isNull _unit || not (_unit isKindOf "CAManBase")) exitWith {
	["Need an AI unit", -1, 1, 4, 0] spawn BIS_fnc_dynamicText;
	playSound "FD_Start_F";
};

private _unitGroup = group _unit;

{
    private _closestTarget = [_x] call COLSOG_fnc_getClosestTarget;
    if (isNull _closestTarget) exitWith {
        systemChat "No player in a 500m radius";
    };

    [_x] join grpNull;
    private _newGroup = group _x;

    // Unit setup (remove ammo, sprint mode, etc.)
    _rifle = primaryWeapon _x;
    removeAllWeapons _x;
    _x addWeapon _rifle;
    _x setUnitPos "UP";
    _x disableAI "FSM";
    _x setBehaviour "AWARE";
    _x allowFleeing 0;
    _x forceSpeed (_closestTarget getSpeed "FAST");
    _x doTarget _closestTarget;

    [
        [_newGroup, _closestTarget],
        {
            params ["_attacker", "_target"];

            private _stop = false;
            private _currentWaypointPos = [0, 0, 0];

            while {(({ alive _x } count units _attacker != 0) && (!_stop))} do {
                sleep 1;

                private _distanceToTarget = (leader _attacker) distance _target;

                if (_distanceToTarget > 3) then {
                    _currentWaypointPos = [_attacker, _target, _currentWaypointPos] call COLSOG_fnc_moveAi;
                } else {
                    [_attacker, _target] call COLSOG_fnc_attackAi;
                };

                // Update targeted player.
                if (!alive _target || lifeState _target == "INCAPACITATED") then {
                    _target = [leader _attacker] call COLSOG_fnc_getClosestTarget;
                    if (isNull _target) then {
                        _stop = true;
                    } else {
                        systemChat "switching target";
                    };
                };
            };

            systemChat "end";
        }
    ] remoteExecCall ["spawn", 2, false];

} foreach units _unitGroup;
