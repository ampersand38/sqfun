/*
	Author: Ampers

	Description:
	Adds actions to Bobcat enabling interactions with Ramparts.
	
	Parameter(s):
	0:	Object	- The Bobcat vehicle

	Returns:
	Nothing

	Example:
	[[bobcat], "makeARV.sqf"] remoteExec ["execVM", -2, true];
*/

params ["_arv"];

//remove turret
_arv lockTurret [[0],true]; 
_arv removeWeaponTurret ["LMG_RCWS",[0]];
_arv animate ["HideTurret",1]; 

//add rampart actions
removeAllActions _arv;
_arv addAction [
	"Create Rampart",
	{
		_arv = (_this select 0);
		_dir = getDir _arv;
		_pos = _arv getPos [7, _dir];
		_ram = createVehicle ["Land_Rampart_F", [0,0,100], [], 0, "CAN_COLLIDE"];
		_ram allowDamage false;
		_ram setDir _dir + 90;
		_ram setPos [_pos select 0, _pos select 1, -2];
	},
	[],
	1.5,
	false,
	false,
	"",
	"_this in (crew _target);"
];
_arv addAction [
	"Raise Rampart",
	{
		_arv = (_this select 0);
		_rams = nearestObjects [_arv, ["Land_Rampart_F"], 10];
		if( (count _rams) > 0) then {
			_ram = _rams select 0;
			_dir = _arv getDir _ram;
			if (_dir - getDir _arv < 45) then {
				_pos = getPos _ram;
				_h = (_pos select 2);
				if (_h < 0) then {
					_h = _h + 0.2;
					if (_h > 0) then {_h = 0;};
				};
				_ram setPos [_pos select 0, _pos select 1, _h];
			};
		};
	},
	[],
	1.5,
	false,
	false,
	"",
	"_this in (crew _target);"
];
_arv addAction [
	"Lower Rampart",
	{
		_arv = (_this select 0);
		_rams = nearestObjects [_arv, ["Land_Rampart_F"], 10];
		if( (count _rams) > 0) then {
			_ram = _rams select 0;
			_dir = _arv getDir _ram;
			if (_dir - getDir _arv < 45) then {
				_pos = getPos _ram;
				_h = (_pos select 2);
				if (_h > -2) then {
					_h = _h - 0.2;
					if (_h < -2) then {_h = -2;};
				};
				_ram setPos [_pos select 0, _pos select 1, _h];
			};
		};
	},
	[],
	1.5,
	false,
	false,
	"",
	"_this in (crew _target);"
];
_arv addAction [
	"Remove Rampart",
	{
		_arv = (_this select 0);
		_rams = nearestObjects [_arv, ["Land_Rampart_F"], 10];
		if( (count _rams) > 0) then {
			_ram = _rams select 0;
			_dir = _arv getDir _ram;
			if (_dir - getDir _arv < 45) then {
				deleteVehicle _ram;
			};
		};
	},
	[],
	1.5,
	false,
	false,
	"",
	"_this in (crew _target);"
];

//inventory clear
clearWeaponCargoGlobal _arv;
clearmagazineCargoGlobal _arv;
clearitemCargoGlobal _arv;
clearBackpackCargoGlobal _arv;

//inventory fill
_arv addItemCargoGlobal ["ToolKit", 2];
_arv addBackpackCargoGlobal ["B_Kitbag_rgr", 2];
_arv addBackpackCargoGlobal ["I_mas_Tripod_Bag", 4];
_arv addBackpackCargoGlobal ["I_mas_M2_Gun_Bag", 4];
_arv addBackpackCargoGlobal ["I_mas_Tripod_h_Bag", 4];
_arv addBackpackCargoGlobal ["I_mas_M2_h_Gun_Bag", 4];

/*	Debug Console

if (local (curatorSelected select 0 select 0)) then {
	selected = vehicle (curatorSelected select 0 select 0);
	publicVariableServer "selected";
};
[[selected],{

	_arv = (_this select 0);

	_arv lockTurret [[0],true]; 
	_arv removeWeaponTurret ["LMG_RCWS",[0]];
	_arv animate ["HideTurret",1]; 

	removeAllActions _arv;
	_arv addAction [
		"Create Rampart",
		{
			_arv = (_this select 0);
			_dir = getDir _arv;
			_pos = _arv getPos [7, _dir];
			_ram = createVehicle ["Land_Rampart_F", [0,0,100], [], 0, "CAN_COLLIDE"];
			_ram allowDamage false;
			_ram setDir _dir + 90;
			_ram setPos [_pos select 0, _pos select 1, -2];
		},
		[],
		1.5,
		false,
		false,
		"",
		"_this in (crew _target);"
	];
	_arv addAction [
		"Raise Rampart",
		{
			_arv = (_this select 0);
			_rams = nearestObjects [_arv, ["Land_Rampart_F"], 10];
			if( (count _rams) > 0) then {
				_ram = _rams select 0;
				_dir = _arv getDir _ram;
				if (_dir - getDir _arv < 45) then {
					_pos = getPos _ram;
					_h = (_pos select 2);
					if (_h < 0) then {
						_h = _h + 0.2;
						if (_h > 0) then {_h = 0;};
					};
					_ram setPos [_pos select 0, _pos select 1, _h];
				};
			};
		},
		[],
		1.5,
		false,
		false,
		"",
		"_this in (crew _target);"
	];
	_arv addAction [
		"Lower Rampart",
		{
			_arv = (_this select 0);
			_rams = nearestObjects [_arv, ["Land_Rampart_F"], 10];
			if( (count _rams) > 0) then {
				_ram = _rams select 0;
				_dir = _arv getDir _ram;
				if (_dir - getDir _arv < 45) then {
					_pos = getPos _ram;
					_h = (_pos select 2);
					if (_h > -2) then {
						_h = _h - 0.2;
						if (_h < -2) then {_h = -2;};
					};
					_ram setPos [_pos select 0, _pos select 1, _h];
				};
			};
		},
		[],
		1.5,
		false,
		false,
		"",
		"_this in (crew _target);"
	];
	_arv addAction [
		"Remove Rampart",
		{
			_arv = (_this select 0);
			_rams = nearestObjects [_arv, ["Land_Rampart_F"], 10];
			if( (count _rams) > 0) then {
				_ram = _rams select 0;
				_dir = _arv getDir _ram;
				if (_dir - getDir _arv < 45) then {
					deleteVehicle _ram;
				};
			};
		},
		[],
		1.5,
		false,
		false,
		"",
		"_this in (crew _target);"
	];

	clearWeaponCargoGlobal _arv;
	clearmagazineCargoGlobal _arv;
	clearitemCargoGlobal _arv;
	clearBackpackCargoGlobal _arv;

	_arv addItemCargoGlobal ["ToolKit", 2];
	_arv addBackpackCargoGlobal ["B_Kitbag_rgr", 2];
	_arv addBackpackCargoGlobal ["I_mas_Tripod_Bag", 4];
	_arv addBackpackCargoGlobal ["I_mas_M2_Gun_Bag", 4];
	_arv addBackpackCargoGlobal ["I_mas_Tripod_h_Bag", 4];
	_arv addBackpackCargoGlobal ["I_mas_M2_h_Gun_Bag", 4];

}] remoteExec ["spawn", 0, true];