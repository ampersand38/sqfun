Public 787343
Private	4865
doesAnyPasswordWork?

//teleport
vehicle player setPos screenToWorld (getMousePosition); vehicle player setDamage 0;
(curatorSelected SELECT 0 SELECT 0) setPos screenToWorld (getMousePosition);

	//enableAI
	private _u = (curatorSelected select 0 select 0);
	{
		[_x, "Path"] remoteExec ["enableAI", _x];
	} forEach units group _u;

//disable VCOM
private _u = (curatorSelected select 0 select 0);
(group _u) setVariable ["Vcm_Disable", true, true];

//look here
private _u = (curatorSelected select 0 select 0);
private _p = screenToWorld [0.5, 0.5];
[_u, _p] remoteExec ["doWatch", _u];

[(curatorSelected select 0 select 0), []] call TFT_fnc_addActions;
[[(curatorSelected select 0 select 0), []], TFT_fnc_addActions] remoteExec ["call"];

(curatorSelected select 0 select 0) forceSpeed 10;

private _u = (curatorSelected select 0 select 0);
if (local _u) then {
	_u disableAI "PATH"; 
	_u setUnitPos "MIDDLE";
}
(objectFromNetId (netId (curatorSelected SELECT 0 SELECT 0))) setPos screenToWorld [0.5,0.5];


player addMagazine (primaryWeaponMagazine player select 0);
player addMagazine (secondaryWeaponMagazine player select 0);

private _m = (curatorSelected SELECT 0 SELECT 0);
_m addMagazine (primaryWeaponMagazine _m select 0);
_m addMagazine (secondaryWeaponMagazine _m select 0);


//create and assign Zeus
private _curator = (allCurators select 0); 
private _curator = (createGroup sideLogic) createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];
{
	if (name _x == "CW4 Ampers") then {
		unassignCurator _curator;
		_x assignCurator _curator;
	};
} forEach allPlayers;
{
  _x addCuratorEditableObjects [allUnits + vehicles, true];
} forEach allCurators;

player remoteControl driver vehicle player;
objNull remoteControl driver vehicle player;

[(curatorSelected select 0), (screenToWorld getMousePosition)] remoteExecCall ["TFT_fnc_CuratorSuppress", (curatorSelected select 0)];
[(curatorSelected select 0), (screenToWorld getMousePosition)] remoteExecCall ["TFT_fnc_CuratorArtillery", (curatorSelected select 0)];

{
	_x animate ["HideTurret",1];
	_x setVehicleAmmo 0;
} forEach (vehicles select {typeOf _x == "O_APC_Wheeled_02_rcws_F"});

vehicle (curatorSelected select 0 select 0) setDamage 0;
(group (curatorSelected select 0 select 0)) setGroupIdGlobal ["Derringer"];

// occupy building
private ["_classes","_c","_b","_bps","_u","_d","_g","_return"];
_return = [];
private _cs = (curatorSelected select 0 select 0);
private _side = side _cs;
_classes = (units group _cs) apply {typeOf _x};

private _position0 = positionCameraToWorld [0, 0, 0]; 
private _position1 = positionCameraToWorld [0, 0, 100]; 
private _intersections = lineIntersectsSurfaces [AGLToASL _position0, AGLToASL _position1, cameraOn, objNull, true, 1, "GEOM"];
if (_intersections isEqualTo []) then {_b = nearestBuilding (screenToWorld getMousePosition);}
else {_b = _intersections select 0 select 2;};

_bps = (_b) buildingPos -1;
_return pushBack format ["%1, %2", typeOf _b, count _bps];
_g = createGroup _side;
_g deleteGroupWhenEmpty true;
_g setCombatMode "YELLOW";
_g setFormation "DIAMOND";
_g setVariable ["Vcm_Disable",true, true];
{
	if ((floor random (10+1)) < 5) then {
		_return pushBack "Y";
		_c = selectRandom _classes;
		_u = _g createUnit [_c, [0, 0, 0], [], 0, "NONE"];
		_u setVariable ["acex_headless_blacklist", true, true];
		_u setPosATL _x;
		_d = _b getDir _x;
		_u setDir _d;
		_u disableAI "PATH";
		_u setUnitPos "UP";
		doStop _u;
	} else {
		_return pushBack "N";
	};
} forEach _bps;
_return

if (isServer) then {
	// Create a new curator logic
	_curator = (createGroup west) createUnit ["ModuleCurator_F",[0,0,0] , [], 0, ""];

	{
		if (name _x == "CW2 Ampers") then {
			unassignCurator _curator;
			_x assignCurator _curator;
		};
	} forEach allPlayers;
	
};

//unit nearest to cursor
nearestObject [screenToWorld (getMousePosition), ["groundweaponholders"]];

0=[] spawn {
	private ["_u", "_p", "_t"];
	_u = (curatorSelected select 0 select 0);
	_p = screenToWorld (getMousePosition);
	_t = "Logic" createVehicleLocal _p;
	_u doWatch _t;
	_u doTarget _t;
	_u doSuppressiveFire _t;
	deleteVehicle _t;
};

(curatorSelected select 0 select 0) doArtilleryFire [(screenToWorld (getMousePosition)), ((curatorSelected select 0 select 0) currentMagazineTurret [0]), 4];

//vls fire on zeus waypoint
private _curator = allCurators # 0;
_curator removeAllEventHandlers "CuratorWaypointPlaced";
_curator addEventHandler ["CuratorWaypointPlaced", {
	params ["_curator", "_group", "_waypointID"];
	if (count units _group > 1) exitWith {};
	
	private _vls = vehicle (units _group # 0);
	if !(typeOf _vls == "B_Ship_MRLS_01_F") exitWith {};
	
	_wPos = waypointPosition [_group, _waypointID];
	private _targetList = _wPos nearEntities ["LaserTarget", 100];
	private _target = objNull;
	if (_targetList isEqualTo []) then
	{
		_target = createVehicle ["LaserTargetW", _wPos, [], 0, "NONE"];
		_curator addCuratorEditableObjects [[_target], true];
		removeFromRemainsCollector [_target];
		_target addEventHandler ["Explosion", {
			deleteVehicle (_this # 0);
			deleteVehicle (_this # 0);
		}];
		[{deleteVehicle (_this # 0);}, [_target], 205] call CBA_fnc_waitAndExecute;
	} else {
		_target = _targetList # 0;
	};
	
	side _vls reportRemoteTarget [_target, 205];
	_vls fireAtTarget [_target];
	deleteWaypoint [_group, _waypointID];
}];



_curator addEventHandler ["CuratorWaypointPlaced", {
	params ["_curator", "_group", "_waypointID"];
	{
		[_x, "Path"] remoteExec ["enableAI", _x];
	} forEach units _group;
}];

{
	_x allowDamage true;
} count (allUnits - switchableUnits - playableUnits);

//invincible and infinite mags
	_x allowDamage false;
{
	_x removeAllEventHandlers "Reloaded";
	_x addEventHandler ["Reloaded", {
		params ["_unit", "_weapon", "_muzzle", "_newMag", "_oldMag"];
		if !(_oldMag isEqualTo []) then {
			_unit addMagazineGlobal (_oldMag select 0);
		};
	}];
} forEach units group (curatorSelected select 0 select 0);

this addEventHandler ["Fired", {
	(_this select 0) setVehicleAmmo 1;
}];

//run code global
if (local (curatorSelected select 0 select 0)) then {
	selected = vehicle (curatorSelected select 0 select 0);
	publicVariableServer "selected";
};
0 = [selected] spawn {
	
};

//AAF orca
if (local player) {
  0=[] spawn {
    _orca = createVehicle ["O_Heli_Light_02_F", position player, [], 0, "NONE"];
    _orca setObjectTextureGlobal [0, "\a3\air_f\Heli_Light_02\Data\heli_light_02_ext_indp_co.paa"]; 
  };
}

{
  if(!alive _x) then
	{
		deleteVehicle _x;
	};
} forEach vehicles select {typeOf _x == "O_Heli_Light_02_F"};


selected = (curatorSelected select 0 select 0);
publicVariable "selected";

selectedClientID = selected remoteExec ["groupOwner", 2];

selectedClientID=groupOwner group selected;
publicVariable "selectedClientID";

[group (curatorSelected select 0 select 0), 2] remoteExec ["setGroupOwner", 2];


player addAction [
	"Jump",
	{
		player setVelocityModelSpace [0,5,10]
	},
	[],
	10,
	true,
	false,
	"",
	"vehicle _this == _this"
];

//cargo get out
this addAction [
	"Disembark",
	{
		params ["_veh"];
		{
			(_x select 0) remoteExec ["unassignVehicle", (_x select 0)];
		} forEach fullCrew [_veh, "cargo"];
	},
	[],
	10,
	true,
	false,
	"",
	"driver _target == _this"
];

player addAction [
	"PULL!",
	{
		[cursorObject, (player vectorModelToWorld [0,100,100] )] remoteExecute ["setVelocity", cursorObject];
	},
	[],
	10,
	true,
	false,
	"",
	"cursorObject isKindOf 'AllVehicles'"
];

[vehicle (curatorSelected select 0 select 0), 1] remoteExec ["setVehicleAmmo", (curatorSelected select 0 select 0)];

//turret watch mouse pos
private _u = (curatorSelected select 0 select 0);
if (local _u) then {
	vehicle _u doWatch (screenToWorld getMousePosition);
} else {
	[vehicle _u, (screenToWorld getMousePosition)] remoteExec ["doWatch", _u];
};

[(curatorSelected select 0), (screenToWorld getMousePosition)] remoteExecCall ["TFT_fnc_CuratorSuppress", (curatorSelected select 0 select 0)];

//lock nearest door
private _r = 4;
private _vn = "";
private _c = _this select 0;
private _t = nearestObject [_c, "HOUSE"];
{
	_snsplit = _x splitString "_";
	if (
		(count _snsplit == 2) &&
		((_snsplit select 0) isEqualTo "door") && 
		(0 < parseNumber (_snsplit select 1))
	) then {
		if ((_c distance (_t modelToWorld (_t selectionPosition _x))) < _r) then {
			_vn = "bis_disabled_" + _x;
			_t setVariable [_vn, 1, true];
		};
	};
} count selectionNames _t;

//toggle lock on the door the camera is pointed at
([100] call ace_interaction_fnc_getDoor) call {
	params ["_house", "_door"];
	private _locked = _house getVariable ("bis_disabled_" + _door);
	if (isNil "_locked") then {
		_locked = true;
	} else {
		_locked = !_locked;
	};
	_house setVariable ["bis_disabled_" + _door, _locked, true];
	[_house, _door, _locked]
};

//toggle door
private _doorInfo = [100] call ace_interaction_fnc_getDoor;
_doorInfo params ["_house", "_door"];
private _getDoorAnimations = _doorInfo call ace_interaction_fnc_getDoorAnimations;
_getDoorAnimations params ["_animations"];
private _phase = [0, 1] select (_house animationPhase (_animations select 0) < 0.5);
{_house animate [_x, _phase]; false} count _animations;



if (hasInterface) then {
	player addItemToUniform "ACE_EarPlugs"; 
};

//NOS button
private _c = this;
_c allowDamage false;
_c addAction ["NOS", {
	private _b = (_this select 0);
	_b setVelocityModelSpace [0,40,0];
}, nil, 6, true, false, "", "_this == (driver _target)"];

//check ai load
private _allHCs = entities "HeadlessClient_F";
private _groupOwners = [];
private _countAI = [];
{
	_groupOwners pushBack (owner _x);
	_countAI pushBack 0;
} forEach _allHCs;
{
	private _unitGroupOwner = (groupOwner group _x);
	private _goIndex = (_groupOwners find _unitGroupOwner);
	_countAI set [_goIndex, (_countAI # _goIndex) + 1];
} forEach (allUnits - allPlayers);
private _result = [];
{
	_result pushBack ((str _x) + "| " + (str (_countAI # _forEachIndex)));
} forEach _allHCs;
_result

//draw gunline
onEachFrame { 
	 if ((curatorSelected # 0) isEqualTo []) exitWith {onEachFrame {};}; 
	 private _unit = curatorSelected # 0 # 0; 
	 private _beg = ASLToAGL (getPosASL _unit); 
	 private _endW = (_beg vectorAdd (_unit weaponDirection currentWeapon _unit vectorMultiply 1000)); 
	 drawLine3D [_beg, _endW, [1,0,0,1]]; 
};

//gain altitude
vehicle player setPos ((getPos vehicle player) vectorAdd [0, 0, 1000]);
vehicle player setVelocity [0, 0, 0];

0= [vehicle player] spawn
{
	private _transport = _this # 0;	
	{
		private _jumper = _x # 0;
		moveOut _jumper;
		private _chute = "Steerable_Parachute_F" createVehicle [0,0,0];
		_chute setPos (getPos _jumper);
		_chute setDir (getDir _transport);
		[_jumper, _chute] remoteExec ["moveInDriver", _jumper];
		_chute setVelocity (velocity _transport);
		sleep 1;
	} forEach fullCrew [_transport, "cargo", false];
};

staticLineJump = {
	params ["_transport"];
	private _jumper = player;
	moveOut _jumper;
	private _chute = "Steerable_Parachute_F" createVehicle [0,0,0];
	_chute setPos (getPos _jumper);
	_chute setDir (getDir _transport);
	[_jumper, _chute] remoteExec ["moveInDriver", _jumper];
	_chute setVelocity (velocity _transport);
};

0= [vehicle player] spawn
{
	private _transport = _this # 0;	
	{
		[_transport] remoteExecCall ["staticLineJump", _x # 0, false];
		sleep 1;
	} forEach fullCrew [_transport, "cargo", false];
};

{
	[_x, _x] call ACE_medical_fnc_treatmentAdvanced_fullHeal;
} forEach allPlayers;
[player, player] call ACE_medical_fnc_treatmentAdvanced_fullHeal;

_vehicle addItemCargo ["ACE_rope36", 10];
[_vehicle] call ace_fastroping_fnc_equipFRIES;

private _action = ["TestName", "Test Name",{},{}] call ace_interact_menu_fnc_createAction;
[_object, ["action", "self-action"] find "action", ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

{ 
    _x setVariable ["acex_headless_blacklist", false, true]; 
} forEach units group (curatorSelected # 0 # 0);

{
	(_x select 0) setVariable ["acex_headless_blacklist", true, true]; 
} forEach fullCrew (curatorSelected # 0 # 0);

//ares custom curator modules
["ACEX Headless", "Blacklist Group", {
	// Get all the passed parameters
	params [["_position", [0,0,0], [[]], 3], ["_objectUnderCursor", objNull, [objNull]]];

	// Log the parameters
	systemChat str _position;
	systemChat str _objectUnderCursor;
	
	group _objectUnderCursor setVariable ["acex_headless_blacklist", true, true];
}] call Ares_fnc_RegisterCustomModule;
["ACEX Headless", "Unblacklist Group", {
	params [["_position", [0,0,0], [[]], 3], ["_objectUnderCursor", objNull, [objNull]]];
	group _objectUnderCursor setVariable ["acex_headless_blacklist", false, true];
}] call Ares_fnc_RegisterCustomModule;

//disable FSM
["AI Behaviour", "Disable FSM", {
	params [["_position", [0,0,0], [[]], 3], ["_objectUnderCursor", objNull, [objNull]]];
	_objectUnderCursor disableAI "FSM";
}] call Ares_fnc_RegisterCustomModule;

(group curatorSelected # 0 # 0) setGroupIdGlobal ["Atlas 1"];

removeAllActions box;
box addAction ["Grab on", {params ['_target', '_caller', '_actionId', '_arguments'];[_caller, _target] call BIS_fnc_attachToRelative;}]

{
	[_x, vehicle cc] remoteExec ["moveInCargo", _x];
} forEach (curatorSelected # 0)

//ladder
private _StepUpLadder = [
	"TFT_StepUpLadder",	// * 0: Action name <STRING>
	"Step up ladder",	// * 1: Name of the action shown in the menu <STRING>
	"",	// * 2: Icon <STRING>
	"",	// * 3: Statement <CODE>
	""	// * 4: Condition <CODE>
] call ace_interact_menu_fnc_createAction;
plate attachTo [_ladder, [0,0,0.13+_currentStep*0.3]];
private _currentStep = ({_x==1} count ([3,4,5,6,7,8,9,10,11] apply {_ladder animationPhase (format["extract_%1", _x]) })) - 1;

private _ladder = ladder;
private _platform = "Box_C_UAV_06_F" createVehicle [0,0,0];
_platform attachTo [player, [0,0,boundingBoxReal _platform # 1 # 2]];
detach _platform;
[_platform, _ladder, true] call BIS_fnc_attachToRelative;
_platform = "Box_C_UAV_06_F" createVehicle [0,0,0];
_platform attachTo [player, [0,-2 * boundingBoxReal _platform # 1 # 1,boundingBoxReal _platform # 1 # 2]];
detach _platform;
[_platform, _ladder, true] call BIS_fnc_attachToRelative;
player action ["ladderOff",ladder];


_arr = [];
{
	_x attachTo [pl, [0, (-2) * (_forEachIndex+1), 0]];
	_arr pushBack [0, (-2) * (_forEachIndex+1), 0];
} forEach (allPlayers - [hc_1, hc_2, hc_3, pl]);
_arr




player allowDamage false;

player allowDamage true;
ch47 setHitpointDamage ["HitEngine", 1];


