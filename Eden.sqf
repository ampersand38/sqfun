Public 787343
doesAnyPasswordWork?
76561197998806051

this disableAI "PATH"; this setUnitPos "UP";
this disableAI "PATH"; this setUnitPos "MIDDLE";
this disableAI "PATH"; this setUnitPos "DOWN";

{_x disableAI "PATH"; } forEach units this;

[objNull,[_this],true] call ace_captives_fnc_moduleSurrender;
[objNull,[_this],true] call ace_captives_fnc_moduleHandcuffed;
this setDamage 0.6;
[this, true, 10000, true] call ace_medical_fnc_setUnconscious;

(group this) setVariable ["Vcm_Disable", true, true];

//unit nearest to cursor
nearestObject [screenToWorld (getMousePosition), ["Man"]]

// occupy building

private ["_classes","_c","_b","_bps","_u","_d","_g","_return"];
_return = [];
_classes = (get3DENSelected "object") apply {typeOf _x};

private _position0 = positionCameraToWorld [0, 0, 0]; 
private _position1 = positionCameraToWorld [0, 0, 100]; 
private _intersections = lineIntersectsSurfaces [AGLToASL _position0, AGLToASL _position1, cameraOn, objNull, true, 1, "GEOM"];
if (_intersections isEqualTo []) then {_b = nearestBuilding (screenToWorld getMousePosition);}
else {_b = _intersections select 0 select 2;};

_bps = (_b) buildingPos -1;
_return pushBack format ["%1, %2", typeOf _b, count _bps];
_g = grpNull;

{
	if ((floor random (10+1)) < 11) then {
		_return pushBack "Y";
		_c = selectRandom _classes;
		if (_g isEqualTo grpNull) then {
			_u = create3DENEntity ["Object", _c, _x];
			_g = group _u;
			_g deleteGroupWhenEmpty true;
			//_g set3DENAttribute ["dynamicSimulation", true];
			//_g set3DENAttribute ["behaviour", "Safe"];
			_g set3DENAttribute ["combatMode", "Open Fire"];
			_g set3DENAttribute ["formation", "Diamond"];
			_g set3DENAttribute ["Init", "this setVariable ['Vcm_Disable', true];"];
		} else {
			_u = _g create3DENEntity ["Object", _c, _x];
		};
		_d = _b getDir _x;
		_u set3DENAttribute ["Rotation", [0, 0, _d]];
		//_u set3DENAttribute ["Init", "this disableAI 'PATH'; this setUnitPos 'UP';"];
		_u set3DENAttribute ["Init", "doStop this;"];
	} else {
		_return pushBack "N";
	};
} forEach _bps;
_return

//init for leader of group that activates when combatMode
if isServer then {
{
	_x disableAI "PATH";
} count units group this;
this addEventHandler ["FiredNear", {
	_man = (_this select 0);
	group _man setBehaviour "COMBAT";
	{
		_x enableAI "PATH";
	} count units group _man;
	_man removeAllEventHandlers "FiredNear";
}];
}

//vic light
this setPilotLight true;

//Infantry group gets new mag on reload
this disableAI "PATH"; this setUnitPos "UP";
this allowDamage false;
this addEventHandler ["Reloaded", {
	_oldMag = _this select 4;
	
	if not (_oldMag isEqualTo []) then {
		_unit = _this select 0;
		_unit addMagazineGlobal (_oldMag select 0);
	};
}];

//uav bomb
{
  detach _x;
} count attachedObjects ttx;
removeAllActions uav;
uav addAction ["Arm", {
	_uav = (_this select 0);
	_bomb = "G_40mm_HE" createVehicle [0,0,100];
	_bomb attachTo [_uav, [0.2,0,-0.1]];
	_bomb = "G_40mm_HE" createVehicle [0,0,100];
	_bomb attachTo [_uav, [-0.2,0,-0.1]];
}, nil, 1.5, false, false, "", "count attachedObjects _target > 2", 5, false];

[configFile >> "CfgVehicles"] call compile preprocessFileLineNumbers "dumpConfig.sqf"
 
str (groupOwner alaqtil1)
aiowner = "test" + str (groupOwner group alaqtil1) + "Test";
[aiowner] remoteExec ["systemChat", -2, true];

//create and assign Zeus
_c = (createGroup sideLogic) createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];
_c addCuratorEditableObjects [allUnits + vehicles, true];
player assignCurator _c;

//spawn all classes matching filter
//CUP_O_Men_TK_MILITIA
//CUP_C_TAKISTAN_Men
_cfgArray = "( 
    (getText (_x >> 'vehicleClass')) isEqualTo 'CUP_C_TAKISTAN_Men'
)" configClasses (configFile >> "CfgVehicles");

_xPos = 0;
_yPos = 0;

{
    _yPos = _yPos + 5;
    _veh = create3DENEntity ["Object", ( configName _x ), player modelToWorld [_xPos, _yPos, 0]];
    if (_yPos >= 100) then {
        _yPos = 0;
        _xPos = _xPos + 5;
    };
} forEach _cfgArray;

// man watch towers
//private _offset = [0,0,0];
private _offset = [-0.0371094,1.39258,1.40843];
//private _c = "Sign_Sphere100cm_F";
private _c = "CUP_O_INS_Soldier";
private _r = 200;

private _u = objNull;
private _g = grpNull;
{
	private _p = _x modelToWorld _offset;
	if (_g isEqualTo grpNull) then {
		_u = create3DENEntity ["Object", _c, _p];
		_g = group _u;
	} else {
		_u = _g create3DENEntity ["Object", _c, _p];
	};
	_u set3DENAttribute ["Rotation", [0, 0, getDir _x]];
	_u set3DENAttribute ["Init", "this disableAI ""PATH""; this setUnitPos ""UP"";"];
} forEach ((screenToWorld [0.5,0.5]) nearObjects ["Land_vez", _r]);

//damage buidlings
{
	_x setDamage [random 1, false];
} forEach (nearestTerrainObjects [this, ["House"], 200]);

//lights
{
  for "_i" from 0 to count getAllHitPointsDamage _x - 1 do
  {
    _x setHitIndex [_i, 0.97];
  };

} forEach nearestObjects 
[
  player, 
  [
  "Lamps_base_F",
  "PowerLines_base_F",
  "PowerLines_Small_base_F"
  ], 
  500
];

//
(get3DENSelected "object" select 0)

//vbied
this addEventHandler ["Killed",{
	"Bo_Mk82" createVehicle (getPosWorld (_this select 0));
}];

this addEventHandler ["Killed",{
	systemChat "BOOM";
	
	(nearestTerrainObjects [_this select 0, ["WALL", "FENCE"], 2] select 0) setDamage 1;
}];

//add to array
if (isNil "vics_to_load") then {vics_to_load = [];}; vics_to_load pushBack this;

/*
 [
  position,
  side,
  details,
  [relative positions],
  [ranks],
  [skill range],
  [ammo range],
  [count, chance],
  direction
 ] call BIS_fnc_spawnGroup
*/
_grp = [
  getPos player, 
  west, 
  configfile >> "CfgGroups" >> "West" >> "rhs_faction_usarmy_d" >> "rhs_group_nato_usarmy_d_infantry" >> "rhs_group_nato_usarmy_d_infantry_squad"
] call BIS_fnc_spawnGroup;
_grp
 
fnc_createWave = {
  private "_grp";
  {
    _grp = [
      getPos player, 
      west, 
      configfile >> "CfgGroups" >> "West" >> "RHS_USAF" >> "Infantry" >> ""
    ] call BIS_fnc_spawnGroup;
	private "_u";
	"B_GEN_Soldier_F" createUnit [_grp, _grp];
	"B_GEN_Soldier_F" createUnit [_grp, _grp];
	"B_GEN_Soldier_F" createUnit [_grp, _grp];
	"B_GEN_Soldier_F" createUnit [_grp, _grp];
	"B_GEN_Soldier_F" createUnit [_grp, _grp];
    { 
      _x addCuratorEditableObjects [units _grp, true]; 
    } forEach allCurators;
    _grp setGroupOwner (owner hvt);
    _grp addWaypoint [hvt, 100];
  } forEach ZM_spawnPoints;
};


{
	// _x = [[1,2]]
	{
		// _x = [1,2]
		{
			// _x = 1
		} forEach _x;
	} forEach _x;
} forEach [[[1,2]]];

// buildingExit
private _b = nearestBuilding player;
private _bes = [];
private _be = [];
for "_i" from 0 to 100 step 1 do {
	_be = _b buildingExit _i;
	if (_be isEqualTo [0,0,0]) exitWith {};
	_bes pushBack _be;
};
{
	private _entity = create3DENEntity ["Object", "Sign_Sphere100cm_F", _x];
	private _name = format ["exit_%1", _forEachIndex];
	_entity set3DENAttribute ["name", _name];
} forEach _bes;

//hightlight doors
private _r = 4;
private _vn = "";
private _c = getPos player;
private _t = nearestObject [_c, "HOUSE"];
{
	_snsplit = _x splitString "_";
	if (	//conditions for door_x
		(count _snsplit == 2) &&
		((_snsplit select 0) isEqualTo "door") && 
		(0 < parseNumber (_snsplit select 1))
	) then {
		private _ep = (_t modelToWorld (_t selectionPosition _x));
		private _entity = create3DENEntity ["Object", "Sign_Sphere100cm_F", _ep];
		private _name = _x;
		_entity set3DENAttribute ["name", _name];
		
	};
} count selectionNames _t;

//lock nearest door
private _r = 4;
private _vn = "";
private _c = getPos this;
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

//"head", "body", "arm_l", "arm_r", "leg_l", "leg_r"
//"bullet", "grenade", "explosive", "shell", "vehiclecrash", "backblast", "stab", "punch", "falling", "ropeburn", "unknown"
[this, 0.4, "head", "vehiclecrash"] call ace_medical_fnc_addDamageToUnit;
[this, 0.5, "body", "vehiclecrash"] call ace_medical_fnc_addDamageToUnit;
[this, 0.3, "leg_l", "vehiclecrash"] call ace_medical_fnc_addDamageToUnit;
[this, 0.4, "leg_r", "vehiclecrash"] call ace_medical_fnc_addDamageToUnit;

{
	[_x, 0.4, "leg_r", "bullet"] call ace_medical_fnc_addDamageToUnit;
} forEach allplayers;

//3den attributes
{
	_x set3DENAttribute ["objectIsSimple", true];
	_x set3DENAttribute ["fuel", true];
} forEach (get3DENSelected "object");

//Pandur APC NATO
_apc = curatorSelected # 0 # 0;
_apc lockTurret [[0],true]; 
{
	_apc removeWeaponTurret [_x,[0]];
} forEach (_apc weaponsTurret [0]);
_apc setObjectTextureGlobal [0, "A3\Armor_F_Gamma\APC_Wheeled_03\Data\apc_wheeled_03_ext_co.paa"];  
_apc setObjectTextureGlobal [1, "A3\Armor_F_Gamma\APC_Wheeled_03\Data\apc_wheeled_03_ext2_co.paa"];  
_apc setObjectTextureGlobal [2, "A3\Armor_F_Gamma\APC_Wheeled_03\Data\rcws30_co.paa"];  
_apc setObjectTextureGlobal [3, "A3\Armor_F_Gamma\APC_Wheeled_03\Data\apc_wheeled_03_ext_alpha_co.paa"]; 
_apc animate ["HideTurret",1]; 

_veh = vehicle (curatorSelected select 0 select 0);
_veh setObjectTextureGlobal [0,'A3\armor_f_beta\apc_tracked_01\data\apc_tracked_01_aa_body_opfor_co.paa']; 
_veh setObjectTextureGlobal [2,'A3\data_f\vehicles\turret_opfor_co.paa']; 
_veh setObjectTextureGlobal [3,'A3\armor_f_beta\apc_tracked_01\data\apc_tracked_01_crv_opfor_co.paa']; 

//OH-6 smoke
this addWeaponTurret ["SmokeMarker", [-1]];
this addMagazineTurret ["SmokeMarker", [-1]];

//line up terrain objects
private _position0 = positionCameraToWorld [0, 0, 0]; 
private _position1 = positionCameraToWorld [0, 0, 100]; 
private _intersections = lineIntersectsSurfaces [AGLToASL _position0, AGLToASL _position1, cameraOn, objNull, true, 1, "GEOM"];
if (_intersections isEqualTo []) exitWith {objNull};
 
private _terrainObj = _intersections select 0 select 2;
private _editorObj = (get3DENSelected "object" # 0);
_editorObj set3DENAttribute ["Position", getPosATL _terrainObj];
_editorObj set3DENAttribute ["Rotation", [0,0,direction _terrainObj]];

//line up editor objects 
private _position0 = positionCameraToWorld [0, 0, 0];  
private _position1 = positionCameraToWorld [0, 0, 100];  
private _intersections = lineIntersectsSurfaces [AGLToASL _position0, AGLToASL _position1, cameraOn, objNull, true, 1, "GEOM"]; 
if (_intersections isEqualTo []) exitWith {objNull}; 
  
private _terrainObj = _intersections select 0 select 2; 
private _editorObj = (get3DENSelected "object" # 0); 
private _attributes = ["Position", "Rotation"]; 
private _values = []; 
{ 
	private _value = (_terrainObj get3DENAttribute _x) # 0; 
	_values pushBack _value; 
	_editorObj set3DENAttribute [_x, _value]; 
} forEach _attributes; 
[_terrainObj, _editorObj, _attributes, _values] 

//inventory gear 
{ 
    if (_x isKindOf "CAManBase") then 
    {	
        _x linkItem "ACE_NVG_Wide";
        _x addWeapon "ACE_Vector";
		
		//earplugs
		if !("ACE_EarPlugs" in uniformItems _x) then {
			_x addItemToUniform "ACE_EarPlugs";
		};
		
		//etool
		if (backpack _x == "") then {
			_x addBackpack "B_AssaultPack_blk";
		};
		if !("ACE_EntrenchingTool" in backpackItems _x) then {
			_x addItemToBackpack "ACE_EntrenchingTool";
		};
		
        save3DENInventory [_x]; 
    }; 
} 
forEach get3DENSelected "object";
 

// The following script takes every Land_Wreck_Ural_F on the map and turns them into a Land_Wreck_Slammer_F, and every Land_Wreck_Hunter_F into a Land_Wreck_T72_hull_F.
// If you edit the _map and put the same "from" class on multiple lines, the script will randomly choose a "to" class name to swap it to. 
private _map = [
    ["Land_Wreck_Ural_F", "Land_Wreck_Slammer_F"],
    ["Land_Wreck_Hunter_F", "Land_Wreck_T72_hull_F"]
];

collect3DENHistory {
    {
        private _entity = _x;
        private _mapEntries =
            _map select { _x select 0 == typeOf _entity };

        if (count _mapEntries > 0) then
        {
            [_entity] set3DENObjectType
                (selectRandom _mapEntries select 1);
        };
    }
    forEach (all3DENEntities select 0);
};





